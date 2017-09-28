//
//  EventUpClient.swift
//  EventUp!
//
//  Created by Siraj Zaneer on 9/28/17.
//  Copyright © 2017 Siraj Zaneer. All rights reserved.
//

import UIKit

class EventUpClient: NSObject {
    static let sharedInstance = EventUpClient()
    
    func getCurrEvent(success: @escaping ([Event]) -> ()) {
        success([])
    }
}
