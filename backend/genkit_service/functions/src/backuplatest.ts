

// // import * as admin from "firebase-admin";
// // import { genkit } from "genkit";
// // import { z } from "zod";
// // import { googleAI } from "@genkit-ai/google-genai";
// // import { onCall, HttpsError } from "firebase-functions/v2/https";
// // import { onDocumentCreated } from "firebase-functions/v2/firestore";
// // import { defineSecret } from "firebase-functions/params";

// // /* =========================================================
// //    INIT
// // ========================================================= */

// // if (!admin.apps.length) {
// //   admin.initializeApp();
// // }

// // const googleApiKey = defineSecret("GOOGLE_GENAI_API_KEY");

// // /* =========================================================
// //    GENKIT SETUP
// // ========================================================= */

// // const ai = genkit({
// //   plugins: [googleAI()],
// //   model: "googleai/gemini-flash-latest",
// // });

// // /* =========================================================
// //    1. HEART RATE FLOW
// // ========================================================= */

// // const hrOutputSchema = z.object({
// //   risk: z.enum(["Low", "Moderate", "High", "Critical"]),
// //   explanation: z.string(),
// //   advice: z.string(),
// //   summary: z.string(),
// // });

// // const healthAnalysisFlow = ai.defineFlow(
// //   {
// //     name: "healthAnalysisFlow",
// //     inputSchema: z.object({ heartRate: z.number() }),
// //     outputSchema: hrOutputSchema,
// //   },
// //   async (input) => {
// //     const risk =
// //       input.heartRate > 130
// //         ? "Critical"
// //         : input.heartRate > 100
// //           ? "High"
// //           : input.heartRate > 90
// //             ? "Moderate"
// //             : "Low";

// //     const response = await ai.generate({
// //       prompt: `
// // Analyze heart rate: ${input.heartRate} bpm.
// // Risk level: ${risk}

// // Return JSON:
// // - risk
// // - explanation (2 sentences)
// // - advice (1 sentence)
// // - summary (1 sentence)
// //       `,
// //     });

// //     return response.output!;
// //   },
// // );

// // /* =========================================================
// //    2. CHRONIC FLOW (RAG)
// // ========================================================= */

// // const chronicOutputSchema = z.object({
// //   risk: z.enum(["Low", "Moderate", "High", "Critical"]),
// //   summary: z.string(),
// //   advice: z.string(),
// // });

// // const chronicAnalysisFlow = ai.defineFlow(
// //   {
// //     name: "chronicAnalysisFlow",
// //     inputSchema: z.object({
// //       userId: z.string(),
// //       heartRate: z.number().optional(),
// //       systolic: z.number().optional(),
// //       diastolic: z.number().optional(),
// //       glucose: z.number().optional(),
// //       spo2: z.number().optional(),
// //     }),
// //     outputSchema: chronicOutputSchema,
// //   },
// //   async (input) => {
// //     const [hSnap, cSnap] = await Promise.all([
// //       admin
// //         .firestore()
// //         .collection("users")
// //         .doc(input.userId)
// //         .collection("heart_rate_logs")
// //         .orderBy("createdAt", "desc")
// //         .limit(10)
// //         .get(),

// //       admin
// //         .firestore()
// //         .collection("users")
// //         .doc(input.userId)
// //         .collection("chronicVital_log")
// //         .orderBy("createdAt", "desc")
// //         .limit(10)
// //         .get(),
// //     ]);

// //     const history = {
// //       hr: hSnap.docs.map((d) => d.data()),
// //       vitals: cSnap.docs.map((d) => d.data()),
// //     };

// //     const response = await ai.generate({
// //       model: "googleai/gemini-flash-latest",
// //       prompt: `
// // Analyze patient health data.

// // CURRENT:
// // ${JSON.stringify(input)}

// // HISTORY:
// // ${JSON.stringify(history).slice(0, 2000)}

// // Return:
// // - risk (Low/Moderate/High/Critical)
// // - summary (max 12 words)
// // - advice (clear medical instruction)
// //       `,
// //     });

// //     return response.output!;
// //   },
// // );

// // /* =========================================================
// //    3. GRAPH TREND FLOW
// // ========================================================= */

