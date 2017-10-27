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
import FBSDKLoginKit

class EventUpClient: NSObject {
    static let sharedInstance = EventUpClient()
    let db = Firestore.firestore()
    let mdb = Database.database().reference().child("messages")
    
    
    func getEvents(success: @escaping ([Event]) -> (), failure: @escaping (Error) -> ()) {
        getEvents(filters: nil, success: { (events) in
            success(events)
        }) { (error) in
            failure(error)
        }
    }
    
    func getEvents(filters: [String: Any]?, success: @escaping ([Event]) -> (), failure: @escaping (Error) -> ()) {
        let events = db.collection("events")
        if let filters = filters {
//            if filters.count <= 1 {
//                Error.
//                failure()
//                return
//            }
//            for (type, value) in filters {
//                if (type == "startDate") {
//                    eventsQuery = eventsQuery.whereField("date", isGreaterThanOrEqualTo: value)
//                }
//            }
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
    
    func createEvent(eventData: [String: Any], eventImage: UIImage?, success: @escaping (Event) ->(), failure: @escaping (Error) -> ()) {
        var eventData = eventData
        let uid = UUID.init().uuidString
        eventData["peopleCount"] = 0;
        eventData["rating"] = 0.00
        eventData["ratingCount"] = 0
        eventData["uid"] = uid
        if let eventImage = eventImage {
            let imageString = base64EncodeImage(eventImage)
            eventData["image"] = imageString
        }
        let newEvent = db.collection("events").document(uid)
        newEvent.setData(eventData) { (error) in
            if let error = error {
                failure(error)
            } else {
                success(Event(eventData: eventData))
            }
        }
        let userEvents = db.collection("users").document(eventData["owner"] as! String).collection("events")
        let newUserEvent = userEvents.document(uid)
        newUserEvent.setData(["uid": uid])
    }
    
    func deleteEvent(event: Event, eventImage: UIImage?, success: @escaping (Event) ->(), failure: @escaping (Error) -> ()) {
        let eventDoc = db.collection("events").document(event.uid)
        eventDoc.delete { (error) in
            if let error = error {
                failure(error)
            }
        }
        let userEvents = db.collection("users").document(event.owner).collection("events")
        userEvents.document(event.uid).delete()
    }
    func rateEvent(rating: Double, uid: String, success: @escaping (Double) ->(), failure: @escaping (Error) -> ()) {
        let event = db.collection("events").document(uid)
        event.getDocument { (eventSnapshot, error) in
            if let error = error {
                failure(error)
            } else {
                var eventData = eventSnapshot!.data()
                let currRating = eventData["rating"] as! Double
                let ratingCount = eventData["ratingCount"] as! Double
                
                let newRatingCount = ratingCount + 1
                let newRating = (currRating * ratingCount + rating) / newRatingCount
                
                event.updateData(["rating": newRating, "ratingCount": ratingCount], completion: { (error) in
                    if let error = error {
                        failure(error)
                    } else {
                        success(newRating)
                    }
                })
            }
        }
    }
    
    
    func checkInEvent(uid: String, success: @escaping () ->(), failure: @escaping (Error) -> ()) {
        let event = db.collection("events").document(uid)
        event.getDocument { (eventSnapshot, error) in
            if let error = error {
                failure(error)
            } else {
                var eventData = eventSnapshot!.data()
                var currPeopleCount = eventData["peopleCount"] as! Int
                currPeopleCount += 1
                print(currPeopleCount)
                event.updateData(["peopleCount": currPeopleCount], completion: { (error) in
                    if let error = error {
                        failure(error)
                    } else {
                        success()
                    }
                })
            }
        }
    }
    
    func deleteEvent(uid: String, success: @escaping () ->(), failure: @escaping (Error) -> ()) {
        let event = db.collection("events").document(uid)
        event.delete { (error) in
            if let error = error {
                failure(error)
                return
            }
            success()
        }
    }
    
    func editEvent(event: Event, eventData: [String: Any], eventImage: UIImage?, success: @escaping (Event) ->(), failure: @escaping (Error) -> ()) {
        var eventData = eventData
        let uid = event.uid!
        eventData["peopleCount"] = event.peopleCount
        eventData["rating"] = event.rating
        eventData["ratingCount"] = event.ratingCount
        eventData["uid"] = uid
        if let eventImage = eventImage {
            let imageString = base64EncodeImage(eventImage)
            eventData["image"] = imageString
        }
        let currEvent = db.collection("events").document(uid)
        currEvent.setData(eventData) { (error) in
            if let error = error {
                failure(error)
            } else {
                success(Event(eventData: eventData))
            }
        }
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
        if ((imagedata?.count)! > 1048487) {
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
    
    
    func registerUser(userData: [String: Any], userImage: UIImage?, success: @escaping (User) ->(), failure: @escaping (Error) -> ()) {
        var userData = userData
        let email = userData["email"] as! String
        let password = userData["password"] as! String
        userData["rating"] = 0.00
        userData.removeValue(forKey: "password")
        if let userImage = userImage {
            let imageString = base64EncodeImage(userImage)
            userData["image"] = imageString
        }
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            if let error = error {
                failure(error)
            } else if let user = user {
                let uid = user.uid
                let users = self.db.collection("users").document(uid)
                users.setData(userData) { (error) in
                    if let error = error {
                        failure(error)
                    } else {
                        success(user)
                    }
                }
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
    
    func getUserInfo(uid: String, success: @escaping (EventUser) -> (), failure: @escaping (Error) -> ()) {
        let users = db.collection("users").document(uid)
        users.getDocument { (userSnapshot, error) in
            if let error = error {
                failure(error)
            } else if let userSnapshot = userSnapshot {
                let user = EventUser(eventData: userSnapshot.data())
                success(user)
            }
        }
    }
    
    func getEventMessages(uid: String, success: @escaping ([Message]) -> (), failure: @escaping (Error) -> ()) {
        let messages = mdb.child(uid)
        messages.observe(.value, with: { (messagesSnapshot) in
            var messageResult: [Message] = []
            guard var eventMessageData = messagesSnapshot.value as? [String: [String: Any]] else {
                success(messageResult)
                return
            }
            let eventMessages = eventMessageData["messages"]
            for (_, message) in eventMessages! {
                messageResult.append(Message(messageData: message as! [String: Any]))
            }
            
            success(messageResult)
            
        }) { (error) in
            failure(error)
        }
    }
    
    func sendEventMessage(uid: String, messageData: [String: Any], success: @escaping () -> (), failure: @escaping (Error) -> ()) {
        let messages = mdb.child(uid)
        messages.setValue(messageData) { (error, _) in
            if let error = error {
                failure(error)
            } else {
                success()
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
        let email = userData["email"] as! String
        userData["rating"] = 0.00
        if let userImage = userImage {
            let imageString = base64EncodeImage(userImage)
            userData["image"] = imageString
        }
        let users = db.collection("users")
        users.document(uid).setData(userData) { (error) in
            if let error = error {
                failure(error)
            }
            success()
        }
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
