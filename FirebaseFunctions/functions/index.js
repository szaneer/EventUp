const functions = require('firebase-functions');
const apn = require('apn');
const admin = require('firebase-admin');
admin.initializeApp(functions.config().firebase);
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

// let deviceToken = "8423626a2a262adcbaf8017c89dad3fb1903d343f36d75f00abb1fd1a88ec217";
//
// var note = new apn.Notification();
//
// note.expiry = Math.floor(Date.now() / 1000) + 3600; // Expires 1 hour from now.
// note.badge = 3;
// note.sound = "ping.aiff";
// note.alert = "\uD83D\uDCE7 \u2709 You have a new message";
// note.payload = {'messageFrom': 'John Appleseed'};
// note.topic = "com.307.EventUp";
//
// provider.send(note, deviceToken).then( (result) => {
//   // see documentation for an explanation of result
// });

exports.eventEdited = functions.firestore
  .document('events/{eventId}').onWrite((event) => {
    // ... Your code here
    console.log(eventId);
  });