// // const graphAnalysisFlow = ai.defineFlow(
// //   {
// //     name: "graphAnalysisFlow",
// //     inputSchema: z.object({
// //       userId: z.string(),
// //       view: z.string(),
// //       metric: z.string(),
// //       data: z.array(z.any()),
// //     }),
// //     outputSchema: z.object({
// //       summary: z.string(),
// //       stability: z.number(),
// //       trends: z.array(
// //         z.object({
// //           label: z.string(),
// //           change: z.number(),
// //           trend: z.enum(["up", "down", "stable"]),
// //         }),
// //       ),
// //     }),
// //   },
// //   async (input) => {
// //     const result = await ai.generate({
// //       model: "googleai/gemini-flash-latest",

// //       // 👇 THIS is the fix
// //       output: {
// //         schema: z.object({
// //           summary: z.string(),
// //           stability: z.number(),
// //           trends: z.array(
// //             z.object({
// //               label: z.string(),
// //               change: z.number(),
// //               trend: z.enum(["up", "down", "stable"]),
// //             }),
// //           ),
// //         }),
// //       },

// //       prompt: `
// // Analyze ${input.metric} trends for ${input.view} view.

// // DATA:
// // ${JSON.stringify(input.data).slice(0, 2000)}

// // Rules:
// // - Return ONLY valid JSON
// // - No markdown
// // - No explanation
// // - All fields must be present
// //       `,
// //     });

// //     if (!result.output) {
// //       throw new Error("AI returned empty output");
// //     }

// //     return result.output;
// //   },
// // );

// // /* =========================================================
// //    4. CALLABLE FUNCTIONS
// // ========================================================= */

// // export const healthAnalysis = onCall(
// //   { secrets: [googleApiKey], cors: true },
// //   async (request) => {
// //     if (!request.auth)
// //       throw new HttpsError("unauthenticated", "User must be signed in.");

// //     return await healthAnalysisFlow(request.data);
// //   },
// // );

// // export const chronicAnalysis = onCall(
// //   { secrets: [googleApiKey], cors: true },
// //   async (request) => {
// //     if (!request.auth)
// //       throw new HttpsError("unauthenticated", "User must be signed in.");

// //     return await chronicAnalysisFlow({
// //       ...request.data,
// //       userId: request.auth.uid,
// //     });
// //   },
// // );

// // export const graphAnalysis = onCall(
// //   { secrets: [googleApiKey], cors: true },
// //   async (request) => {
// //     if (!request.auth)
// //       throw new HttpsError("unauthenticated", "User must be signed in.");

// //     return await graphAnalysisFlow({
// //       ...request.data,
// //       userId: request.auth.uid,
// //     });
// //   },
// // );

// // /* =========================================================
// //    5. PUSH NOTIFICATION TRIGGER
// // ========================================================= */

// // export const sendPushNotification = onDocumentCreated(
// //   {
// //     document: "users/{userId}/notifications/{notificationId}",
// //     region: "us-central1",
// //   },
// //   async (event) => {
// //     const snap = event.data;
// //     if (!snap) return;

// //     const data = snap.data();
// //     const userId = event.params.userId;

// //     const userDoc = await admin.firestore().doc(`users/${userId}`).get();
// //     const token = userDoc.data()?.fcmToken;

// //     if (!token) return;

// //     const isEmergency = data?.type === "emergency";

// //     try {
// //       await admin.messaging().send({
// //         token,
// //         notification: {
// //           title: data?.title || "Health Alert",
// //           body: data?.message || "New health update received.",
// //         },
// //         android: {
// //           priority: isEmergency ? "high" : "normal",
// //           notification: {
// //             channelId: isEmergency ? "emergency_alerts" : "general_alerts",
// //           },
// //         },
// //       });
// //     } catch (e) {
// //       console.error("FCM Send Failed:", e);
// //     }
// //   },
// // );



// import * as admin from "firebase-admin";
// import { genkit } from "genkit";
// import { z } from "zod";
// import { googleAI } from "@genkit-ai/google-genai";
// import { onCall, HttpsError } from "firebase-functions/v2/https";
// import { onDocumentCreated } from "firebase-functions/v2/firestore";
// import { defineSecret } from "firebase-functions/params";

// /* =========================================================
//    INIT
// ========================================================= */

// if (!admin.apps.length) {
//   admin.initializeApp();
// }

