
// const outputSchema = z.object({
//   risk: z.enum(["low", "moderate", "high"]),
//   explanation: z.string(),
//   advice: z.string(),
//   summary: z.string(),
// });

// type OutputType = z.infer<typeof outputSchema>;

// export const healthAnalysisFlow = ai.defineFlow(
//   {
//     name: "healthAnalysisFlow",
//     inputSchema: z.object({
//       systolic: z.number(),
//       diastolic: z.number(),
//       heartRate: z.number(),
//       glucose: z.number(),
//       spo2: z.number(),
//     }),
//     outputSchema,
//   },
//   async (input): Promise<OutputType> => {
//     try {
//       const response = await ai.generate({
//         prompt: `
// Analyze the following health metrics:

// Blood Pressure: ${input.systolic}/${input.diastolic} mmHg  
// Heart Rate: ${input.heartRate} bpm  
// Glucose: ${input.glucose} mg/dL  
// SpO2: ${input.spo2}%  

// Rules:
// - risk must be one of: low, moderate, high
// - Keep explanation simple
// - Give practical advice
// - Summary must be 1 short sentence
//         `,
//         output: { schema: outputSchema },
//       });

//       const output = response.output;

//       if (!output) {
//         return {
//           risk: "moderate",
//           explanation: "AI could not analyze the health data.",
//           advice: "Please try again or consult a healthcare professional.",
//           summary: "Analysis unavailable.",
//         };
//       }

//       return output;
//     } catch (error) {
//       console.error("AI Error:", error);

//       return {
//         risk: "moderate",
//         explanation: "System error occurred during analysis.",
//         advice: "Retry later or consult a doctor if symptoms persist.",
//         summary: "System error during analysis.",
//       };
//     }
//   },
// );
