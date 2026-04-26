# VitaLife Genkit Backend Service

**AI-Powered Health Analytics Engine for Firebase Cloud Functions**

A sophisticated backend service built with Firebase Genkit and Google Gemini AI to provide real-time health analysis, chronic condition monitoring, and predictive health trends for the VitaLife health tracking platform.

**Deployed Region:** asia-southeast1 (Singapore)

---

## 🚀 Features

- **Real-Time Health Analysis**: Instant heart rate risk assessment using AI
- **Chronic Condition Monitoring**: Professional clinical analysis of vital signs with patient history context
- **Trend Prediction**: AI-powered 7-day health trend forecasting with stability scoring
- **Fallback Safety Logic**: Graceful degradation with pre-configured fallback responses when AI services are unavailable
- **Emergency Notifications**: Push notifications to mobile devices with priority routing
- **Schema Validation**: Zod-based output validation ensuring data integrity
- **Authentication-First**: All endpoints require Firebase authentication

---

## 🏗️ Architecture

### Technology Stack

- **Runtime**: Firebase Cloud Functions (Node.js 24)
- **AI Engine**: Google Genkit with Gemini 2.5 Flash Lite
- **Database**: Firestore (patient histories & logs)
- **Messaging**: Firebase Cloud Messaging (FCM)
- **Type Safety**: TypeScript + Zod validation

### Service Flow

```
Request (Auth Required)
    ↓
AI Instance Pool (Singleton)
    ↓
Genkit with Google AI Plugin
    ↓
Structured Output (Zod Validated)
    ↓
Response OR Fallback Logic
```

---

## 📋 Prerequisites

- Node.js 24.x or higher
- Firebase CLI installed globally
- Firebase project set up with Firestore & Cloud Functions
- Google Cloud project with Genkit enabled
- Google AI API key (Gemini)

---

## 🔧 Setup & Installation

### 1. Install Dependencies

```bash
cd backend/genkit_service
npm install

cd functions
npm install
```

### 2. Configure Environment Variables

Create a `.env` file in the `backend/genkit_service` directory:

```env
GOOGLE_GENAI_API_KEY=your_google_ai_api_key_here
FIREBASE_PROJECT_ID=your_firebase_project_id
```

**Important:** The `GOOGLE_GENAI_API_KEY` is also defined as a Firebase Secret (via `defineSecret`). Set it using Firebase CLI:

```bash
firebase functions:secrets:set GOOGLE_GENAI_API_KEY
```

### 3. Build the Project

```bash
cd functions
npm run build
```

### 4. Test Locally with Emulator

```bash
npm run serve
```

This starts the Firebase emulator suite on `http://localhost:4000`.

---

## 🌍 Environment Configuration

### Required Secrets

| Secret                 | Description                         |
| ---------------------- | ----------------------------------- |
| `GOOGLE_GENAI_API_KEY` | Google AI API key for Gemini access |

### Firebase Configuration

- **Region**: `asia-southeast1` (Singapore)
- **Runtime**: Node.js 24
- **CORS**: Enabled for all functions
- **Authentication**: Firebase Auth required

---

## 📡 API Functions

### 1. `healthAnalysis` (Callable Function)

Analyzes heart rate data and provides structured risk assessment.

**Endpoint**: `https://asia-southeast1-{project-id}.cloudfunctions.net/healthAnalysis`

**Request**:

```typescript
{
  heartRate: number; // BPM value to analyze
}
```

**Response** (Success):

```typescript
{
  risk: "Low" | "Moderate" | "High" | "Critical",
  explanation: string,
  advice: string,
  summary: string
}
```

**Risk Thresholds**:

- **Critical**: > 130 bpm
- **High**: 100-130 bpm
- **Moderate**: 90-100 bpm
- **Low**: < 90 bpm

**Fallback**: Returns pre-calculated response if AI unavailable.

---

### 2. `chronicAnalysis` (Callable Function)

Provides comprehensive clinical assessment of vital signs with historical context.

**Endpoint**: `https://asia-southeast1-{project-id}.cloudfunctions.net/chronicAnalysis`

**Request**:

```typescript
{
  systolic: number,      // Blood pressure (top number)
  diastolic?: number,    // Blood pressure (bottom number)
  glucose: number,       // Blood glucose level
  // Additional vitals as needed
}
```

