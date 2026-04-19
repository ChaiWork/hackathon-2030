import * as admin from "firebase-admin";
import { genkit } from "genkit";
import { z } from "zod";
import { googleAI } from "@genkit-ai/google-genai";
import { onCallGenkit } from "firebase-functions/https";
import { defineSecret } from "firebase-functions/params";
import { onDocumentCreated } from "firebase-functions/v2/firestore";

admin.initializeApp();

/* ---------------- SECRET ---------------- */

const googleApiKey = defineSecret("GOOGLE_GENAI_API_KEY");

/* ---------------- GENKIT SETUP ---------------- */

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

type InputType = z.infer<typeof inputSchema>;
type OutputType = z.infer<typeof outputSchema>;

/* ---------------- AI FLOW ---------------- */

const healthAnalysisFlow = ai.defineFlow(
  {
    name: "healthAnalysisFlow",
    inputSchema,
    outputSchema,
  },
  async (input: InputType): Promise<OutputType> => {
    try {
      const response = await ai.generate({
        prompt: `
Analyze this heart rate reading:

Heart Rate: ${input.heartRate} bpm

Rules:
- risk must be low, moderate, or high
- explanation must be simple
- advice must be practical
- summary must be 1 short sentence
        `,
        output: {
          schema: outputSchema,
        },
      });

      return (
        response.output || {
          risk: "moderate",
          explanation: "No AI output.",
          advice: "Try again.",
          summary: "No result.",
        }
      );
    } catch (error) {
      console.error("AI ERROR:", error);

      return {
        risk: "moderate",
        explanation: "AI error.",
        advice: "Retry later.",
        summary: "Temporary issue.",
      };
    }
  },
);

/* ---------------- GENKIT EXPORT ---------------- */

export const healthAnalysis = onCallGenkit(
  {
    secrets: [googleApiKey],
  },
  healthAnalysisFlow,
);

/* ---------------- FIRESTORE → FCM ---------------- */

export const sendPushNotification = onDocumentCreated(
  "users/{userId}/notifications/{notificationId}",
  async (event): Promise<void> => {
    const snapshot = event.data;
    const userId = event.params.userId;

    // MUST handle missing snapshot safely
    if (!snapshot) {
      console.log("No snapshot found");
      return;
    }

    const notification = snapshot.data();

    const userDoc = await admin
      .firestore()
      .collection("users")
      .doc(userId)
      .get();

    if (!userDoc.exists) {
      console.log("User not found");
      return;
    }

    const fcmToken = userDoc.data()?.fcmToken;

    if (!fcmToken) {
      console.log("No FCM token");
      return;
    }

    const isEmergency = notification?.type === "emergency";

    const priority: "high" | "normal" = isEmergency ? "high" : "normal";

    const message = {
      token: fcmToken,
      notification: {
        title: notification?.title || "Alert",
        body: notification?.message || "New notification",
      },
      data: {
        type: notification?.type || "info",
        notificationId: event.params.notificationId,
      },
      android: {
        priority,
        notification: {
          channelId: isEmergency ? "emergency_alerts" : "general_alerts",
          sound: isEmergency ? "emergency_siren" : "default",
        },
      },
    };

    try {
      const response = await admin.messaging().send(message);
      console.log("Push sent:", response);
      return;
    } catch (error) {
      console.error("Push error:", error);

      const err = error as any;

      if (err?.code === "messaging/registration-token-not-registered") {
        await admin.firestore().collection("users").doc(userId).update({
          fcmToken: admin.firestore.FieldValue.delete(),
        });
      }

      return;
    }
  },
);
