//
//  EventUpClient.swift
//  EventUp!
//
//  Created by Siraj Zaneer on 9/28/17.
//  Copyright © 2017 Siraj Zaneer. All rights reserved.
//

import UIKit
import MapKit
import Firebase
import GeoFire
import FBSDKLoginKit
import GTToast

class EventUpClient: NSObject {
    static let sharedInstance = EventUpClient()
    let db = Firestore.firestore()
    let fdb = Database.database().reference()
    let cdb = Database.database().reference().child("chats")
    
    //Events
    func getEvents(success: @escaping ([Event]) -> (), failure: @escaping (Error) -> ()) {
        getEvents(filters: [:], success: { (events) in
            success(events)
        }) { (error) in
            failure(error)
        }
    }
    
    func getEvents(filters: [String: Any], success: @escaping ([Event]) -> (), failure: @escaping (Error) -> ()) {
        let events = db.collection("events")
        if filters.count > 0 {
            var query: Query? = nil
            for (key, value) in filters {
                if (key == "past") {
                    if !(value as! Bool) {
                        continue
                    }
                    let currDate = Date.timeIntervalSinceReferenceDate.magnitude
                    if query == nil {
                        query = events.whereField("date", isLessThan: currDate)
                    } else {
                        query = query!.whereField("date", isLessThan: currDate)
                    }
                    continue
                }
                if query == nil {
                    query = events.order(by: key, descending: value as! Bool)
                } else {
                    query = query!.order(by: key, descending: value as! Bool)
                }
            }
            if let query = query {
                query.getDocuments { (eventsSnapshot, error) in
                    if let error = error {
                        failure(error)
                    } else {
                        var eventResult: [Event] = []
                        guard let events = eventsSnapshot?.documents else {
                            success(eventResult)
                            return
                        }
                        
                        for event in events {
                            eventResult.append(Event(eventData: event.data()))
                        }
                        
                        success(eventResult)
                    }
                }
            } else {
                events.getDocuments { (eventsSnapshot, error) in
                    if let error = error {
                        failure(error)
                    } else {
                        var eventResult: [Event] = []
                        guard let events = eventsSnapshot?.documents else {
                            success(eventResult)
                            return
                        }
                        
                        for event in events {
                            eventResult.append(Event(eventData: event.data()))
                        }
                        
                        success(eventResult)
                    }
                }
            }
            
        } else {
            events.getDocuments { (eventsSnapshot, error) in
                if let error = error {
                    failure(error)
                } else {
                    var eventResult: [Event] = []
                    guard let events = eventsSnapshot?.documents else {
                        success(eventResult)
                        return
                    }
                    
                    for event in events {
                        eventResult.append(Event(eventData: event.data()))
                    }
                    
                    success(eventResult)
                }
            }
        }
    }
    
    func getEvent(uid: String, success: @escaping (Event) -> (), failure: @escaping (Error) -> ()) {
        let event = db.collection("events").document(uid)
        event.getDocument { (snapshot, error) in
            if let error = error {
                failure(error)
            } else if let snapshot = snapshot {
                success(Event(eventData: snapshot.data()))
            }
        }
    }
    
    func getEventImage(uid: String, success: @escaping (UIImage) -> (), failure: @escaping (Error) -> ()) {
        let eventImage = db.collection("eventImages").document(uid)
        eventImage.getDocument { (snapshot, error) in
            if let error = error {
                failure(error)
            } else if let snapshot = snapshot {
                
                let data = snapshot.data()
                guard let imageString = data["image"] as? String else {
                    failure(EventUpError.imageDownloadError)
                    return
                }
                let image = self.base64DecodeImage(imageString)
                success(image)
            }
        }
    }
    
    func getPastUserEvents(uid: String, success: @escaping ([Event]) -> (), failure: @escaping (Error) -> ()) {
        let currDate = Date.timeIntervalSinceReferenceDate.magnitude
        let userEvents = db.collection("events").whereField("owner", isEqualTo: uid).whereField("date", isLessThan: currDate)
        userEvents.getDocuments { (eventsSnapshot, error) in
            if let error = error {
                failure(error)
            } else {
                var eventResult: [Event] = []
                guard let events = eventsSnapshot?.documents else {
                    success(eventResult)
                    return
                }
                
                for event in events {
                    eventResult.append(Event(eventData: event.data()))
                }
                
                success(eventResult)
            }
        }
        
    }
    
