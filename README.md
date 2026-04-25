# VitalIfe (Hackathon 2030)

## Executive Summary

**VitalIfe** is a multi-app health assistant prototype that combines:

- **Mobile assistant (Flutter)**: captures/visualizes user health data, authenticates users, and requests AI insights.
- **AI backend (Firebase Functions + Genkit)**: exposes a callable function (`healthAnalysis`) that returns structured risk/advice using Gemini.
- **Web dashboard (Vite + React)**: a dashboard experience for viewing health metrics and AI-driven insights.

Core goals:

- Enable **fast, low-friction** health insights for users.
- Provide a **secure-by-default** setup where secrets are never committed.
- Keep backend logic **deterministic and testable**, with typed inputs/outputs for AI results.

---

## 🌳 Branching workflow

- **Main branch (`main`)**: stable, demo-ready.
  - Only merges from feature branches are allowed.
- **Feature branches (e.g. `sos`, `ai-flow`)**: active development.
  - Regularly merge `main` → your branch to stay updated.
  - Avoid merging feature branches into each other; merge back into `main`.

---

## Repository structure

```text
vitalife-health-dashboard/       # Vite + React dashboard
backend/genkit_service/          # Firebase Functions project wrapper
backend/genkit_service/functions # Firebase Functions (TypeScript) + Genkit
vitalife_asistant/               # Flutter mobile app
vitalife_asistant/functions      # Firebase Functions (Node) for notifications
```

---

## Installation & Setup

### Requirements

- **Node.js 24+** (Firebase Functions in this repo specify Node 24)
- **npm**
- **Firebase CLI** (`npm i -g firebase-tools`)
- **Flutter SDK** (for the mobile app)

### 1) Clone

```bash
git clone <YOUR_GITHUB_REPO_URL>
cd <YOUR_REPO_FOLDER>
```

---

## ⚙️ Secrets & configuration (required before first run)

> [!IMPORTANT]
> **Never commit real keys to GitHub.**
> This repo uses `.env` files and Firebase **Functions secrets**. Examples are included, real secrets are not.

### A) Web dashboard env (`vitalife-health-dashboard/.env.local`)

1. Create your local env file:

```bash
cd vitalife-health-dashboard
Copy-Item .env.example .env.local
```

2. Edit `vitalife-health-dashboard/.env.local`:

- `GEMINI_API_KEY`: Gemini API key (Google AI Studio)
- `APP_URL`: optional; for local use you can set `http://localhost:3000`

### B) Genkit backend secret (Firebase Functions secret)

The callable AI function uses **Firebase Functions secrets** (not `.env`) for server-side keys.

- **Secret name**: `GOOGLE_GENAI_API_KEY`

Set it on your Firebase project:

```bash
cd backend/genkit_service/functions
firebase functions:secrets:set GOOGLE_GENAI_API_KEY
```

> After setting secrets, restart emulators or redeploy functions.

### C) Flutter assistant env (`vitalife_asistant/.env`)

If you use `flutter_dotenv` locally, create:

```bash
cd vitalife_asistant
Copy-Item .env.example .env
```

Then set:

- `GEMINI_API_KEY` (if your Flutter build uses it directly; otherwise you can leave it unused and rely on the backend callable)

---

## Run locally

## 1) Web dashboard (Vite + React)

```bash
cd vitalife-health-dashboard
npm install
npm run dev
```

Open:

- `http://localhost:3000`

---

## 2) Genkit AI backend (Firebase Functions emulator)

This backend exposes a callable function named **`healthAnalysis`** with:

- **Input**: `{ heartRate: number }`
- **Output**: `{ risk: "low" | "moderate" | "high", explanation: string, advice: string, summary: string }`

Run locally:

```bash
cd backend/genkit_service/functions
npm install
firebase emulators:start --only functions
```

### Optional: Genkit UI

```bash
cd backend/genkit_service/functions
npm run genkit:ui
```

---

## 3) Flutter mobile assistant

```bash
cd vitalife_asistant
flutter pub get
flutter run
```

Backend connection note:

- The app calls the callable function **`healthAnalysis`** (see `vitalife_asistant/lib/services/gemini_genkit.dart`).
- Default region is `us-central1`. Make sure your deployed Functions match (or update the region in code).

---

## Deployment

### Deploy Genkit Functions (AI callable + push logic)

```bash
cd backend/genkit_service/functions
npm install
npm run build
firebase deploy --only functions
```

### Deploy Flutter Functions (notification trigger)

```bash
cd vitalife_asistant/functions
npm install
firebase deploy --only functions
```

---

## Troubleshooting

- **Node version issues**: verify `node -v` is 24+.
- **Firebase CLI missing**: install via `npm i -g firebase-tools`.
- **Callable function fails**:
  - Check logs: `firebase functions:log`
  - Confirm `GOOGLE_GENAI_API_KEY` secret is set.
- **Flutter can’t reach local emulators**:
  - Prefer testing against deployed Functions first on Windows.
  - Android emulator networking often requires emulator host mapping.

---

## Security notes (public repo readiness)

- `.env` files are ignored; only `*.env.example` are committed.
- Firebase client keys (e.g. those in `firebase_options.dart`) are **not secrets** by themselves, but still represent your project identity—use a dedicated hackathon project.
- Server-side API keys must live in **Firebase Functions secrets**.

---

## License

