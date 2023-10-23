/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

const {onRequest} = require("firebase-functions/v2/https");
const logger = require("firebase-functions");
const {onDocumentCreated} = require("firebase-functions/v2/firestore");

// const { getMessaging } = require("firebase/messaging");

// const messaging = getMessaging();
// The Firebase Admin SDK to access Firestore.
const {initializeApp} = require("firebase-admin/app");
const {getFirestore} = require("firebase-admin/firestore");
// const { app, getMessaging } = require("firebase-admin");
const {getMessaging} = require("firebase-admin/messaging")

// const messaging = admin.messaging();


initializeApp();

exports.sendNewFollowerNotification = onDocumentCreated("/followers/{uid}/user-followers/{follower_uid}/", (event) => {
    // This registration token comes from the client FCM SDKs.


    const fcmToken = "fPIqYlLD_EmSia-fiRDkHk:APA91bG2EiJwNCmdO2vOYQKdJH7JJbv9SjKoqZm1H6VGecTCI1D7xyb_fPiyZ7eqGlRjvGgXjfyltzRsFat9kk0ZssKzOyRAr0n5V7Nfh-IhB6_J_tiMUksx4kVG3ZtxQxI2YhKVIaD6";

    const message = {
        notification: {
            title: "God is with me.",
            body: "I don't believe in defeat."
        },
        data: {
        },
        token: fcmToken
    };

    // Send a message to the device corresponding to the provided
    // registration token.
    getMessaging().send(message)
    .then((response) => {
        // Response is a message ID string.
        console.log("Successfully sent message:", response);
    })
    .catch((error) => {
        console.log("Error sending message:", error);
    });
  });

// Create and deploy your first functions
// https://firebase.google.com/docs/functions/get-started

// exports.helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });


