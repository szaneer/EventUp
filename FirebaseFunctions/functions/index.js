const functions = require('firebase-functions');
const apn = require('apn');
const admin = require('firebase-admin');
// Required for side-effects
admin.initializeApp(functions.config().firebase);

var db = admin.firestore();
// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//
// exports.helloWorld = functions.https.onRequest((request, response) => {
//  response.send("Hello from Firebase!");
// });

// let provider = new apn.Provider({
//   token: {
//     key: "AuthKey_JCNX2742EK.p8",
//     keyId: "JCNX2742EK",
//     teamId: "3YC9K4952Y"
//   },
//   production: false
// });

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

exports.createEvent = functions.firestore
  .document('events/{eventId}')
  .onCreate(event => {
    // Get an object representing the document
    // e.g. {'name': 'Marie', 'age': 66}
    var newValue = event.data.data();

    // access a particular field as you would any JS property
    var owner = newValue.owner;
    var uid = newValue.uid;
    db.collection("users").doc(owner).collection("events").doc(uid).set({
        uid: uid
    })
});

exports.updateEvent = functions.firestore
  .document('events/{eventId}')
  .onUpdate(event => {
    // Get an object representing the document
    // e.g. {'name': 'Marie', 'age': 66}
    var newValue = event.data.data();
    var uid = newValue.uid;
    db.collection("notifications").doc(uid).set({
        type: "edit",
        "uid": uid
    })
});

exports.deleteEvent = functions.firestore
  .document('events/{eventId}')
  .onDelete(event => {
    // Get an object representing the document
    // e.g. {'name': 'Marie', 'age': 66}
    var newValue = event.data.previous.data();

    // access a particular field as you would any JS property
    var owner = newValue.owner;
    var uid = newValue.uid;
    db.collection("users").doc(owner).collection("events").doc(uid).delete();
});

exports.eventRated = functions.firestore
  .document('events/{eventId}/rated/{userId}')
  .onCreate(rating => {
    // Get an object representing the document
    // e.g. {'name': 'Marie', 'age': 66}
    var newValue = rating.data.data();

    // access a particular field as you would any JS property

    let newRating = newValue.rating;
    db.collection("events").doc(rating.params.eventId).get().then(function(doc) {
        var eventRating = newRating + doc.data().rating * doc.data().ratingCount;
        ratingC = doc.data().ratingCount + 1;
        eventRating /= ratingC;
        db.collection("events").doc(rating.params.eventId).update({
            "rating": eventRating,
            "ratingCount": ratingC
        });
        db.collection("users").doc(doc.data().owner).get().then(function(userDoc) {
            var userRating = newRating + userDoc.data().rating * userDoc.data().ratingCount;
            ratingC = userDoc.data().ratingCount + 1;
            userRating /= ratingC;
            db.collection("users").doc(doc.data().owner).update({
                "rating": userRating,
                "ratingCount": ratingC
            });
        });
    });



});

exports.eventRatedUpdate = functions.firestore
  .document('events/{eventId}/rated/{userId}')
  .onUpdate(rating => {
    // Get an object representing the document
    // e.g. {'name': 'Marie', 'age': 66}
    var newValue = rating.data.data();

    // access a particular field as you would any JS property

    var newRating = newValue.rating;
    db.collection("events").doc(rating.params.eventId).get().then(function(doc) {
        var eventRating = newRating +  (doc.data().rating * (doc.data().ratingCount - 1));
        let ratingC = doc.data().ratingCount;
        newRating /= ratingC;
        db.collection("events").doc(rating.params.eventId).update({
            "rating": newRating,
            "ratingCount": ratingC
        });
        db.collection("users").doc(doc.data().owner).get().then(function(userDoc) {
            var userRating = newRating + userDoc.data().rating * (userDoc.data().ratingCount - 1);
            ratingC = userDoc.data().ratingCount;
            userRating /= ratingC;
            db.collection("users").doc(doc.data().owner).update({
                "rating": userRating,
                "ratingCount": ratingC
            });
        });
    });

});
