/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

// https://firebase.google.com/docs/functions/get-started
const {onRequest} = require("firebase-functions/v2/https");
const logger = require("firebase-functions");
const {onDocumentCreated} = require("firebase-functions/v2/firestore");

const {initializeApp} = require("firebase-admin/app");
const {getFirestore} = require("firebase-admin/firestore");
const {getMessaging} = require("firebase-admin/messaging")

initializeApp();

exports.sendNewFollowerNotification = onDocumentCreated("/followers/{uid}/user-followers/{follower_uid}/", (event) => {

    getFirestore().collection("fcmTokens").doc(event.params.uid).get().then((doc) => {
        const token = doc.data().token

        getFirestore().collection("users").doc(event.params.follower_uid).get().then((doc) => {
            const follower = doc.data().username

            const message = {
                notification: {
                    title: "WeGym",
                    body: `${follower} is now following you.`
                },
                data: {
                },
                token: token
            };
        
            getMessaging().send(message)
            .then((response) => {
                console.log("Successfully sent message:", response);
                console.log("data: ", token)
            })
            .catch((error) => {
                console.log("Error sending message:", error);
            });
        });
    });
  });
  