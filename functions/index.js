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
  

exports.sendNewMessageNotification = onDocumentCreated("/messages/{uid1}/{uid2}/{messageId}", (event) => {

    const snapshot = event.data;
    const data = snapshot.data();

    const toId = data.toId;
    const fromId = data.fromId;
    const messageText = data.text;

    // prevent dup notifications
    // two message documents created
    // one in each of the user's message list
    if (toId == event.params.uid2) {
        return;
    }

    getFirestore().collection("fcmTokens").doc(toId).get().then((doc) => {

        const token = doc.data().token;

        getFirestore().collection("users").doc(fromId).get().then((doc) => {
            
            const fromName = doc.data().username; //TODO: should this be fullName instead? (optional)

            const message = {
                notification: {
                    title: "WeGym",
                    body: `${messageText}`,
                },
                data: {

                },
                // Apple specific settings
                apns: {
                    headers: {
                        'apns-priority': '10',
                    },
                    payload: {
                        aps: {
                            sound: 'default',
                        }
                    },
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
