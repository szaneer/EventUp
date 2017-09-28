//
//  EventAnnotation.swift
//  EventUp!
//
//  Created by Siraj Zaneer on 9/28/17.
//  Copyright © 2017 Siraj Zaneer. All rights reserved.
//

import UIKit
import MapKit

class EventAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var event: Event?
    
    init(coordinate: CLLocationCoordinate2D, title: String, event: Event) {
        self.coordinate = coordinate
        self.title = title
        self.event = event
    }
}
