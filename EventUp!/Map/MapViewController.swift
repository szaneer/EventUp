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
import SVProgressHUD

class MapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, FilterDelegate {
    
    @IBOutlet weak var eventMapView: MKMapView!
    var events: [Event] = []
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        SVProgressHUD.show()
        view.isUserInteractionEnabled = false
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
    
    func filter(type: String) {
        return
    }
    
    func refresh() {
        SVProgressHUD.show()
        loadEvents()
    }
    
    
    func loadEvents() {
        EventUpClient.sharedInstance.getEvents(success: { (events) in
            self.events = events
            for event in events {
                self.addEventToMap(event: event)
            }
            view.isUserInteractionEnabled = true
            SVProgressHUD.dismiss()
        }) { (error) in
            print(error.localizedDescription)
            view.isUserInteractionEnabled = true
            SVProgressHUD.dismiss()
        }
    }
    
    func addEventToMap(event: Event) {
        let annotation = EventAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: Double(event.latitude)!, longitude: Double(event.longitude)!)
        annotation.event = event
        annotation.title = event.name
        let heatCircle = MKCircle(center: annotation.coordinate, radius: CLLocationDistance(event.peopleCount * 100))
        eventMapView.addAnnotation(annotation)
        eventMapView.add(heatCircle)
    }
    
    func goToDetail(event: Event) {
        performSegue(withIdentifier: "detailSegue", sender: event)
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKCircleRenderer(overlay: overlay)
        renderer.fillColor = UIColor.cyan.withAlphaComponent(0.5)
        renderer.strokeColor = UIColor.cyan.withAlphaComponent(0.8)
        return renderer
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            let eventAnnotation = view.annotation as! EventAnnotation
            goToDetail(event: eventAnnotation.event)
        } else if control == view.leftCalloutAccessoryView {
            let eventAnnotation = view.annotation as! EventAnnotation
            let coordinate = CLLocationCoordinate2D(latitude: Double(eventAnnotation.event.latitude)!, longitude: Double(eventAnnotation.event.longitude)!)
            let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate, addressDictionary:nil))
            mapItem.name = eventAnnotation.event.name
            mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving])
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let eventAnnotation = annotation as? EventAnnotation else {
            return nil
        }
        let annotationView = MKAnnotationView(annotation: eventAnnotation, reuseIdentifier: nil)
        annotationView.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        let navButton = UIButton(type: .detailDisclosure)
        annotationView.leftCalloutAccessoryView = navButton
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
            destination.delegate = self
        }
    }
    
    
}

