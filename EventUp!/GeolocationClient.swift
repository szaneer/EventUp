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
import MapKit

class GeolocationClient: NSObject {
    static let sharedInstance = GeolocationClient()
    
    let locationManager = CLLocationManager()
    var radius = 1000.00
    var queue: DispatchQueue!
    var center: CLLocation?
    var isLocating = false
    override init() {
        super.init()
        queue = DispatchQueue(label: "checkinQueue")
    }

    func beginCheckins(uid: String) {
        
        if !self.setupLocation() {
            return
        }
        queue.async {
            while true {
                if self.isLocating {
                    continue
                }
                let geofireRef = Database.database().reference().child("userRsvpLists").child(uid)
                let geoFire = GeoFire(firebaseRef: geofireRef)!
                
                guard let center = self.locationManager.location else {
                    continue
                }
                
                self.center = center
                let circleQuery = geoFire.query(at: center, withRadius: self.radius)
                
                
                self.isLocating = true
                circleQuery?.observe(.keyEntered, with: { (key, location) in
                    print(key)
                })
                
                circleQuery?.observeReady({
                    //self.isLocating = false
                    
                })
            }
        }
        
    }
    
    func sleepThread() {
        queue.suspend()
        
    }
}

extension GeolocationClient: CLLocationManagerDelegate {
    func setupLocation() -> Bool {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.requestAlwaysAuthorization()
            locationManager.startMonitoringSignificantLocationChanges()
            
            
        } else {
            // Tell user to turn on location
        }
        
        locationManager.delegate = self
        
        switch CLLocationManager.authorizationStatus() {
        case .authorizedAlways:
            return true
        case .denied:
            return false
        default:
            return false
        }
    }
}
