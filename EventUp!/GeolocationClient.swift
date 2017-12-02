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
    var isActive = true
    
    override init() {
        super.init()
        if (UserDefaults.standard.value(forKey: "checkin") != nil) {
            isActive = UserDefaults.standard.value(forKey: "checkin") as! Bool
        }
        
        if (UserDefaults.standard.value(forKey: "radius") != nil) {
            radius = UserDefaults.standard.value(forKey: "radius") as! Double
        }
    }
    
    @objc func beginCheckins() {
        if !enabled {
            return
        }
        if !isActive {
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
        
        circleQuery?.observe(.keyEntered, with: { (key, location) in
            print(key)
            EventUpClient.sharedInstance.checkInEventWithUID(eventUID: key!, uid: uid, success: {
                print("asdsd")
                geofireRef.child(key!).removeValue()
            }, failure: { (error) in
                print(error.localizedDescription)
            })
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
        
        Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { (timer) in
            self.beginCheckins()
        }

    }
}
