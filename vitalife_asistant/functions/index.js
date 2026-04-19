const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

/**
 * Send push notification when Firestore notification is created
 */
exports.sendPushNotification = functions.firestore
  .document("users/{userId}/notifications/{notificationId}")
  .onCreate(async (snapshot, context) => {
    const userId = context.params.userId;
    const notification = snapshot.data();

    // Get user FCM token
    const userDoc = await admin
      .firestore()
      .collection("users")
      .doc(userId)
      .get();

    if (!userDoc.exists) return null;

    const fcmToken = userDoc.data()?.fcmToken;

    if (!fcmToken) return null;

    const isEmergency = notification.type === "emergency";

    const message = {
      token: fcmToken,
      notification: {
        title: notification.title,
        body: notification.message,
      },
      data: {
        type: notification.type || "info",
        notificationId: snapshot.id,
      },
      android: {
        priority: isEmergency ? "high" : "normal",
        notification: {
          channelId: isEmergency ? "emergency_alerts" : "general_alerts",
          sound: isEmergency ? "emergency_siren" : "default",
        },
      },
      apns: {
        payload: {
          aps: {
            alert: {
              title: notification.title,
              body: notification.message,
            },
            sound: isEmergency ? "emergency_siren.caf" : "default",
            badge: 1,
          },
        },
      },
    };

    try {
      const response = await admin.messaging().send(message);
      console.log("Push sent:", response);
      return response;
    } catch (error) {
      console.error("Push error:", error);

      // remove invalid token
      if (error.code === "messaging/registration-token-not-registered") {
        await admin.firestore().collection("users").doc(userId).update({
          fcmToken: admin.firestore.FieldValue.delete(),
        });
      }

      return null;
    }
  });
