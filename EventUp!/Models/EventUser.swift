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
    
    init(eventData: [String: Any]) {
        
        name = eventData["username"] as! String
        email = eventData["email"] as! String
        rating = eventData["rating"] as! Double
        ratingCount = eventData["ratingCount"] as! Double
        image = eventData["image"] as? String
    }
}