// const googleApiKey = defineSecret("GOOGLE_GENAI_API_KEY");

// /* =========================================================
//    GENKIT SETUP
// ========================================================= */

// const ai = genkit({
//   plugins: [
//     googleAI({
//       apiKey: process.env.GOOGLE_GENAI_API_KEY,
//     }),
//   ],
//   model: "googleai/gemini-2.5-flash-lite",
// });

// /* =========================================================
//    FALLBACK LOGIC
// ========================================================= */

// function fallbackHealthAnalysis(input: { heartRate: number }) {
//   const hr = input.heartRate || 72;

//   const risk: "Low" | "Moderate" | "High" | "Critical" =
//     hr > 130 ? "Critical" : hr > 100 ? "High" : hr > 90 ? "Moderate" : "Low";

//   return {
//     risk,
//     explanation: `Heart rate of ${hr} bpm evaluated using fallback logic.`,
//     summary: `Heart rate indicates ${risk.toLowerCase()} risk level.`,
//     advice:
//       "Rest and hydrate. Monitor regularly. Seek medical attention if needed.",
//   };
// }

// function fallbackChronicAnalysis(input: any) {
//   const sys = input.systolic || 120;
//   const glu = input.glucose || 95;

//   let risk: "Low" | "Moderate" | "High" | "Critical" = "Low";

//   if (sys > 180 || glu > 300) risk = "Critical";
//   else if (sys > 140 || glu > 140) risk = "High";
//   else if (sys > 130 || glu > 110) risk = "Moderate";

//   return {
//     risk,
//     summary: `Fallback evaluation (BP: ${sys}, Glucose: ${glu}).`,
//     advice: `Current readings suggest ${risk.toLowerCase()} risk.`,
//   };
// }

// function fallbackGraphAnalysis() {
//   return {
//     summary: "Trend analysis unavailable, using fallback.",
//     stability: 85,
//     trends: [
//       {
//         label: "Overall",
//         change: 0,
//         trend: "stable" as const, // ✅ important
//       },
//     ],
//   };
// }

// /* =========================================================
//    1. HEART RATE FLOW
// ========================================================= */

// const hrOutputSchema = z.object({
//   risk: z.enum(["Low", "Moderate", "High", "Critical"]),
//   explanation: z.string(),
//   advice: z.string(),
//   summary: z.string(),
// });

// const healthAnalysisFlow = ai.defineFlow(
//   {
//     name: "healthAnalysisFlow",
//     inputSchema: z.object({ heartRate: z.number() }),
//     outputSchema: hrOutputSchema,
//   },
//   async (input) => {
//     try {
//       const risk =
//         input.heartRate > 130
//           ? "Critical"
//           : input.heartRate > 100
//             ? "High"
//             : input.heartRate > 90
//               ? "Moderate"
//               : "Low";

//       const response = await ai.generate({
//         model: "googleai/gemini-2.5-flash-lite",
//         output: { schema: hrOutputSchema },
//         prompt: `
// You are an advanced medical AI assistant.

// Heart Rate: ${input.heartRate}
// Risk: ${risk}

// Provide safe structured output.
//         `,
//       });

//       if (!response.output) throw new Error("AI returned null");

//       return response.output;
//     } catch (err) {
//       console.error("Health AI failed:", err);
//       return fallbackHealthAnalysis(input);
//     }
//   },
// );

// /* =========================================================
//    2. CHRONIC FLOW
// ========================================================= */

// const chronicOutputSchema = z.object({
//   risk: z.enum(["Low", "Moderate", "High", "Critical"]),
//   summary: z.string(),
//   advice: z.string(),
// });

// const chronicAnalysisFlow = ai.defineFlow(
//   {
//     name: "chronicAnalysisFlow",
//     inputSchema: z.object({
//       userId: z.string(),
//       heartRate: z.number().optional(),
//       systolic: z.number().optional(),
//       diastolic: z.number().optional(),
//       glucose: z.number().optional(),
//       spo2: z.number().optional(),
//     }),
//     outputSchema: chronicOutputSchema,
//   },
//   async (input) => {
//     try {
//       const [hSnap, cSnap] = await Promise.all([
//         admin
//           .firestore()
//           .collection("users")
//           .doc(input.userId)
//           .collection("heart_rate_logs")
//           .orderBy("createdAt", "desc")
//           .limit(10)
//           .get(),

