//
//  Message.swift
//  EventUp!
//
//  Created by Siraj Zaneer on 10/19/17.
//  Copyright © 2017 Siraj Zaneer. All rights reserved.
//

import UIKit

class Message: NSObject {
    var message: String!
    var sender: String!
    var timestamp: Double!
    
    init(messageData: [String: Any]) {
        message = messageData["message"] as! String
        sender = messageData["sender"] as! String
        timestamp = messageData["timestamp"] as! Double
    }
}
