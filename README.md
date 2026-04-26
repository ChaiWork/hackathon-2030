# VitaLife Assistant  (Hackathon 2030)

## Executive Summary

**VitalIfe** is a multi-platform health assistant prototype designed to support accessible health monitoring, intelligent risk analysis, and chronic disease prediction through an integrated mobile and web ecosystem.

VitalIfe combines:

* **Mobile Assistant (Flutter APK)**
  Captures and visualizes health data, authenticates users, syncs wearable health metrics, and requests AI-driven health insights.

* **AI Backend (Firebase Functions + Genkit + Gemini)**
  Processes health readings using structured AI pipelines and returns health risk classifications, chronic clinical intelligence, predictions, and personalized advice.

* **Web Dashboard (Vite + React)**
  Allows users and caregivers to manually log health data, monitor trends, and view AI-generated health insights and predictions.

Core goals:

* Deliver **fast, low-friction health insights** for users and caregivers.
* Support both **manual health logging** and **automatic smartwatch integration**.
* Provide **secure-by-default architecture** where secrets are never committed.
* Keep AI pipelines **deterministic, structured, and testable** using typed outputs.

---

## 🌳 Branching Workflow

* **Main branch (`main`)**: stable, demo-ready branch

  * Only reviewed feature branches are merged here.

* **Feature branches** (e.g. `sos`, `ai-flow`, `dashboard`, `wearable-sync`)

  * Used for active development
  * Frequently sync `main` → feature branch
  * Merge back into `main` after testing and review

---

## Repository Structure

```text
vitalife-health-dashboard/       # Vite + React dashboard
backend/genkit_service/          # Firebase Functions project wrapper
backend/genkit_service/functions # Firebase Functions (TypeScript) + Genkit AI logic
vitalife_asistant/               # Flutter mobile app (APK)
vitalife_asistant/functions      # Firebase Functions (Node) for notifications/SOS
```

---

## System Architecture

VitalIfe supports both **manual health logging** and **wearable device synchronization**.

### 1. Manual Health Logging Flow

Users can manually input health data through the web dashboard:

* Heart Rate
* Blood Oxygen (SpO₂)
* BMI
* Blood Pressure
* Blood Glucose

Once submitted, the system automatically runs:

1. **Health Intelligence**
2. **Chronic Clinical Intelligence**
3. **Advice Generation**
4. **Prediction Engine**

Flow:

```text
Manual Website Input
→ Save Health Record
→ Run Health Intelligence
→ Run Chronic Clinical Intelligence
→ Generate Advice
→ Generate Prediction
→ Display Full Analysis
```

---

### 2. Smartwatch Integration Flow

VitalIfe also supports smartwatch integration through Android health services.

Required apps:

* **Health Connect**
* **Google Fit**
* **Smartwatch App** (e.g. COROS)
* **VitaLife APK**

Wearable sync flow:

```text
Smartwatch
→ COROS App
→ Google Fit
→ Health Connect
→ VitaLife APK
→ Firebase / Dashboard
```

This allows VitaLife to retrieve wearable data such as:

* Heart Rate
* Steps
* Calories
* Sleep
* Activity Sessions

---

## Installation & Setup

### Requirements

* **Node.js 24+**
* **npm**
* **Firebase CLI** (`npm i -g firebase-tools`)
* **Flutter SDK**

### Clone Repository

```bash
git clone <YOUR_GITHUB_REPO_URL>
cd <YOUR_REPO_FOLDER>
```

---

## ⚙️ Secrets & Configuration

> [!IMPORTANT]
> **Never commit real keys to GitHub.**
> This repository uses `.env` files and Firebase **Functions secrets**.

---

### A) Web Dashboard Environment

Create local environment file:

```bash
cd vitalife-health-dashboard
Copy-Item .env.example .env.local
```

Set:

* `GEMINI_API_KEY` = Gemini API key (Google AI Studio)
* `APP_URL` = optional local URL (`http://localhost:3000`)

