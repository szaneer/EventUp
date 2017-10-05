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
    var events: [Event] = []
    let locationManager = CLLocationManager()
    let geoCoder = CLGeocoder()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupLocation()
        loadEvents()
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

    
    
    @IBAction func onLocation(_ sender: Any) {
        if let userLocation = locationManager.location?.coordinate {
            let region = MKCoordinateRegion(center: userLocation, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            eventMapView.setRegion(region, animated: true)
        }
        
        
    }
    
    func loadEvents() {
        EventUpClient.sharedInstance.getEvents(success: { (events) in
            self.events = events
            for event in events {
                self.addEventToMap(event: event)
            }
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    func addEventToMap(event: Event) {
        let annotation = EventAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: Double(event.latitude)!, longitude: Double(event.longitude)!)
        annotation.event = event
        annotation.title = event.name
        eventMapView.addAnnotation(annotation)
    }
    
    func goToDetail(event: Event) {
        performSegue(withIdentifier: "detailSegue", sender: event)
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            let eventAnnotation = view.annotation as! EventAnnotation
            goToDetail(event: eventAnnotation.event)
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let eventAnnotation = annotation as? EventAnnotation else {
            return nil
        }
        let annotationView = MKAnnotationView(annotation: eventAnnotation, reuseIdentifier: nil)
        let annotationButton = UIButton(type: .detailDisclosure)
        annotationView.rightCalloutAccessoryView = annotationButton
        annotationView.canShowCallout = true
        annotationView.isEnabled = true
        let annotationImage = UIImage(named: "EventAnnotation")
        annotationView.image = annotationImage
        return annotationView
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        guard let id = segue.identifier else {
            return
        }
        
        if id == "detailSegue" {
            let destination = segue.destination as! EventDetailViewController
            destination.event = sender as! Event
        }
    }
    

}