**Response** (Success):

```typescript
{
  risk: "Low" | "Moderate" | "High" | "Critical",
  summary: string,                  // Brief status (max 15 words)
  clinicalSummary: string,          // Detailed clinical assessment
  futureRisks: string,              // Potential conditions/diseases
  advice: string,                   // Professional medical recommendations
  medications: string,              // General medication classes (AI-suggested, requires physician verification)
  prevention: string                // Actionable preventative measures
}
```

**Data Retrieved**:

- Last 10 heart rate logs
- Last 10 chronic vital logs
- Auto-contextualizes analysis with patient history

**Risk Thresholds**:

- **Critical**: Systolic > 180 OR Glucose > 300
- **High**: Systolic > 140 OR Glucose > 140
- **Moderate**: Systolic > 130 OR Glucose > 110
- **Low**: All others

---

### 3. `graphAnalysis` (Callable Function)

Analyzes health trends and predicts future patterns.

**Endpoint**: `https://asia-southeast1-{project-id}.cloudfunctions.net/graphAnalysis`

**Request**:

```typescript
{
  metric: string,              // e.g., "heart_rate", "blood_pressure"
  data: Array<{
    date: string,
    value: number
  }>,
  bmiData?: Array<any>         // Optional BMI context
}
```

**Response** (Success):

```typescript
{
  summary: string,             // Overall trend summary
  stability: number,           // 0-100 stability score
  trends: Array<{
    label: string,             // Metric name
    change: number,            // Percentage change
    trend: "up" | "down" | "stable"
  }>,
  prediction: string,          // 7-day trend forecast
  advice: string               // Recommended actions
}
```

**Analysis Includes**:

- Trend summarization
- Stability scoring
- Change detection
- 7-day predictions
- Contextual advice

---

### 4. `sendPushNotification` (Firestore Trigger)

Automatically sends push notifications when a notification document is created.

**Trigger**: Document creation at `users/{userId}/notifications/{notificationId}`

**Document Schema**:

```typescript
{
  type: "emergency" | "normal",
  title: string,
  message: string,
  createdAt: Timestamp
}
```

**Notification Routing**:

- **Emergency Alerts**: High priority, dedicated channel
- **General Alerts**: Normal priority, general channel

**Requirements**:

- User must have `fcmToken` in their user document
- FCM setup on Android device

---

## 🛡️ Fallback Safety Logic

All AI functions include robust fallback mechanisms:

### Health Analysis Fallback

```typescript
{
  risk: "Low|Moderate|High|Critical" (based on HR thresholds),
  explanation: "Heart rate processed using safety engine...",
  summary: "Heart rate indicates X risk level.",
  advice: "Rest and hydrate. Monitor regularly..."
}
```

### Chronic Analysis Fallback

```typescript
{
  risk: "Low|Moderate|High|Critical" (based on BP/glucose thresholds),
  summary: "Metabolic vitals evaluated via backup safety logic.",
  advice: "Current readings suggest X risk. Maintain logging routine."
}
```

### Graph Analysis Fallback

```typescript
{
  summary: "Trend analysis utilizing local statistical modeling.",
  stability: 85,
  trends: [{ label: "Temporal Stability", change: 0, trend: "stable" }],
  prediction: "Stable trajectory predicted.",
  advice: "Continue regular vitals logging."
}
```

**Triggers**:

- Network failures
- AI service unavailability
- API rate limiting
- Invalid API key

---

## 🔐 Authentication & Security

All callable functions require Firebase Authentication:

```typescript
if (!req.auth) {
  throw new HttpsError("unauthenticated", "Login required");
}
```

**User Context Available**:

- `req.auth.uid`: User ID
- `req.auth.email`: User email
- `req.auth.token`: Auth token

---

## 📦 Deployment

### Deploy to Firebase

```bash
# From backend/genkit_service/functions directory
npm run deploy
```

### Pre-deployment Checklist

- [ ] Set `GOOGLE_GENAI_API_KEY` secret in Firebase
- [ ] Configure Firebase project region (asia-southeast1)
- [ ] Verify Firestore database exists
- [ ] Enable Cloud Messaging API
- [ ] Test with `npm run serve` locally first