    func createEvent(eventData: [String: Any], eventImage: UIImage?, success: @escaping (Event) ->(), failure: @escaping (Error) -> ()) {
        var eventData = eventData
        eventData["rsvpCount"] = 0
        eventData["checkedInCount"] = 0
        eventData["rating"] = 0.00
        eventData["ratingCount"] = 0
        let eventDoc = db.collection("events").document()
        eventData["uid"] = eventDoc.documentID
        let image = db.collection("eventImages").document(eventDoc.documentID)
        let rsvpList = db.collection("eventRsvpLists").document(eventDoc.documentID)
        let checkInList = db.collection("eventCheckInLists").document(eventDoc.documentID)
        let ratingList = db.collection("eventRatingLists").document(eventDoc.documentID)
        self.db.runTransaction({ (transaction, errorPointer) -> Any? in
            transaction.setData(eventData, forDocument: eventDoc)
            if let eventImage = eventImage {
                let imageString = self.base64EncodeImage(eventImage)
                transaction.setData(["image": imageString], forDocument: image)
            } else {
                transaction.setData([:], forDocument: image)
            }
            transaction.setData([:], forDocument: rsvpList)
            transaction.setData([:], forDocument: checkInList)
            transaction.setData([:], forDocument: ratingList)
            return eventData
        }, completion: { (object, error) in
            if let error = error {
                failure(error)
            } else {
                success(Event(eventData: object as! [String : Any]))
            }
        })
    }
    
    func editEvent(event: Event, eventData: [String: Any], eventImage: UIImage?, success: @escaping () ->(), failure: @escaping (Error) -> ()) {
        let uid = event.uid!
        let eventDoc = db.collection("events").document(uid)
        let image = db.collection("eventImages").document(uid)
        let rsvpList = db.collection("eventRsvpLists").document(eventDoc.documentID)
        let userRsvpLists = fdb.child("userRsvpLists")
        let notifications = db.collection("notifications").document()
        
        
        self.db.runTransaction({ (transaction, errorPointer) -> Any? in
            transaction.updateData(eventData, forDocument: eventDoc)
            if let eventImage = eventImage {
                let imageString = self.base64EncodeImage(eventImage)
                transaction.setData(["image": imageString], forDocument: image)
            } else {
                transaction.setData([:], forDocument: image)
            }
            
            transaction.setData(["uid": event.uid, "type": "edit", "message": "\(event.name!) has been edited, check out what's new!"], forDocument: notifications)
            return nil
        }, completion: { (object, error) in
            if let error = error {
                failure(error)
            } else {
                rsvpList.getDocument(completion: { (snapshot, error) in
                    if let snapshot = snapshot {
                        for (key, _) in snapshot.data() {
                            let geoFire = GeoFire(firebaseRef: userRsvpLists.child(key))!
                            geoFire.setLocation(CLLocation(latitude: event.latitude, longitude: event.longitude), forKey: event.uid)
                        }
                        self.cdb.child(event.uid).removeValue()
                    }
                })
                success()
            }
        })
    }
    
    func deleteEvent(event: Event, success: @escaping () ->(), failure: @escaping (Error) -> ()) {
        let events = db.collection("events").document(event.uid)
        let eventImages = db.collection("eventImages").document(event.uid)
        let rsvpLists = db.collection("eventRsvpLists").document(event.uid)
        let checkInLists = db.collection("eventCheckInLists").document(event.uid)
        let userRsvpLists = fdb.child("userRsvpLists")
        let ratingList = db.collection("eventRatingLists").document(event.uid)
        
        self.cdb.child(event.uid).removeValue()

        let deleteBatch = db.batch()
        deleteBatch.deleteDocument(events)
        deleteBatch.deleteDocument(eventImages)
        deleteBatch.deleteDocument(rsvpLists)
        deleteBatch.deleteDocument(checkInLists)
        deleteBatch.deleteDocument(ratingList)
        
        rsvpLists.getDocument { (snapshot, error) in
            if let error = error {
                failure(error)
                
            } else if let snapshot = snapshot {
                for (key, _) in snapshot.data() {
                    userRsvpLists.child(key).child(event.uid).removeValue()
                }
                self.cdb.child(event.uid).removeValue()
                deleteBatch.commit(completion: { (error) in
                    success()
                })
            }
        }
    }
    
