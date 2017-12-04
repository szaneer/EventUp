//
//  EventLocationSelectViewController.swift
//  EventUp!
//
//  Created by Siraj Zaneer on 10/19/17.
//  Copyright © 2017 Siraj Zaneer. All rights reserved.
//

import UIKit
import MapKit

class EventLocationSelectViewController: UIViewController {

    @IBOutlet weak var eventLocationView: MKMapView!
    
    var delegate: EventLocationSelectViewControllerDelegate!
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupLocation()
    }
    
    @IBAction func onSelect(_ sender: Any) {
        let alert = UIAlertController(title: "Confirm", message: "Are you sure this is the location?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
            self.delegate.setLocation(coordinate: self.eventLocationView.centerCoordinate)
            self.dismiss(animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func onLocation(_ sender: Any) {
        if let userLocation = locationManager.location?.coordinate {
            let region = MKCoordinateRegion(center: userLocation, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            eventLocationView.setRegion(region, animated: true)
        }
    }
    
    func setupLocation() {
        eventLocationView.showsUserLocation = true
        if CLLocationManager.locationServicesEnabled() {
            locationManager.requestWhenInUseAuthorization()
        }
        
        locationManager.startUpdatingLocation()
        
        onLocation(self)
    }
    
    @IBAction func onCancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
