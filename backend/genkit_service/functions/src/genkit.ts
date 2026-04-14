import { genkit } from "genkit";
import { googleAI } from "@genkit-ai/google-genai";
import { defineSecret } from "firebase-functions/params";
import dotenv from "dotenv";

dotenv.config();

const googleApiKey = defineSecret("GOOGLE_API_KEY");

// ✅ Try local first, then fallback to Firebase secret
const apiKey = process.env.GOOGLE_API_KEY || googleApiKey.value();

// ❗ Only warn (don't crash Genkit UI)
if (!apiKey) {
  console.warn("⚠️ GOOGLE_API_KEY not found (local or secret)");
}

export const ai = genkit({
  plugins: [
    googleAI({
      apiKey: apiKey || "", // prevent crash
    }),
  ],
  model: "googleai/gemini-2.5-flash",
});
