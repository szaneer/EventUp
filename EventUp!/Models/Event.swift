//
//  Event.swift
//  EventUp!
//
//  Created by Siraj Zaneer on 9/28/17.
//  Copyright © 2017 Siraj Zaneer. All rights reserved.
//

import UIKit

class Event: NSObject {

    var name: String!
    var date: Double!
    var longitude: String!
    var latitude: String!
    var tags: String!
    var peopleCount: Int!
    var rating: Double!
    var ratingCount: Int!
    var location: String!
    var info: String!
    var uid: String!
    var image: String?
    var owner: String!
    var rsvpList: [String]!
    
    init(eventData: [String: Any]) {
        name = eventData["name"] as! String
        date = eventData["date"] as! Double
        longitude = eventData["longitude"] as! String
        latitude = eventData["latitude"] as! String
        tags = eventData["tags"] as! String
        peopleCount = eventData["peopleCount"] as! Int
        rating = eventData["rating"] as! Double
        ratingCount = eventData["ratingCount"] as! Int
        location = eventData["location"] as! String
        info = eventData["info"] as! String
        uid = eventData["uid"] as! String
        image = eventData["image"] as? String
        owner = eventData["owner"] as! String
        rsvpList = eventData["rsvpList"] as! [String]
    }
}