---

### B) Backend Secret (Firebase Functions)

The Genkit backend uses Firebase Functions secrets.

Set secret:

```bash
cd backend/genkit_service/functions
firebase functions:secrets:set GOOGLE_GENAI_API_KEY
```

Secret name:

* `GOOGLE_GENAI_API_KEY`

After setting, restart emulator or redeploy.

---

### C) Flutter Environment

```bash
cd vitalife_asistant
Copy-Item .env.example .env
```

Optional local variable:

* `GEMINI_API_KEY`

If omitted, Flutter will use backend callable instead.

---

## Run Locally

### 1) Web Dashboard (Vite + React)

```bash
cd vitalife-health-dashboard
npm install
npm run dev
```

Open:

* `http://localhost:3000`

---

### 2) Genkit AI Backend (Firebase Functions)

Runs the callable AI endpoint:

* **Function**: `healthAnalysis`

Example structured input:

```json
{
  "heartRate": 88,
  "bloodOxygen": 97,
  "bmi": 26.1,
  "bloodPressure": "135/88",
  "bloodGlucose": 7.2
}
```

Example structured output:

```json
{
  "risk": "moderate",
  "explanation": "Elevated blood pressure and BMI indicate moderate cardiovascular risk.",
  "advice": "Monitor blood pressure regularly, reduce sodium intake, and increase physical activity.",
  "summary": "Moderate chronic risk detected with early hypertension trend."
}
```

Run locally:

```bash
cd backend/genkit_service/functions
npm install
firebase emulators:start --only functions
```

Optional Genkit UI:

```bash
npm run genkit:ui
```

---

### 3) Flutter Mobile Assistant

```bash
cd vitalife_asistant
flutter pub get
flutter run
```

The Flutter app:

* syncs smartwatch data
* displays health metrics
* sends health data to backend
* receives AI-generated advice and predictions

---

## Deployment

### Deploy AI Backend

```bash
cd backend/genkit_service/functions
npm install
npm run build
firebase deploy --only functions
```

### Deploy Notification / SOS Backend

```bash
cd vitalife_asistant/functions
npm install
firebase deploy --only functions
```

---

## Troubleshooting

* **Node issues** → ensure `node -v` is 24+
* **Firebase CLI missing** → install globally
* **Function errors**:

  * Run `firebase functions:log`
  * Confirm `GOOGLE_GENAI_API_KEY` exists
* **Flutter emulator connection issue**:

  * Prefer deployed backend for Windows testing
* **No smartwatch data**:

  * Check Health Connect permissions
  * Check Google Fit sync
  * Check smartwatch app permissions

---

## Security Notes

* `.env` files are ignored
* only `.env.example` is committed
* Firebase client config is public-safe but project-specific
* real secrets must remain in Firebase Functions secrets
* no production API keys should be committed to GitHub

---

## AI Usage & Development Assistance

AI tools were used to accelerate development, debugging, UI iteration, and architecture validation throughout this hackathon prototype.

### AI tools used

* OpenAI **ChatGPT**
  Used for:

  * debugging Flutter, Firebase, and TypeScript issues
  * architecture planning
  * prompt engineering
  * backend logic refinement
  * health rule validation
  * documentation drafting

* Google **Gemini**
  Used for:

  * structured health analysis generation
  * AI response prototyping
  * Genkit pipeline testing
  * health insight generation

* **Cursor AI**
  Used for:

  * code completion
  * rapid iteration
  * inline debugging

* **Claude AI**
  Used for:

  * code review
  * logic validation
  * prompt comparison
  * alternative implementation review

### AI usage policy

AI tools were used as **development assistants**, not autonomous authors.

All generated code, UI, prompts, and logic were:

* manually reviewed
* tested locally
* validated in runtime
* adjusted for project requirements
* verified before deployment

Final implementation, testing, debugging, and integration decisions were performed by the development team.

---

## License

This project is developed for hackathon and educational demonstration purposes.
