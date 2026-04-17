import { genkit, z } from "genkit";
import { googleAI } from "@genkit-ai/google-genai";
import { HttpsError, onCall, onCallGenkit } from "firebase-functions/https";
import { defineSecret } from "firebase-functions/params";
import { Datastore } from "@google-cloud/datastore";

/* ---------------- SECRET ---------------- */

const googleApiKey = defineSecret("GOOGLE_GENAI_API_KEY");

/* ---------------- DATASTORE ---------------- */

const datastore = new Datastore();

/* ---------------- AI SETUP ---------------- */

const ai = genkit({
  plugins: [googleAI()],
  model: "googleai/gemini-2.5-flash",
});

/* ---------------- SCHEMAS ---------------- */

const inputSchema = z.object({
  heartRate: z.number(),
});

const outputSchema = z.object({
  risk: z.enum(["low", "moderate", "high"]),
  explanation: z.string(),
  advice: z.string(),
  summary: z.string(),
});

type OutputType = z.infer<typeof outputSchema>;

/* ---------------- FLOW ---------------- */

const healthAnalysisFlow = ai.defineFlow(
  {
    name: "healthAnalysisFlow",
    inputSchema,
    outputSchema,
  },
  async (input): Promise<OutputType> => {
    try {
      const response = await ai.generate({
        prompt: `
Analyze this heart rate reading:

Heart Rate: ${input.heartRate} bpm

Rules:
- risk must be exactly one of: low, moderate, high
- explanation must be simple
- advice must be practical
- summary must be 1 short sentence
        `,
        output: {
          schema: outputSchema,
        },
      });

      if (!response.output) {
        return {
          risk: "moderate",
          explanation: "AI could not analyze the data.",
          advice: "Please try again later.",
          summary: "Analysis unavailable.",
        };
      }

      return response.output;
    } catch (error) {
      console.error("AI ERROR:", error);

      return {
        risk: "moderate",
        explanation: "AI service temporarily unavailable.",
        advice: "Retry shortly.",
        summary: "Temporary issue.",
      };
    }
  },
);

/* ---------------- EXPORT FUNCTION ---------------- */

export const healthAnalysis = onCallGenkit(
  {
    secrets: [googleApiKey],
  },
  healthAnalysisFlow,
);

/* ---------------- HEART RATE LOG (DATASTORE MODE) ---------------- */

const saveHeartRateInputSchema = z.object({
  heartRate: z.number().int().positive(),
  spo2: z.number().int().min(0).max(100).optional(),
  steps: z.number().int().min(0).optional(),
});

export const saveHeartRateLog = onCall(async (request) => {
  if (!request.auth?.uid) {
    throw new HttpsError("unauthenticated", "Sign in required.");
  }

  const parsed = saveHeartRateInputSchema.safeParse(request.data);
  if (!parsed.success) {
    throw new HttpsError("invalid-argument", "Invalid payload.");
  }

  const { heartRate, spo2, steps } = parsed.data;
  const uid = request.auth.uid;

  const key = datastore.key(["heart_rate_logs"]);
  await datastore.save({
    key,
    data: {
      uid,
      heartRate,
      spo2: spo2 ?? null,
      steps: steps ?? null,
      createdAt: new Date().toISOString(),
    },
  });

  return { ok: true };
});

/* ---------------- USER PROFILE (DATASTORE MODE) ---------------- */

const emergencyContactSchema = z.object({
  name: z.string().min(1),
  phone: z.string().min(1),
});

const profileSchema = z.object({
  fullName: z.string().optional(),
  age: z.string().optional(),
  gender: z.string().optional(),
  height: z.string().optional(),
  weight: z.string().optional(),

  medicalConditions: z.string().optional(),
  lifestyle: z.string().optional(),

  emergencyContacts: z.array(emergencyContactSchema).optional(),
  autoNotify: z.boolean().optional(),

  connectedDevice: z.string().optional(),
  isConnected: z.boolean().optional(),

  heartRateThreshold: z.string().optional(),
  notificationToggle: z.boolean().optional(),

  aiSensitivity: z.string().optional(),

  targetHRRange: z.string().optional(),
  fitnessGoal: z.string().optional(),

  dataSharingToggle: z.boolean().optional(),
});

const defaultProfile = {
  fullName: "John Doe",
  age: "28",
  gender: "Male",
  height: "5'10\"",
  weight: "75 kg",

  medicalConditions: "None",
  lifestyle: "Active",

  emergencyContacts: [{ name: "Mom", phone: "+1-234-567-8900" }],
  autoNotify: true,

  connectedDevice: "Smartwatch",
  isConnected: true,

  heartRateThreshold: "120",
  notificationToggle: true,

  aiSensitivity: "Medium",

  targetHRRange: "60-100",
  fitnessGoal: "Improve stamina",

  dataSharingToggle: true,
};

export const getUserProfile = onCall(async (request) => {
  if (!request.auth?.uid) {
    throw new HttpsError("unauthenticated", "Sign in required.");
  }

  const uid = request.auth.uid;
  const key = datastore.key(["user_profiles", uid]);

  const [entity] = await datastore.get(key);
  const data = (entity ?? {}) as Record<string, unknown>;

  return {
    ok: true,
    profile: {
      ...defaultProfile,
      ...data,
    },
  };
});

export const updateUserProfile = onCall(async (request) => {
  if (!request.auth?.uid) {
    throw new HttpsError("unauthenticated", "Sign in required.");
  }

  const parsed = profileSchema.safeParse(request.data);
  if (!parsed.success) {
    throw new HttpsError("invalid-argument", "Invalid payload.");
  }

  const uid = request.auth.uid;
  const key = datastore.key(["user_profiles", uid]);

  const [existing] = await datastore.get(key);
  const existingData = (existing ?? {}) as Record<string, unknown>;

  const merged = {
    ...defaultProfile,
    ...existingData,
    ...parsed.data,
    uid,
    updatedAt: new Date().toISOString(),
  };

  await datastore.save({ key, data: merged });

  return { ok: true, profile: merged };
});