    func deleteUser(uid: String, success: @escaping () ->(), failure: @escaping (Error) -> ()) {
        let user = db.collection("users").document(uid)
        let image = db.collection("userImages").document(uid)
        let eventImages = db.collection("eventImages")
        let rsvpLists = db.collection("eventRsvpLists")
        let checkInLists = db.collection("eventCheckInLists")
        let userRsvpLists = fdb.child("userRsvpLists")
        let ratingList = db.collection("eventRatingLists")
        let tags = db.collection("tags").document(uid)
        
        let deleteBatch = db.batch()
        deleteBatch.deleteDocument(user)
        deleteBatch.deleteDocument(image)
        deleteBatch.deleteDocument(tags)
        
        let query = db.collection("events").whereField("owner", isEqualTo: uid)
        
        query.getDocuments { (snapshot, error) in
            if let error = error {
                
                failure(error)
            } else if let snapshot = snapshot {
                let max = snapshot.documents.count - 1
                if max <= 0 {
                    deleteBatch.commit(completion: { (error) in
                        success()
                    })
                } else {
                    for i in 0...max {
                        let document = snapshot.documents[i]
                        let eventUid = document.data()["uid"] as! String
                        rsvpLists.document(eventUid).getDocument(completion: { (snapshot, error) in
                            if let error = error {
                                failure(error)
                                
                            } else if let snapshot = snapshot {
                                print(snapshot.data())
                                for (key, _) in snapshot.data() {
                                    userRsvpLists.child(key).child(eventUid).removeValue()
                                }
                                deleteBatch.deleteDocument(document.reference)
                                deleteBatch.deleteDocument(eventImages.document(document.documentID))
                                deleteBatch.deleteDocument(ratingList.document(document.documentID))
                                deleteBatch.deleteDocument(checkInLists.document(document.documentID))
                                deleteBatch.deleteDocument(rsvpLists.document(document.documentID))
                                self.cdb.child(eventUid).removeValue()
                                if i == max {
                                    deleteBatch.commit(completion: { (error) in
                                        success()
                                    })
                                }
                            }
                        })
                        
                        
                    }
                }
            } else {
                deleteBatch.commit(completion: { (error) in
                    success()
                })
            }
        }
    }
    
    func rateEvent(rating: Double, event: Event, uid: String, success: @escaping ((rating: Double, count: Int)) ->(), failure: @escaping (Error) -> ()) {
        
        let eventRef = db.collection("events").document(event.uid)
        let ratings = db.collection("eventRatingLists").document(event.uid)
        let owner = db.collection("users").document(event.owner)
        
        db.runTransaction({ (transaction, errorPointer) -> Any? in
            var eventDoc: DocumentSnapshot
            var ratingsDoc: DocumentSnapshot
            var userDoc: DocumentSnapshot
            do {
                eventDoc = try transaction.getDocument(eventRef)
                ratingsDoc = try transaction.getDocument(ratings)
                userDoc = try transaction.getDocument(owner)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }
        
            let eventData = eventDoc.data()
            let oldRating = eventData["rating"] as! Double
            let oldRatingCount = eventData["ratingCount"] as! Int
            
            let ownerData = userDoc.data()
            let oldOwnerRating = ownerData["rating"] as! Double
            let oldOwnerRatingCount = ownerData["ratingCount"] as! Int
            
            
            var newRating: Double
            var newRatingCount: Int
            var newOwnerRating: Double
            var newOwnerRatingCount: Int
            
            let ratingsData = ratingsDoc.data()
            if ratingsData[uid] == nil {
                newRating = oldRating * Double(oldRatingCount) + rating
                newRatingCount = oldRatingCount + 1
                newRating /= Double(newRatingCount)
                
                newOwnerRating = oldOwnerRating * Double(oldOwnerRatingCount) + rating
                newOwnerRatingCount = oldOwnerRatingCount + 1
                newOwnerRating /= Double(newOwnerRatingCount)
                
            } else {
                newRatingCount = oldRatingCount
                newRating = oldRating * Double(oldRatingCount) - oldRating + rating
                newRating /= Double(newRatingCount)
                
                newOwnerRatingCount = oldOwnerRatingCount
                newOwnerRating = oldOwnerRating * Double(oldOwnerRatingCount) - oldOwnerRating + rating
                newOwnerRating /= Double(newOwnerRatingCount)
            }
            
            
            transaction.updateData(["rating": newRating, "ratingCount": newRatingCount], forDocument: eventRef)
            transaction.updateData(["rating": newOwnerRating, "ratingCount": newOwnerRatingCount], forDocument: owner)
            transaction.updateData([uid: true], forDocument: ratings)
            return (newRating, newRatingCount)
        }, completion: { (object, error) in
            if let error = error {
                failure(error)
            } else {
                success(object as! (Double, Int))
            }
        })
    }
    
