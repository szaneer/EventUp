//
//  EventUpClient.swift
//  EventUp!
//
//  Created by Siraj Zaneer on 9/28/17.
//  Copyright © 2017 Siraj Zaneer. All rights reserved.
//

import UIKit
import Firebase

class EventUpClient: NSObject {
    static let sharedInstance = EventUpClient()
    let db = Firestore.firestore()
    
    
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
    
    func createEvent(eventData: [String: Any], success: @escaping (Event) ->(), failure: @escaping (Error) -> ()) {
        var eventData = eventData
        let uid = UUID.init().uuidString
        eventData["peopleCount"] = 0;
        eventData["rating"] = 0.00
        eventData["ratingCount"] = 0
        eventData["uid"] = uid
        let newEvent = db.collection("events").document(uid)
        newEvent.setData(eventData) { (error) in
            if let error = error {
                failure(error)
            } else {
                success(Event(eventData: eventData))
            }
        }
    }
    
    func rateEvent(rating: Double, uid: String, success: @escaping () ->(), failure: @escaping (Error) -> ()) {
        let event = db.collection("events").document(uid)
        event.getDocument { (eventSnapshot, error) in
            if let error = error {
                failure(error)
            } else {
                let currRating = eventSnapshot?.value(forKey: "rating") as! Double
                let ratingCount = eventSnapshot?.value(forKey: "ratingCount") as! Double
                
                let newRatingCount = ratingCount + 1
                let newRating = (currRating * ratingCount + rating) / newRatingCount
                
                event.updateData(["rating": newRating, "ratingCount": newRating], completion: { (error) in
                    if let error = error {
                        failure(error)
                    } else {
                        success()
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
                var currPeopleCount = eventSnapshot?.value(forKey: "peopleCount") as! Int
                currPeopleCount += 1
                
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
}
