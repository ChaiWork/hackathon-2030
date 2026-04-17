import { genkit, z } from "genkit";
import { googleAI } from "@genkit-ai/google-genai";
import { onCallGenkit } from "firebase-functions/https";
import { defineSecret } from "firebase-functions/params";

/* ---------------- SECRET ---------------- */

const googleApiKey = defineSecret("GOOGLE_GENAI_API_KEY");

/* ---------------- AI SETUP ---------------- */

const ai = genkit({
  plugins: [googleAI()],
  model: "googleai/gemini-2.5-flash",
});

/* ---------------- SCHEMAS ---------------- */

const inputSchema = z.object({
  systolic: z.number(),
  diastolic: z.number(),
  heartRate: z.number(),
  glucose: z.number(),
  spo2: z.number(),
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
Analyze the following health metrics:

Blood Pressure: ${input.systolic}/${input.diastolic} mmHg  
Heart Rate: ${input.heartRate} bpm  
Glucose: ${input.glucose} mg/dL  
SpO2: ${input.spo2}%  

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
  }
);

/* ---------------- EXPORT FUNCTION ---------------- */

export const healthAnalysis = onCallGenkit(
  {
    secrets: [googleApiKey],
  },
  healthAnalysisFlow
);