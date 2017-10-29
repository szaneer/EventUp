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
    var longitude: Double!
    var latitude: Double!
   
    var rsvpCount: Int!
    var checkedInCount: Int!
    var rating: Double!
    var ratingCount: Int!
    var location: String!
    var info: String!
    var uid: String!
    var owner: String!
    var rsvpList: [String]?
    var checkedInList: [String]?
    var tags: [String]?
    var image: String?
    
    init(eventData: [String: Any]) {
        uid = eventData["uid"] as! String
        owner = eventData["owner"] as! String
        
        name = eventData["name"] as! String
        date = eventData["date"] as! Double
        
        location = eventData["location"] as! String
        longitude = eventData["longitude"] as! Double
        latitude = eventData["latitude"] as! Double
        location = eventData["location"] as! String
        
        if let tags = eventData["tags"] as? [String] {
            self.tags = tags
        }
        
        rsvpCount = eventData["rsvpCount"] as! Int
        rsvpList = eventData["rsvpList"] as? [String]
        checkedInCount = eventData["checkedInCount"] as! Int
        checkedInList = eventData["checkedInList"] as? [String]
        
        rating = eventData["rating"] as! Double
        ratingCount = eventData["ratingCount"] as! Int
        
        info = eventData["info"] as! String
        
        image = eventData["image"] as? String
        
    }
}
