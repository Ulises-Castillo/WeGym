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
const {getMessaging} = require("firebase-admin/messaging");
const { event } = require("firebase-functions/v1/analytics");

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


exports.sendNewCommentNotification = onDocumentCreated("/training_sessions/{training_session_uid}/post-comments/{comment_uid}", (event) => {

//NOTE:     do not send notification to `commentOwnerUid` (filter), send to everyone else including `trainingSessionOwnerUid` (as  long as not equal to `commentOwnerUid`)
    // Algo:
    // 1. collect UIDs of everyone who has commented on the trainingSession -> add to set (avoid dups) + trainingSessionOwnerUid, remove newComment owner
    // 2. Get FCM tokens of all UIDs in the set
    // 4. send multi-cast notification to all tokens

    const snapshot = event.data;
    const data = snapshot.data();
    const timestamp = data.timestamp;
    const commentText = data.commentText;

    const newCommentOwnerUid = data.commentOwnerUid;
    const trainingSessionOwnerUid = data.trainingSessionOwnerUid;

    


    getFirestore().collection("training_sessions").doc(event.params.training_session_uid).collection("post-comments").get().then((querySnapshot) => {

        var commentUids = [];

        commentUids.push(trainingSessionOwnerUid)

        querySnapshot.forEach((doc) => {

            const prevCommentData = doc.data();
            const prevCommentUid = prevCommentData.commentOwnerUid;

            if (prevCommentUid != trainingSessionOwnerUid) {
                commentUids.push(prevCommentUid);
            }

            // doc.data() is never undefined for query doc snapshots
            // console.log(doc.id, " => ", doc.data());
        });

        

        var tokens = [];

        commentUids.forEach((uid) => {

            getFirestore().collection("fcmTokens").doc(uid).get().then((doc) => {

                const token = doc.data().token;

                if (uid != newCommentOwnerUid && !tokens.includes(token)) {
                    tokens.push(token);
                }

            });

        });

        //TODO: if array is empty at this point, return (edge case where user comments on his own session w/o any other commenters)

        getFirestore().collection("users").doc(newCommentOwnerUid).get().then((doc) => {
                
            const data = doc.data()
            const newCommenterName = data.fullName;
            const newCommenterUsername = data.username;
    
            const newCommenter = newCommenterName == null ? newCommenterUsername : newCommenterName;
        

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
                            "title" : `${newCommenter}`, //TODO: get new commenter name
                            // "subtitle" : `${li}`,
                            "body" : `Commented: ${commentText}` //TODO: get comment text
                        }
                    },
                    notificationType: "new_training_session_comment",
                    trainingSessionUid: `${event.params.training_session_uid}`,
                    fromId: `${newCommentOwnerUid}`,
                    commentId: `${event.params.comment_uid}`,
                    date: `${timestamp.toDate()}`
                }
            },
            tokens: tokens
        };

        getMessaging().sendEachForMulticast(message)
            .then((response) => {
                console.log(response.successCount + ' messages were sent successfully');
            });
        });
    });
});

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
