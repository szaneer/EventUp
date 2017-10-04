//
//  MapViewController.swift
//  EventUp!
//
//  Created by Siraj Zaneer on 9/25/17.
//  Copyright © 2017 Siraj Zaneer. All rights reserved.
//

import UIKit
import MapKit
import Firebase

class MapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    @IBOutlet weak var eventMapView: MKMapView!
    let locationManager = CLLocationManager()
    let geoCoder = CLGeocoder()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupLocation()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupLocation() {
        eventMapView.delegate = self
        eventMapView.showsUserLocation = true
        if CLLocationManager.locationServicesEnabled() {
            locationManager.requestWhenInUseAuthorization()
        } else {
            // Tell user to turn on location
        }
        
        locationManager.delegate = self
    }

    func loadEvents() {
//        EventUpClient.sharedInstance.getCurrEvent { (events) in
//            for event in events {
//                self.addEventToMap(event: event)
//            }
//        }
    }
    
    func addEventToMap(event: Event) {
        DispatchQueue.global().async {
            self.geoCoder.geocodeAddressString(event.location) { (placemarks: [CLPlacemark]?, error: Error?) in
                if error != nil {
                    print(error?.localizedDescription)
                } else {
                    if let placemark = placemarks?[0] {
                        let coordinate = CLLocationCoordinate2DMake((placemark.location?.coordinate.latitude)!, (placemark.location?.coordinate.longitude)!)
                        let annotation = EventAnnotation(coordinate: coordinate, title: event.name, event: event)
                        self.eventMapView.addAnnotation(annotation)
                    }
                }
            }
        }
    }
    
    @IBAction func onLocation(_ sender: Any) {
        if let userLocation = locationManager.location?.coordinate {
            let region = MKCoordinateRegion(center: userLocation, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            eventMapView.setRegion(region, animated: true)
        }
        
        
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
