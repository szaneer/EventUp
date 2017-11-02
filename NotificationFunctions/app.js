const functions = require('firebase-functions');
const apn = require('apn');
const admin = require('firebase-admin');

var serviceAccount = require("./serviceKey.json");

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  databaseURL: "https://eventup-8c89b.firebaseio.com"
});

var db = admin.firestore();
// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//
// exports.helloWorld = functions.https.onRequest((request, response) => {
//  response.send("Hello from Firebase!");
// });

let provider = new apn.Provider({
  token: {
    key: "AuthKey_JCNX2742EK.p8",
    keyId: "JCNX2742EK",
    teamId: "3YC9K4952Y"
  },
  production: false
});


var query = db.collection("notifications");

var observer = query.onSnapshot(querySnapshot => {
  console.log(`Received query snapshot of size ${querySnapshot.size}`);
  querySnapshot.docChanges.forEach(function(change) {
            if (change.type === "added") {
                let type = change.doc.data().type;
                let uid = change.doc.data().uid;
                if (type == "edit") {
                  db.collection("events").doc(uid).collection("rsvpList").get().then(function(rsvpList) {
                    rsvpList.forEach(function(rsvp) {
                      if (rsvp !== undefined) {
                        db.collection("users").doc(rsvp.data().uid).get().then(function(userInfo) {
                          let data = userInfo.data();
                          console.log(data.token);
                          if (data.token !== undefined) {
                            let deviceToken = data.token ;

                            var note = new apn.Notification();

                            note.expiry = Math.floor(Date.now() / 1000) + 3600; // Expires 1 hour from now.
                            note.badge = 3;
                            note.sound = "ping.aiff";
                            note.alert = "An event you RSVP'd to has just been updated!";
                            note.payload = {'uid': uid};
                            note.topic = "com.307.EventUp";

                            provider.send(note, deviceToken).then( (result) => {
                              // see documentation for an explanation of result
                              console.log(result);
                            });
                          }
                        });
                      }
                      });
                  });

                  query.doc(uid).delete();
                } else if (type == "user") {
                  db.collection("users").doc(change.doc.id).get().then(function(userInfo) {
                      let data = userInfo.data();

                      let deviceToken = data.token;
                      if (deviceToken !== undefined) {

                      var note = new apn.Notification();

                      note.expiry = Math.floor(Date.now() / 1000) + 3600; // Expires 1 hour from now.
                      note.badge = 3;
                      note.sound = "ping.aiff";
                      note.alert = "Check out this event shared by a friend!";
                      note.payload = {"uid": uid};
                      provider.send(note, deviceToken).then( (result) => {
                        // see documentation for an explanation of result
                        console.log(result);
                      });
                    }

                  });

                  query.doc(change.doc.id).delete();
                }
            }
        });
}, err => {
  console.log(`Encountered error: ${err}`);
});
// exports.eventEdited = functions.firestore
//   .document("events/{eventId}").onUpdate((event) => {
//     // ... Your code here
//     console.log(eventId);
//   });
