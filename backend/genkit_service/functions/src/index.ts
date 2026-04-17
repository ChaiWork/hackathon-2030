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
  }
);

/* ---------------- EXPORT FUNCTION ---------------- */

export const healthAnalysis = onCallGenkit(
  {
    secrets: [googleApiKey],
  },
  healthAnalysisFlow
);