    // Users
    func registerUser(userData: [String: Any], userImage: UIImage?, success: @escaping (User) ->(), failure: @escaping (Error) -> ()) {
        var userData = userData
        let email = userData["email"] as! String
        let password = userData["password"] as! String
        userData["rating"] = 0.00
        userData["ratingCount"] = 0
        userData["checkedInCount"] = 0
        userData.removeValue(forKey: "password")
        
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            if let error = error {
                failure(error)
            } else if let user = user {
                let uid = user.uid
                let userDoc = self.db.collection("users").document(uid)
                let images = self.db.collection("userImages").document(uid)
                let tags = self.db.collection("tags").document(uid)
                self.db.runTransaction({ (transaction, errorPointer) -> Any? in
                    transaction.setData(userData, forDocument: userDoc)
                    transaction.setData(["Social": 0, "Learning": 0, "Other": 0], forDocument: tags)
                    if let userImage = userImage {
                        let imageString = self.base64EncodeImage(userImage)
                        transaction.setData(["image": imageString], forDocument: images)
                    } else {
                        transaction.setData([:], forDocument: images)
                    }
                    return nil
                }, completion: { (object, error) in
                    if let error = error {
                        failure(error)
                    } else {
                        success(user)
                    }
                })
            }
        }
    }
    
    func loginUser(userData: [String: Any], success: @escaping (User) ->(), failure: @escaping (Error) -> ()) {
        var userData = userData
        let email = userData["email"] as! String
        let password = userData["password"] as! String
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if let error = error {
                failure(error)
            } else if let user = user {
                success(user)
            }
        }
    }
    
    func loginOrRegisterWithFacebook(credential: AuthCredential, success: @escaping (User, [String: Any], Bool) -> (), failure: @escaping (Error) -> ()) {
        
        FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, picture.type(large), email"]).start { (request, result, error) in
            if let error = error {
                failure(error)
            } else if let result = result {
                let userInfo = result as! [String: Any]
                print(userInfo)
                Auth.auth().signIn(with: credential) { (user, error) in
                    if let error = error {
                        failure(error)
                    } else if let user = user {
                        self.db.collection("users").document(user.uid).getDocument(completion: { (userDoc, error) in
                            if let error = error {
                                failure(error)
                            } else if userDoc!.exists {
                                success(user, userInfo, true)
                            } else {
                                success(user, userInfo, false)
                            }
                        })
                        
                    }
                }
            }
        }
        
    }
    
    func registerFacebookUser(uid: String, userData: [String: Any], userImage: UIImage?, success: @escaping () ->(), failure: @escaping (Error) -> ()) {
        var userData = userData
        userData["rating"] = 0.00
        userData["ratingCount"] = 0
        userData["checkedInCount"] = 0
        let userDoc = self.db.collection("users").document(uid)
        let images = self.db.collection("userImages").document(uid)
        let tags = self.db.collection("tags").document(uid)
        self.db.runTransaction({ (transaction, errorPointer) -> Any? in
            transaction.setData(userData, forDocument: userDoc)
            transaction.setData(["Social": 0, "Learning": 0, "Other": 0], forDocument: tags)
            if let userImage = userImage {
                let imageString = self.base64EncodeImage(userImage)
                transaction.setData(["image": imageString], forDocument: images)
            } else {
                transaction.setData([:], forDocument: images)
            }
            return nil
        }, completion: { (object, error) in
            if let error = error {
                failure(error)
            } else {
                success(
                )
            }
        })
    }
    
    func saveUserPushNotificationToken(uid: String, token: String, success: @escaping (EventUser) -> (), failure: @escaping (Error) -> ()) {
        
    }
    
    func getUserInfo(user: String, success: @escaping (EventUser?) -> (), failure: @escaping (Error) -> ()) {
        let userRef = db.collection("users").document(user)
        let images = db.collection("userImages").document(user)
        db.runTransaction({ (transaction, errorPointer) -> Any? in
            var userDoc: DocumentSnapshot
            var imageDoc: DocumentSnapshot
            do {
                userDoc = try transaction.getDocument(userRef)
                imageDoc = try transaction.getDocument(images)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }
            
            var userData = userDoc.data()
            let userImageData = imageDoc.data()
            if userImageData["image"] != nil {
                userData["image"] = userImageData["image"]
            }
            transaction.updateData([:], forDocument: userRef)
            transaction.updateData([:], forDocument: images)
            return userData
        }, completion: { (object, error) in
            if let error = error {
                print(error)
                failure(error)
            } else {
                success(EventUser(eventData: object as! [String : Any]))
            }
        })
    }
    
    func getUserInfo(uid: String, success: @escaping (EventUser) -> (), failure: @escaping (Error) -> ()) {
        let userRef = db.collection("users").document(uid)
        let images = db.collection("userImages").document(uid)
        db.runTransaction({ (transaction, errorPointer) -> Any? in
            var userDoc: DocumentSnapshot
            var imageDoc: DocumentSnapshot
            do {
                userDoc = try transaction.getDocument(userRef)
                imageDoc = try transaction.getDocument(images)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }
            
            var userData = userDoc.data()
            let userImageData = imageDoc.data()
            
            if userImageData["image"] != nil {
                userData["image"] = userImageData["image"]
            }
            return userData
        }, completion: { (object, error) in
            if let error = error {
                failure(error)
            } else {
                success(EventUser(eventData: object as! [String : Any]))
            }
        })
    }
    
    func rsvpEvent(event: Event, uid: String, success: @escaping (Int) ->(), failure: @escaping (Error) -> ()) {
        
        let eventRef = db.collection("events").document(event.uid)
        let rsvpList = db.collection("eventRsvpLists").document(event.uid)
        let userRsvpList = fdb.child("userRsvpLists").child(uid)
        let notifications = db.collection("notifications").document()
        
        let geoFire = GeoFire(firebaseRef: userRsvpList)!
        
        db.runTransaction({ (transaction, errorPointer) -> Any? in
            var eventDoc: DocumentSnapshot
            var rsvpListDoc: DocumentSnapshot
            do {
                eventDoc = try transaction.getDocument(eventRef)
                rsvpListDoc = try transaction.getDocument(rsvpList)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }
            
            var eventData = eventDoc.data()
            let rsvpListData = rsvpListDoc.data()
            var rsvpCount = eventData["rsvpCount"] as! Int
            if rsvpListData[uid] == nil {
                rsvpCount += 1
            }
            
            transaction.updateData(["rsvpCount": rsvpCount], forDocument: eventRef)
            transaction.updateData([uid: true], forDocument: rsvpList)
            transaction.setData(["uid": event.owner, "type": "user", "message": "A user has RSVP'd to \(event.name!)"], forDocument: notifications)
            return rsvpCount
        }, completion: { (object, error) in
            if let error = error {
                failure(error)
            } else {
                geoFire.setLocation(CLLocation(latitude: event.latitude, longitude: event.longitude), forKey: event.uid)
                success(object as! Int)
            }
        })
        
    }
    
    func cancelRsvpEvent(event: Event, uid: String, success: @escaping (Int) ->(), failure: @escaping (Error) -> ()) {
        
        let eventRef = db.collection("events").document(event.uid)
        let rsvpList = db.collection("eventRsvpLists").document(event.uid)
        let userRsvpList = fdb.child("userRsvpLists").child(uid)
        let notifications = db.collection("notifications").document()
        
        db.runTransaction({ (transaction, errorPointer) -> Any? in
            var eventDoc: DocumentSnapshot
            var rsvpListDoc: DocumentSnapshot
            
            do {
                eventDoc = try transaction.getDocument(eventRef)
                rsvpListDoc = try transaction.getDocument(rsvpList)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }
            
            var eventData = eventDoc.data()
            var rsvpListData = rsvpListDoc.data()
            var rsvpCount = eventData["rsvpCount"] as! Int
            rsvpCount -= 1
            rsvpListData.removeValue(forKey: uid)
            transaction.updateData(["rsvpCount": rsvpCount], forDocument: eventRef)
            transaction.setData(rsvpListData, forDocument: rsvpList)
            transaction.setData(["uid": event.owner, "type": "user", "message": "A user has canceled their RSVP to \(event.name!)"], forDocument: notifications)
            return rsvpCount
        }, completion: { (object, error) in
            if let error = error {
                failure(error)
            } else {
                userRsvpList.child(event.uid).removeValue()
                success(object as! Int)
                
            }
        })
        
    }
    
    func cancelCheckInEvent(event: Event, uid: String, success: @escaping (Int) ->(), failure: @escaping (Error) -> ()) {
        
        let tagCounts = db.collection("tags").document(uid)
        let eventRef = db.collection("events").document(event.uid)
        let checkInList = db.collection("eventCheckInLists").document(event.uid)
        let notifications = db.collection("notifications").document()
        
        db.runTransaction({ (transaction, errorPointer) -> Any? in
            var eventDoc: DocumentSnapshot
            var checkInListDoc: DocumentSnapshot
            var tagDoc: DocumentSnapshot
            
            do {
                eventDoc = try transaction.getDocument(eventRef)
                checkInListDoc = try transaction.getDocument(checkInList)
                tagDoc = try transaction.getDocument(tagCounts)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }
            
            var tagData = tagDoc.data()
            if let tags = event.tags {
                for tag in tags {
                    if tagData[tag] != nil {
                        tagData[tag] = (tagData[tag] as! Int) - 1
                    } else {
                        tagData[tag] = 0
                    }
                }
            }
            
            var eventData = eventDoc.data()
            var checkInListData = checkInListDoc.data()
            
            var checkInCount = eventData["checkedInCount"] as! Int
            checkInCount -= 1
            
            checkInListData.removeValue(forKey: uid)
            
            transaction.updateData(["checkedInCount": checkInCount], forDocument: eventRef)
            transaction.setData(checkInListData, forDocument: checkInList)
            
            transaction.setData(tagData, forDocument: tagCounts)
            
            transaction.setData(["uid": event.owner, "type": "user", "message": "A user has canceled their checkin for \(event.name!)"], forDocument: notifications)
            return checkInCount
        }, completion: { (object, error) in
            if let error = error {
                failure(error)
            } else {
                success(object as! Int)
                
            }
        })
        
    }
    
    func checkInEvent(event: Event, uid: String, success: @escaping (Int) ->(), failure: @escaping (Error) -> ()) {
        
        let tagCounts = db.collection("tags").document(uid)
        let eventRef = db.collection("events").document(event.uid)
        let checkInList = db.collection("eventCheckInLists").document(event.uid)
        let rsvpList = db.collection("eventRsvpLists").document(event.uid)
        let userRsvpList = fdb.child("userRsvpLists").child(uid)
        let notifications = db.collection("notifications").document()
        let geoFire = GeoFire(firebaseRef: userRsvpList)!
        
        db.runTransaction({ (transaction, errorPointer) -> Any? in
            var eventDoc: DocumentSnapshot
            var checkInListDoc: DocumentSnapshot
            var rsvpListDoc: DocumentSnapshot
            var tagDoc: DocumentSnapshot
            do {
                eventDoc = try transaction.getDocument(eventRef)
                checkInListDoc = try transaction.getDocument(checkInList)
                rsvpListDoc = try transaction.getDocument(rsvpList)
                tagDoc = try transaction.getDocument(tagCounts)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }
            
            var tagData = tagDoc.data()
            if let tags = event.tags {
                for tag in tags {
                    if tagData[tag] != nil {
                        tagData[tag] = (tagData[tag] as! Int) + 1
                    } else {
                        tagData[tag] = 1
                    }
                }
            }
            
            var eventData = eventDoc.data()
            var rsvpListData = rsvpListDoc.data()
            let checkInListData = checkInListDoc.data()
            
            var checkInCount = eventData["checkedInCount"] as! Int
            if checkInListData[uid] == nil {
                checkInCount += 1
            }
            
            rsvpListData.removeValue(forKey: uid)
            
            transaction.setData(rsvpListData, forDocument: rsvpList)
            transaction.updateData(["checkedInCount": checkInCount], forDocument: eventRef)
            transaction.updateData([uid: true], forDocument: checkInList)
            
            transaction.setData(tagData, forDocument: tagCounts)
            
            transaction.setData(["uid": event.owner, "type": "user", "message": "A user just has checked in for \(event.name!)"], forDocument: notifications)
            return checkInCount
        }, completion: { (object, error) in
            if let error = error {
                failure(error)
            } else {
                geoFire.removeKey(event.uid)
                success(object as! Int)
            }
        })
    }
    
    func checkInEventWithUID(eventUID: String, uid: String, success: @escaping () ->(), failure: @escaping (Error) -> ()) {
        
        let tagCounts = db.collection("tags").document(uid)
        let eventRef = db.collection("events").document(eventUID)
        let checkInList = db.collection("eventCheckInLists").document(eventUID)
        let rsvpList = db.collection("eventRsvpLists").document(eventUID)
        let notifications = db.collection("notifications").document()
        
        var toast: GTToastView!
        db.runTransaction({ (transaction, errorPointer) -> Any? in
            var eventDoc: DocumentSnapshot
            var checkInListDoc: DocumentSnapshot
            var rsvpListDoc: DocumentSnapshot
            var tagDoc: DocumentSnapshot
            do {
                eventDoc = try transaction.getDocument(eventRef)
                checkInListDoc = try transaction.getDocument(checkInList)
                rsvpListDoc = try transaction.getDocument(rsvpList)
                tagDoc = try transaction.getDocument(tagCounts)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }
            
            var eventData = eventDoc.data()
            var rsvpListData = rsvpListDoc.data()
            let checkInListData = checkInListDoc.data()
            
            
            let event = Event(eventData: eventData)
            
            var tagData = tagDoc.data()
            if let tags = event.tags {
                for tag in tags {
                    if tagData[tag] != nil {
                        tagData[tag] = (tagData[tag] as! Int) + 1
                    } else {
                        tagData[tag] = 1
                    }
                }
            }
            
            if event.date > Date().timeIntervalSince1970 {
                return nil
            }
            
            var checkInCount = eventData["checkedInCount"] as! Int
            if checkInListData[uid] == nil {
                checkInCount += 1
            }
            
            rsvpListData.removeValue(forKey: uid)
            
            transaction.setData(rsvpListData, forDocument: rsvpList)
            transaction.updateData(["checkedInCount": checkInCount], forDocument: eventRef)
            transaction.updateData([uid: true], forDocument: checkInList)
            
            transaction.setData(tagData, forDocument: tagCounts)
            
            transaction.setData(["uid": eventData["owner"] as! String, "type": "user", "message": "A user just has checked in for \(eventData["name"] as! String)"], forDocument: notifications)
            
            
            return eventData
        }, completion: { (object, error) in
            if let error = error {
                failure(error)
            } else {
                let eventData = object as! [String: Any]
                DispatchQueue.main.async {
                    toast = GTToast.create("You were just checked into \(eventData["name"] as! String)")
                    toast.show()
                }
                success()
            }
        })
    }
    
   
    func setNotificationToken(uid: String, token: String, success: @escaping () ->(), failure: @escaping (Error) -> ()) {
        let eventDoc = db.collection("users").document(uid)
        eventDoc.updateData(["token": token], completion: { (error) in
            if let error = error {
                failure(error)
            }
            success()
        })
    }
    
    func notifyUser(email: String, event: Event, success: @escaping (EventUser?) ->(), failure: @escaping (Error) -> ()) {
        let user = db.collection("users").whereField("email", isEqualTo: email)
        user.getDocuments { (snapshot, error) in
            if let error = error {
                failure(error)
            } else {
                guard let users = snapshot?.documents, users.count > 0 else {
                    success(nil)
                    return
                }
                let user = EventUser(eventData: users[0].data())
                let notifications = self.db.collection("notifications").document(users[0].documentID)
                notifications.setData(["uid": users[0].documentID, "type": "user", "message": "Hey \(user.name!), check out \(event.name!)!"])
                success(user)
                
            }
        }
    }
    
    func checkIfRsvp(event: Event, uid: String, success: @escaping (Bool) ->(), failure: @escaping (Error) -> ()) {
        
        let rsvpList = db.collection("eventRsvpLists").document(event.uid)
        
        rsvpList.getDocument { (snapshot, error) in
            if let error = error {
                failure(error)
            } else if let snapshot = snapshot {
                let rsvpList = snapshot.data()
                success(rsvpList[uid] != nil)
            }
        }
    }
    
    func checkIfCheckedIn(event: Event, uid: String, success: @escaping (Bool) ->(), failure: @escaping (Error) -> ()) {
        
        let rsvpList = db.collection("eventCheckInLists").document(event.uid)
        
        rsvpList.getDocument { (snapshot, error) in
            if let error = error {
                failure(error)
            } else if let snapshot = snapshot {
                let checkInList = snapshot.data()
                success(checkInList[uid] != nil)
            }
        }
    }
    
    func getUserSuggestedTags(uid: String, success: @escaping ([String]) ->(), failure: @escaping (Error) -> ()) {
        let tags = db.collection("tags").document(uid)
        
        tags.getDocument { (snapshot, error) in
            if let error = error {
                failure(error)
            } else if let snapshot = snapshot {
                let tagData = snapshot.data() as! [String: Int]
                
                let maxEntry = tagData.max(by: { (entry1, entry2) -> Bool in
                    return entry1.value <= entry2.value
                })
                
                let max = maxEntry!.value
                
                if max == 0 {
                    success([])
                    return
                }
                
                var tags: [String] = []
                
                for (tag, value) in tagData {
                    if value == max {
                        tags.append(tag.lowercased())
                    }
                }
                
                success(tags)
            }
        }
    }
    
    // Chat
    func sendMessage(event: Event, message: [String: Any], success: @escaping () ->(), failure: @escaping (Error) -> ()) {
        let eventMessages = cdb.child(event.uid).child("messages")
        let newMessage = eventMessages.childByAutoId()
        newMessage.setValue(message) { (error, ref) in
            if let error = error {
                failure(error)
            } else {
                print(ref)
                success()
            }
        }
    }
    
    func getMessages(event: Event, success: @escaping ([String: Any]) ->(), failure: @escaping (Error) -> ()) {
        let eventMessages = cdb.child(event.uid).child("messages")
        let messageQuery = eventMessages.queryLimited(toLast:25)
        
        messageQuery.observe(.childAdded, with: { (snapshot) -> Void in
            let messageData = snapshot.value as! [String: Any]
            success(messageData)
        })
    }
    
    // Resize a given image using a given GCSize
    func resizeImage(_ imageSize: CGSize, image: UIImage) -> Data {
        UIGraphicsBeginImageContext(imageSize)
        image.draw(in: CGRect(x: 0, y: 0, width: imageSize.width, height: imageSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        let resizedImage = UIImagePNGRepresentation(newImage!)
        UIGraphicsEndImageContext()
        return resizedImage!
    }
    
    // Encode image to string
    func base64EncodeImage(_ image: UIImage) -> String {
        var imagedata = UIImagePNGRepresentation(image)
        
        // Resize the image if it exceeds the 2MB API limit
        while ((imagedata?.count)! > 1048487) {
            let oldSize: CGSize = image.size
            let newSize: CGSize = CGSize(width: 400, height: oldSize.height / oldSize.width * 400)
            imagedata = resizeImage(newSize, image: image)
        }
        
        return imagedata!.base64EncodedString(options: .endLineWithCarriageReturn)
    }
    
    func base64DecodeImage(_ data: String) -> UIImage {
        let data = Data(base64Encoded: data, options: .ignoreUnknownCharacters)!
        
        return UIImage(data: data)!
    }
}

extension String {
    func isValidEmail() -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: self)
    }
}

protocol EventLocationSelectViewControllerDelegate {
    func setLocation(coordinate: CLLocationCoordinate2D)
}

protocol EventTagSelectViewControllerDelegate {
    func setTag(tag: String, index: Int)
}


protocol FilterDelegate {
    func filter(filters: [String: Bool])
    func refresh(event: Event?)
}

enum EventUpError: Error {
    case imageDownloadError
}

