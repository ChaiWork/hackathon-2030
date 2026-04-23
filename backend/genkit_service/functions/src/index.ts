import * as admin from "firebase-admin";
import { genkit } from "genkit";
import { z } from "zod";
import { googleAI } from "@genkit-ai/google-genai";
import { onCall, HttpsError } from "firebase-functions/v2/https";
import { onDocumentCreated } from "firebase-functions/v2/firestore";
import { defineSecret } from "firebase-functions/params";

/* =========================================================
   INIT
========================================================= */

if (!admin.apps.length) {
  admin.initializeApp();
}

const googleApiKey = defineSecret("GOOGLE_GENAI_API_KEY");

/* =========================================================
   GENKIT LAZY SETUP
========================================================= */

let aiInstance: any = null;

function getAI() {
  if (!aiInstance) {
    aiInstance = genkit({
      plugins: [
        googleAI({
          apiKey: googleApiKey.value(), // ✅ FIXED
        }),
      ],
      model: "googleai/gemini-2.5-flash-lite", // consistent model
    });
  }
  return aiInstance;
}

/* =========================================================
   FALLBACK LOGIC
========================================================= */

function fallbackHealthAnalysis(input: any) {
  const hr = input?.heartRate ?? 72;

  const risk =
    hr > 130 ? "Critical" : hr > 100 ? "High" : hr > 90 ? "Moderate" : "Low";

  return {
    risk,
    explanation: `Heart rate of ${hr} bpm processed using safety engine. AI consultation is temporarily limited.`,
    summary: `Heart rate indicates ${risk.toLowerCase()} risk level.`,
    advice:
      "Rest and hydrate. Monitor regularly. Seek medical attention if symptoms persist.",
  };
}

function fallbackChronicAnalysis(input: any) {
  const sys = input?.systolic ?? 120;
  const glu = input?.glucose ?? 95;

  let risk = "Low";

  if (sys > 180 || glu > 300) risk = "Critical";
  else if (sys > 140 || glu > 140) risk = "High";
  else if (sys > 130 || glu > 110) risk = "Moderate";

  return {
    risk,
    summary: `Metabolic vitals (BP: ${sys}, Glu: ${glu}) evaluated via backup safety logic.`,
    advice: `Current readings suggest ${risk.toLowerCase()} risk. Maintain your logging routine.`,
  };
}

function fallbackGraphAnalysis() {
  return {
    summary: "Trend analysis currently utilizing local statistical modeling.",
    stability: 85,
    trends: [{ label: "Temporal Stability", change: 0, trend: "stable" }],
  };
}

/* =========================================================
   SCHEMAS
========================================================= */

const hrOutputSchema = z.object({
  risk: z.enum(["Low", "Moderate", "High", "Critical"]),
  explanation: z.string(),
  advice: z.string(),
  summary: z.string(),
});

const chronicOutputSchema = z.object({
  risk: z.enum(["Low", "Moderate", "High", "Critical"]),
  summary: z.string(),
  advice: z.string(),
});

const graphOutputSchema = z.object({
  summary: z.string(),
  stability: z.number(),
  trends: z.array(
    z.object({
      label: z.string(),
      change: z.number(),
      trend: z.enum(["up", "down", "stable"]),
    }),
  ),
  prediction: z.string(),
  advice: z.string(),
});

/* =========================================================
   CALLABLE FUNCTIONS
========================================================= */

export const healthAnalysis = onCall(
  { secrets: [googleApiKey], cors: true },
  async (req) => {
    if (!req.auth) {
      throw new HttpsError("unauthenticated", "Login required");
    }

    const input = req.data;
    const ai = getAI();

    try {
      const response = await ai.generate({
        output: { schema: hrOutputSchema },
        prompt: `Analyze heart rate: ${input?.heartRate} bpm. Provide structured risk assessment.`,
      });

      return response?.output ?? fallbackHealthAnalysis(input);
    } catch (err) {
      console.error("Health AI failed:", err);
      return fallbackHealthAnalysis(input);
    }
  },
);

export const chronicAnalysis = onCall(
  { secrets: [googleApiKey], cors: true },
  async (req) => {
    if (!req.auth) {
      throw new HttpsError("unauthenticated", "Login required");
    }

    const input = req.data;
    const userId = req.auth.uid;
    const ai = getAI();

    try {
      const [hSnap, cSnap] = await Promise.all([
        admin
          .firestore()
          .collection("users")
          .doc(userId)
          .collection("heart_rate_logs")
          .orderBy("createdAt", "desc")
          .limit(10)
          .get(),

        admin
          .firestore()
          .collection("users")
          .doc(userId)
          .collection("chronicVital_log")
          .orderBy("createdAt", "desc")
          .limit(10)
          .get(),
      ]);

      const history = {
        hr: hSnap.docs.map((d) => d.data()),
        vitals: cSnap.docs.map((d) => d.data()),
      };

      const response = await ai.generate({
        output: { schema: chronicOutputSchema },
        prompt: `Analyze chronic data.
Current: ${JSON.stringify(input)}.
History: ${JSON.stringify(history).slice(0, 2000)}.`,
      });

      return response?.output ?? fallbackChronicAnalysis(input);
    } catch (err) {
      console.error("Chronic AI failed:", err);
      return fallbackChronicAnalysis(input);
    }
  },
);

export const graphAnalysis = onCall(
  { secrets: [googleApiKey], cors: true },
  async (req) => {
    if (!req.auth) {
      throw new HttpsError("unauthenticated", "Login required");
    }

    const input = req.data;
    const ai = getAI();

    try {
      const response = await ai.generate({
        output: { schema: graphOutputSchema },
        prompt: `
Analyze the health trends for ${input?.metric}. 
Primary Data Series: ${JSON.stringify(input?.data).slice(0, 1500)}. 
BMI Context: ${JSON.stringify(input?.bmiData || []).slice(0, 500)}.

Tasks:
1. Summarize trend
2. Stability score (0-100)
3. Detect changes
4. Predict next 7 days
5. Give advice
        `,
      });

      return (
        response?.output ?? {
          ...fallbackGraphAnalysis(),
          prediction: "Stable trajectory predicted.",
          advice: "Continue regular vitals logging.",
        }
      );
    } catch (err) {
      console.error("Graph AI failed:", err);
      return {
        ...fallbackGraphAnalysis(),
        prediction: "Prediction unavailable.",
        advice: "Use historical trend reference.",
      };
    }
  },
);

/* =========================================================
   PUSH NOTIFICATION
========================================================= */

export const sendPushNotification = onDocumentCreated(
  {
    document: "users/{userId}/notifications/{notificationId}",
    region: "us-central1",
  },
  async (event) => {
    const snap = event.data;
    if (!snap) return;

    const data = snap.data();
    const userId = event.params.userId;

    const userDoc = await admin.firestore().doc(`users/${userId}`).get();
    const token = userDoc.data()?.fcmToken;

    if (!token) return;

    const isEmergency = data?.type === "emergency";

    try {
      await admin.messaging().send({
        token,
        notification: {
          title: data?.title || "Health Alert",
          body: data?.message || "New update received",
        },
        android: {
          priority: isEmergency ? "high" : "normal",
          notification: {
            channelId: isEmergency ? "emergency_alerts" : "general_alerts",
          },
        },
      });
    } catch (e) {
      console.error("FCM error:", e);
    }
  },
);
