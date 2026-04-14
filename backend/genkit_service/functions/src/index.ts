import { genkit, z } from "genkit";
import { googleAI } from "@genkit-ai/google-genai";
import { onCallGenkit } from "firebase-functions/https";
import { defineSecret } from "firebase-functions/params";

const apiKey = defineSecret("GOOGLE_GENAI_API_KEY");

/* ---------------- AI SETUP ---------------- */

const ai = genkit({
  plugins: [googleAI()],
});
/* ---------------- SCHEMAS ---------------- */

const outputSchema = z.object({
  risk: z.enum(["low", "moderate", "high"]),
  explanation: z.string(),
  advice: z.string(),
  summary: z.string(),
});

type OutputType = z.infer<typeof outputSchema>;

const inputSchema = z.object({
  systolic: z.number(),
  diastolic: z.number(),
  heartRate: z.number(),
  glucose: z.number(),
  spo2: z.number(),
});

/* ---------------- FLOW ---------------- */

export const healthAnalysisFlow = ai.defineFlow(
  {
    name: "healthAnalysisFlow",
    inputSchema,
    outputSchema,
  },
  async (input): Promise<OutputType> => {
    const response = await ai.generate({
      model: "googleai/gemini-2.5-flash",
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

    const output = response.output;

    /* ---------------- FIX #1: null safety ---------------- */
    if (!output) {
      return {
        risk: "moderate" as const,
        explanation: "AI could not analyze the health data.",
        advice: "Try again or consult a healthcare professional.",
        summary: "Analysis unavailable.",
      };
    }

    /* ---------------- FIX #2: strict enum type safety ---------------- */
    return {
      risk: output.risk as "low" | "moderate" | "high",
      explanation: output.explanation,
      advice: output.advice,
      summary: output.summary,
    };
  },
);

/* ---------------- EXPORT FUNCTION ---------------- */

export const healthAnalysis = onCallGenkit(
  {
    secrets: [apiKey],
  },
  healthAnalysisFlow,
);
