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
import Firebase

class GeolocationClient: NSObject {
    static let sharedInstance = GeolocationClient()
    
    let locationManager = CLLocationManager()
    var radius = 1000.00
    var enabled = true
    var isActive = false
    
    override init() {
        super.init()
    }
    
    @objc func beginCheckins() {
        if isActive {
            return
        }
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        guard let location = locationManager.location else {
            return
        }
        let geofireRef = Database.database().reference().child("userRsvpLists").child(uid)
        let geoFire = GeoFire(firebaseRef: geofireRef)!
        
        let circleQuery = geoFire.query(at: location, withRadius: self.radius)
        var uids: [String] = []
        
        isActive = true
        circleQuery?.observe(.keyEntered, with: { (key, location) in
            if let key = key {
                uids.append(key)
            }
        })
        
        circleQuery?.observeReady({
            for eventUID in uids {
                EventUpClient.sharedInstance.checkInEventWithUID(eventUID: eventUID, uid: uid, success: {
                    
                    if uids.index(of: eventUID) == uids.count - 1 {
                        self.isActive = false
                    }
                }, failure: { (error) in
                    if uids.index(of: eventUID) == uids.count - 1 {
                        
                        self.isActive = false
                    }
                })
            }
        })
    }
    
}



extension GeolocationClient: CLLocationManagerDelegate {
    func setupLocation() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.requestAlwaysAuthorization()
            
            
        } else {
            // Tell user to turn on location
        }
        locationManager.startUpdatingLocation()
        locationManager.startMonitoringSignificantLocationChanges()
        locationManager.delegate = self
        
        
        Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(self.beginCheckins), userInfo: nil, repeats: true)

    }
}
