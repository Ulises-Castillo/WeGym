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
                            "content-available": 1,
                            sound: 'default',
                            alert : {
                                "title" : "WeGym",
                                "subtitle" : `${fromName}`,
                                "body" : `${messageText}`
                            }
                        },
                        notificationType: "new_direct_message",
                        "fromId": `${fromId}`
                    }
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


// exports.sendNewCommentNotification = onDocumentCreated("/training_sessions/{training_session_uid}/post-comments/{comment_uid}", (event) => {

    //NOTE: do not send notification if `commentOwnerUid` is equal to `trainingSessionOwnerUid` && no one else has commented on the same training sessions
    // Algo:
    // 1. collect UIDs of everyone who has commented on the trainingSession
    // 2. Edge case: if only the trainingSession Owner has commented on his own session, no notification
    // 3. Get FCM tokens of all the commenters
    // 4. send multi-cast notification to all commenters

// });

exports.sendNewTrainingSessionLikeNotification = onDocumentCreated("/training_sessions/{training_session_uid}/training_session-likes/{liker_uid}", (event) => {

    // Algo:
    // 1. get liker_uid
    // 2. get training_session ownerUid
    // 3. if liker_uid == ownerUid, return
    // 4. otherwise, use ownerUid to get FCM token
    // 5. get liker username
    // 6. send message to owner FCM token "{username} liked your [Chest][Back] workout"

    // edge case: do not send notification when user likes his own session

    getFirestore().collection("training_sessions").doc(event.params.training_session_uid).get().then((doc) => {

        const data = doc.data();
        const ownerUid = data.ownerUid;
        const workoutFocus = data.focus.join(' ');
        const timestamp = data.date;

        if (ownerUid == event.params.liker_uid) {
            return;
        }

        getFirestore().collection("fcmTokens").doc(ownerUid).get().then((doc) => {

            const token = doc.data().token;

            getFirestore().collection("users").doc(event.params.liker_uid).get().then((doc) => {
                
                const data = doc.data()
                const likerName = data.fullName;
                const likerUsername = data.username;

                const liker = likerName == null ? likerUsername : likerName;

                const message = {
                    notification: {
                        title: "WeGym",
                        body: "",
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
                                "content-available": 1,
                                sound: 'default',
                                alert : {
                                    "title" : `${liker}`,
                                    // "subtitle" : `${li}`,
                                    "body" : `liked your ${workoutFocus} workout`
                                }
                            },
                            notificationType: "new_training_session_like",
                            fromId: `${event.params.liker_uid}`,
                            date: `${timestamp.toDate()}`
                        }
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

});