//         admin
//           .firestore()
//           .collection("users")
//           .doc(input.userId)
//           .collection("chronicVital_log")
//           .orderBy("createdAt", "desc")
//           .limit(10)
//           .get(),
//       ]);

//       const history = {
//         hr: hSnap.docs.map((d) => d.data()),
//         vitals: cSnap.docs.map((d) => d.data()),
//       };

//       const response = await ai.generate({
//         model: "googleai/gemini-2.5-flash-lite",
//         output: { schema: chronicOutputSchema },
//         prompt: `
// Analyze patient chronic data safely.

// Current:
// ${JSON.stringify(input)}

// History:
// ${JSON.stringify(history).slice(0, 2000)}
//         `,
//       });

//       if (!response.output) throw new Error("AI returned null");

//       return response.output;
//     } catch (err) {
//       console.error("Chronic AI failed:", err);
//       return fallbackChronicAnalysis(input);
//     }
//   },
// );

// /* =========================================================
//    3. GRAPH FLOW
// ========================================================= */

// const graphOutputSchema = z.object({
//   summary: z.string(),
//   stability: z.number(),
//   trends: z.array(
//     z.object({
//       label: z.string(),
//       change: z.number(),
//       trend: z.enum(["up", "down", "stable"]),
//     }),
//   ),
// });

// const graphAnalysisFlow = ai.defineFlow(
//   {
//     name: "graphAnalysisFlow",
//     inputSchema: z.object({
//       userId: z.string(),
//       view: z.string(),
//       metric: z.string(),
//       data: z.array(z.any()),
//     }),
//     outputSchema: graphOutputSchema,
//   },
//   async (input) => {
//     try {
//       const result = await ai.generate({
//         model: "googleai/gemini-2.5-flash-lite",
//         output: { schema: graphOutputSchema },
//         prompt: `
// Analyze trends.

// Metric: ${input.metric}
// Data: ${JSON.stringify(input.data).slice(0, 2000)}
//         `,
//       });

//       if (!result.output) throw new Error("AI returned null");

//       return result.output;
//     } catch (err) {
//       console.error("Graph AI failed:", err);
//       return fallbackGraphAnalysis();
//     }
//   },
// );

// /* =========================================================
//    CALLABLE FUNCTIONS
// ========================================================= */

// export const healthAnalysis = onCall(
//   { secrets: [googleApiKey], cors: true },
//   async (req) => {
//     if (!req.auth) throw new HttpsError("unauthenticated", "Login required");
//     return healthAnalysisFlow(req.data);
//   },
// );

// export const chronicAnalysis = onCall(
//   { secrets: [googleApiKey], cors: true },
//   async (req) => {
//     if (!req.auth) throw new HttpsError("unauthenticated", "Login required");
//     return chronicAnalysisFlow({
//       ...req.data,
//       userId: req.auth.uid,
//     });
//   },
// );

// export const graphAnalysis = onCall(
//   { secrets: [googleApiKey], cors: true },
//   async (req) => {
//     if (!req.auth) throw new HttpsError("unauthenticated", "Login required");
//     return graphAnalysisFlow({
//       ...req.data,
//       userId: req.auth.uid,
//     });
//   },
// );

// /* =========================================================
//    PUSH NOTIFICATION
// ========================================================= */

// export const sendPushNotification = onDocumentCreated(
//   {
//     document: "users/{userId}/notifications/{notificationId}",
//     region: "us-central1",
//   },
//   async (event) => {
//     const snap = event.data;
//     if (!snap) return;

//     const data = snap.data();
//     const userId = event.params.userId;

//     const userDoc = await admin.firestore().doc(`users/${userId}`).get();
//     const token = userDoc.data()?.fcmToken;

//     if (!token) return;

//     const isEmergency = data?.type === "emergency";

//     try {
//       await admin.messaging().send({
//         token,
//         notification: {
//           title: data?.title || "Health Alert",
//           body: data?.message || "New update received",
//         },
//         android: {
//           priority: isEmergency ? "high" : "normal",
//           notification: {
//             channelId: isEmergency ? "emergency_alerts" : "general_alerts",
//           },
//         },
//       });
//     } catch (e) {
//       console.error("FCM error:", e);
//     }
//   },
// );
