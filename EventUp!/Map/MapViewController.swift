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
import AVFoundation

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
    
    func setupLocation() {
        eventMapView.delegate = self
        eventMapView.showsUserLocation = true
        if CLLocationManager.locationServicesEnabled() {
            locationManager.requestWhenInUseAuthorization()
        } else {
            // Tell user to turn on location
        }
        
        
        locationManager.startUpdatingLocation()
        
        locationManager.delegate = self
        
        onLocation(self)
    }
    
    
    
    @IBAction func onLocation(_ sender: Any) {
        if let userLocation = locationManager.location?.coordinate {
            let region = MKCoordinateRegion(center: userLocation, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            eventMapView.setRegion(region, animated: true)
        }
        
        
    }
    
    func filter(filters: [String: Bool]) {
        return
    }
    
    func refresh(event: Event?) {
        SVProgressHUD.show()
        loadEvents()
    }
    
    
    func loadEvents() {
        SVProgressHUD.show()
        view.isUserInteractionEnabled = false
        EventUpClient.sharedInstance.getEvents(success: { (events) in
            self.events = events
            
            self.eventMapView.removeAnnotations(self.eventMapView.annotations)
            for event in self.events {
                self.addEventToMap(event: event)
            }
            self.view.isUserInteractionEnabled = true
            SVProgressHUD.dismiss()
        }) { (error) in
            print(error.localizedDescription)
            self.view.isUserInteractionEnabled = true
            SVProgressHUD.dismiss()
        }
    }
    
    @IBAction func onRefresh(_ sender: Any) {
        loadEvents()
    }
    
    
    func addEventToMap(event: Event) {
        let annotation = EventAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: event.latitude, longitude: event.longitude)
        annotation.event = event
        annotation.title = event.name
        let heatCircle = MKCircle(center: annotation.coordinate, radius: CLLocationDistance(event.rsvpCount * 100))
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
            let coordinate = CLLocationCoordinate2D(latitude: eventAnnotation.event.latitude, longitude: eventAnnotation.event.longitude)
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
        
        let date = Date(timeIntervalSinceReferenceDate: eventAnnotation.event.date)
        let endDate = Date(timeIntervalSinceReferenceDate: eventAnnotation.event.endDate)
        let currDate = Date(timeIntervalSinceReferenceDate: Date.timeIntervalSinceReferenceDate)
        
        let calendar = Calendar.current
        
        let currDay = calendar.ordinality(of: .day, in: .year, for: currDate)!
        let start = calendar.ordinality(of: .day, in: .year, for: date)!
        let end = calendar.ordinality(of: .day, in: .year, for: endDate)!
        
        if currDay >= start && currDay <= end {
            let annotationImage = UIImage(named: "EventAnnotation_green")
            annotationView.image = annotationImage
        } else if currDay < start {
            let annotationImage = UIImage(named: "EventAnnotation")
            annotationView.image = annotationImage
        } else {
            let annotationImage = UIImage(named: "EventAnnotation_red")
            annotationView.image = annotationImage
        }
        
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
//        let alertSound = URL(fileURLWithPath: Bundle.main.path(forResource: "test", ofType: "wav")!)
//        print(alertSound)
//        
//        try! AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
//        try! AVAudioSession.sharedInstance().setActive(true)
//        
//        try! audioPlayer = AVAudioPlayer(contentsOf: alertSound)
//        audioPlayer!.prepareToPlay()
//        audioPlayer!.play()
//        
        let smallView = UIView()
        smallView.frame = CGRect(x: 25, y: 25, width: 100, height: 100)
        
        let text = UILabel()
        text.text = "Test Annotation Menu"
        smallView.addSubview(text)
        
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

