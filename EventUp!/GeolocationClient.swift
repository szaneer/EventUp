//
//  GeolocationClient.swift
//  EventUp!
//
//  Created by Siraj Zaneer on 11/14/17.
//  Copyright © 2017 Siraj Zaneer. All rights reserved.
//

import Foundation
import Firebase
import GeoFire

class GeolocationClient {
    static let sharedInstance = GeolocationClient()
    
    func checkLocations(uid: String) {
        let geofireRef = Database.database().reference().child("userRsvpLists").child(uid)
        let geoFire = GeoFire(firebaseRef: geofireRef)!
        
        let center = CLLocation(latitude: 37.7832889, longitude: -122.4056973)
        // Query locations at [37.7832889, -122.4056973] with a radius of 600 meters
        var circleQuery = geoFire.queryAtLocation(center, withRadius: 0.6)
        
        // Query location by region
        let span = MKCoordinateSpanMake(0.001, 0.001)
        let region = MKCoordinateRegionMake(center.coordinate, span)
        var regionQuery = geoFire.queryWithRegion(region)
        
        var queryHandle = query.observeEventType(.KeyEntered, withBlock: { (key: String!, location: CLLocation!) in
            println("Key '\(key)' entered the search area and is at location '\(location)'")
        })
    }
}
