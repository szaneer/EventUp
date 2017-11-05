//
//  User.swift
//  EventUp!
//
//  Created by Siraj Zaneer on 10/18/17.
//  Copyright © 2017 Siraj Zaneer. All rights reserved.
//

import UIKit

class EventUser: NSObject {
    
    var name: String!
    var rating: Double!
    var ratingCount: Double!
    var email: String!
    var image: String?
    var events: [String]?
    
    init(eventData: [String: Any]) {
        name = eventData["username"] as! String
        email = eventData["email"] as! String
        rating = eventData["rating"] as!CV #imageLiteral(resourceName: "icn_vine_badge.png")]
        \\]Double
        ratingCount = eventData["ratingCount"] as! Double
        image = eventData["image"] as? String
    }
}