### Deploy Specific Function

```bash
firebase deploy --only functions:healthAnalysis
```

### View Logs

```bash
npm run logs
```

---

## 💻 Development

### Local Development with Genkit UI

```bash
npm run genkit:ui
```

Starts the Genkit development dashboard at `http://localhost:4000` with:

- AI request tracing
- Response inspection
- Latency monitoring
- Fallback tracking

### Build & Watch

```bash
npm run build:watch
```

### Interactive Shell

```bash
npm run shell
```

Provides Firebase functions shell for testing callable functions interactively.

---

## 📊 Firestore Collections Structure

```
users/
  {userId}/
    heart_rate_logs/
      {logId}
        - heartRate: number
        - createdAt: Timestamp
        - metadata: {...}

    chronicVital_log/
      {logId}
        - systolic: number
        - diastolic?: number
        - glucose: number
        - createdAt: Timestamp

    notifications/
      {notificationId}
        - type: "emergency" | "normal"
        - title: string
        - message: string
        - createdAt: Timestamp
```

---

## 🔍 Monitoring & Troubleshooting

### View Function Logs

```bash
firebase functions:log
```

### Common Issues

| Issue                            | Solution                                                  |
| -------------------------------- | --------------------------------------------------------- |
| `GOOGLE_GENAI_API_KEY` not found | Run `firebase functions:secrets:set GOOGLE_GENAI_API_KEY` |
| Authentication error             | Ensure user is logged in to Firebase Auth                 |
| AI response timeout              | Check Google API quota; fallback response will be used    |
| Notification not sending         | Verify FCM token exists in user document                  |
| Cold start latency               | AI instance is cached; subsequent calls are faster        |

### Debug Mode

Enable detailed logging by modifying functions:

```typescript
console.error("Function name:", err);
console.log("Request data:", input);
```

Check logs:

```bash
firebase functions:log --follow
```

---

## 📚 Zod Schemas Reference

All outputs are validated against these schemas:

### `hrOutputSchema`

```typescript
{
  risk: "Low" | "Moderate" | "High" | "Critical",
  explanation: string,
  advice: string,
  summary: string
}
```

### `chronicOutputSchema`

```typescript
{
  risk: "Low" | "Moderate" | "High" | "Critical",
  summary: string,
  advice: string,
  clinicalSummary: string,
  futureRisks: string,
  medications: string,
  prevention: string
}
```

### `graphOutputSchema`

```typescript
{
  summary: string,
  stability: number,
  trends: Array<{
    label: string,
    change: number,
    trend: "up" | "down" | "stable"
  }>,
  prediction: string,
  advice: string
}
```

---

## 🚀 Performance Optimization

- **AI Instance Pooling**: Genkit instance is cached and reused (singleton pattern)
- **Parallel Data Fetching**: Chronic analysis uses `Promise.all()` for concurrent Firestore queries
- **Response Limits**: Large JSON data truncated (2000-1500 chars) to optimize token usage
- **CORS Enabled**: Supports cross-origin requests from web/mobile clients

---

## 📝 API Key Rotation

To rotate the Google AI API key:

1. Generate new API key in Google Cloud Console
2. Update Firebase secret:
   ```bash
   firebase functions:secrets:set GOOGLE_GENAI_API_KEY
   ```
3. Redeploy functions:
   ```bash
   firebase deploy --only functions
   ```

---

## 🔗 Related Documentation

- [Genkit Documentation](https://firebase.google.com/docs/genkit)
- [Google AI API](https://ai.google.dev/)
- [Firebase Cloud Functions](https://firebase.google.com/docs/functions)
- [Firestore Documentation](https://firebase.google.com/docs/firestore)
- [Firebase Authentication](https://firebase.google.com/docs/auth)

---

## 📄 License

Part of the VitaLife Hackathon 2030 project.

---

## 👥 Support

For issues or questions:

1. Check the troubleshooting section above
2. Review Genkit UI debug dashboard (`npm run genkit:ui`)
3. Check Firebase function logs
4. Verify Firestore security rules allow data access

---

**Last Updated**: April 2026  
**Service Region**: asia-southeast1 (Singapore)  
**AI Model**: Google Gemini 2.5 Flash Lite
