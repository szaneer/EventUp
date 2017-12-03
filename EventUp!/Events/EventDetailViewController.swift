
//
//  EventDetailViewController.swift
//  EventUp!
//
//  Created by Siraj Zaneer on 9/27/17.
//  Copyright © 2017 Siraj Zaneer. All rights reserved.
//

import UIKit
import MapKit
import Firebase
import HCSStarRatingView

class EventDetailViewController: UIViewController, FilterDelegate {
    @IBOutlet weak var eventView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var endDateLabel: UILabel!
    @IBOutlet weak var tagsLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var eventMapView: MKMapView!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var rsvpButton: UIButton!
    @IBOutlet weak var ratingView: HCSStarRatingView!
    @IBOutlet weak var ratingCountLabel: UILabel!
    @IBOutlet weak var chatButton: UIButton!
    
    var event: Event!
    var eventImage: UIImage?
    var delegate: FilterDelegate!
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLocation()
        
        if (UserDefaults.standard.object(forKey: "notifyUID") != nil) {
            setupFromNotify()
        } else {
            
            setup()
        }
    }
    
    func setupFromNotify() {
        EventUpClient.sharedInstance.getEvent(uid: UserDefaults.standard.object(forKey: "notifyUID") as! String, success: { (event) in
            self.event = event
            UserDefaults.standard.removeObject(forKey: "notifyUID")
            
            self.setup()
        }, failure: { (error) in
            print(error.localizedDescription)
        })
    }
    
    func setup() {
        if let eventImage = eventImage {
            eventView.image = eventImage
        } else {
            EventUpClient.sharedInstance.getEventImage(uid: event.uid, success: { (image) in
                self.eventView.image = image
            }, failure: { (error) in
                print(error)
            })
        }
        
        eventView.layer.cornerRadius = 10
        
        EventUpClient.sharedInstance.getUserInfo(uid: event.owner, success: { (user) in
            //self.userRatingLabel.text = String(format: "%.2f", user.rating)
        }) { (error) in
            print(error.localizedDescription)
        }
        
        if (Auth.auth().currentUser!.uid != event.owner) {
            editButton.isHidden = true
        } else {
            editButton.isHidden = false
        }
        
        if let tags = event.tags {
            var first = true
            for tag in tags {
                if first {
                    
                    tagsLabel.text = tag
                    first = false
                } else {
                    tagsLabel.text = tagsLabel.text! + ", " + tag
                }
            }
        }
        
        ratingCountLabel.text = String(format: "%d ratings", event.ratingCount)
        ratingView.value = CGFloat(event.rating)
        nameLabel.text = event.name
        descriptionLabel.text = event.info
        descriptionLabel.sizeToFit()
        let date = Date(timeIntervalSince1970: event.date)
        
        let endDate = Date(timeIntervalSince1970: event.endDate)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy h:mma -"
        dateLabel.text = dateFormatter.string(from: date)
        dateFormatter.dateFormat = "MM/dd/yyyy h:mma"
        endDateLabel.text = dateFormatter.string(from: endDate)
        let currDate = Date()
    
        let currDay = currDate.timeIntervalSince1970
        
        if currDay >= event.date && currDay <= event.endDate {
            rsvpButton.isEnabled = true
            rsvpButton.setTitle("Check In: \(event.checkedInCount!)", for: .normal)
        } else if currDay < event.date {
            rsvpButton.isEnabled = true
            rsvpButton.setTitle("RSVP: \(event.rsvpCount!)", for: .normal)
        } else {
            rsvpButton.isEnabled = false
            rsvpButton.setTitle("Attended: \(event.checkedInCount!)", for: .normal)
        }
        
        if let userLocation = locationManager.location?.coordinate {
            
            let coordinateMe = CLLocation(latitude: userLocation.latitude, longitude: userLocation.longitude)
            let coordinateE = CLLocation(latitude: event.latitude, longitude: event.longitude)
            
            let distance = Int(coordinateE.distance(from: coordinateMe) / 1609.0)
            distanceLabel.text = "\(distance)mi"
        }
        
        eventMapView.removeAnnotations(eventMapView.annotations)
        eventMapView.addAnnotation(eventMapView.userLocation)
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: event.latitude, longitude: event.longitude)
        annotation.title = "Navigate"
        let region = MKCoordinateRegion(center: annotation.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
        eventMapView.removeAnnotations(eventMapView.annotations)
        eventMapView.setRegion(region, animated: true)
        eventMapView.addAnnotation(annotation)
    }
    
    @IBAction func onRate(_ sender: Any) {
        ratingView.isUserInteractionEnabled = false
        
        EventUpClient.sharedInstance.rateEvent(rating: Double(ratingView.value),event: event, uid: Auth.auth().currentUser!.uid, success: { (newRating) in
            self.ratingCountLabel.text = String(format: "%d ratings", newRating.count)
            let alert = UIAlertController(title: "Success!", message: "You rated this event.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
            self.delegate.refresh(event: nil)
            self.ratingView.value = CGFloat(newRating.rating)
            self.ratingView.isUserInteractionEnabled = true
        }) { (error) in
            print(error.localizedDescription)
            self.ratingView.isUserInteractionEnabled = true
        }
    }
    
    
    @IBAction func onChat(_ sender: Any) {
        let currDate = Date()
        
        let currDay = currDate.timeIntervalSince1970
        
        if currDay >= event.date && currDay <= event.endDate {
            EventUpClient.sharedInstance.checkIfCheckedIn(event: event, uid: Auth.auth().currentUser!.uid, success: { (isCheckedIn) in
                if isCheckedIn {
                    self.performSegue(withIdentifier: "chatSegue", sender: nil)
                } else {
                    let alert = UIAlertController(title: "Error", message: "You must check in to use chat room.", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.cancel, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }, failure: { (error) in
                print(error.localizedDescription)
            })
        } else if currDay < event.date {
            EventUpClient.sharedInstance.checkIfRsvp(event: event, uid: Auth.auth().currentUser!.uid, success: { (isCheckedIn) in
                if isCheckedIn {
                    self.performSegue(withIdentifier: "chatSegue", sender: nil)
                } else {
                    let alert = UIAlertController(title: "Error", message: "You must RSVP to use chat room.", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.cancel, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }, failure: { (error) in
                print(error.localizedDescription)
            })
        } else {
            let alert = UIAlertController(title: "Error", message: "Event is already over and the chat room is closed.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func onSuccessful() {
        self.delegate.refresh(event: nil)
    }
    @IBAction func onNotify(_ sender: Any) {
        let alertController = UIAlertController(title: "Notify User", message: "Enter in email address of user to notify.", preferredStyle: UIAlertControllerStyle.alert)
        alertController.addTextField { (textField : UITextField) -> Void in
            textField.placeholder = "email"
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) { (result : UIAlertAction) -> Void in
        }
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) { (result : UIAlertAction) -> Void in
            EventUpClient.sharedInstance.notifyUser(email: alertController.textFields![0].text!, event: self.event, success: { (user) in
            }, failure: { (error) in
                print(error.localizedDescription)
            })
        }
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func rsvpUser(_ sender: Any) {
        let currDate = Date()
        
        let currDay = currDate.timeIntervalSince1970
        
        if currDay >= event.date && currDay <= event.endDate {
            EventUpClient.sharedInstance.checkIfCheckedIn(event: event, uid: Auth.auth().currentUser!.uid, success: { (checkedIn) in
                if checkedIn {
                    let alert = UIAlertController(title: "Error!", message: "You already are checked into this event, would you like to remove your checkin?", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: {(action: UIAlertAction!) in
                        EventUpClient.sharedInstance.cancelCheckInEvent(event: self.event, uid: Auth.auth().currentUser!.uid, success: { (newCount) in
                            let alert = UIAlertController(title: "Success", message: "You removed your check in from the event", preferredStyle: UIAlertControllerStyle.alert)
                            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: {(action: UIAlertAction!) in self.onSuccessful()}))
                            self.present(alert, animated: true, completion: nil)
                            self.event.checkedInCount = newCount
                            DispatchQueue.main.async {
                                self.setup()
                            }
                            
                        }) { (error) in
                            print(error.localizedDescription)
                        }
                        alert.dismiss(animated: true, completion: nil)
                    }))
                    alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                } else {
                    EventUpClient.sharedInstance.checkInEvent(event: self.event, uid: Auth.auth().currentUser!.uid, success: { newCount in
                        let alert = UIAlertController(title: "Success", message: "You checked into the event", preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: {(action: UIAlertAction!) in self.onSuccessful()}))
                        self.present(alert, animated: true, completion: nil)
                        self.event.checkedInCount = newCount
                        DispatchQueue.main.async {
                            self.setup()
                        }
                        
                    }) { (error) in
                        print(error.localizedDescription)
                    }
                    
                }
            }, failure: { (error) in
                print(error.localizedDescription)
            })
        } else if currDay < event.date {
            EventUpClient.sharedInstance.checkIfRsvp(event: event, uid: Auth.auth().currentUser!.uid, success: { (checkedIn) in
                if checkedIn {
                    let alert = UIAlertController(title: "Error!", message: "You already are RSVP'd to this event, would you like to remove your RSVP?", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: {(action: UIAlertAction!) in
                        EventUpClient.sharedInstance.cancelRsvpEvent(event: self.event, uid: Auth.auth().currentUser!.uid, success: { (newCount) in
                            let alert = UIAlertController(title: "Success", message: "You canceled your RSVP to the event", preferredStyle: UIAlertControllerStyle.alert)
                            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: {(action: UIAlertAction!) in self.onSuccessful()}))
                            self.present(alert, animated: true, completion: nil)
                            self.event.rsvpCount = newCount
                            DispatchQueue.main.async {
                                self.setup()
                            }
                            
                        }) { (error) in
                            print(error.localizedDescription)
                        }
                        alert.dismiss(animated: true, completion: nil)
                    }))
                    alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                } else {
                    EventUpClient.sharedInstance.rsvpEvent(event: self.event, uid: Auth.auth().currentUser!.uid, success: { newCount in
                        let alert = UIAlertController(title: "Success!", message: "You RSVP'd to the event", preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: {(action: UIAlertAction!) in self.onSuccessful()}))
                        self.present(alert, animated: true, completion: nil)
                        self.event.rsvpCount = newCount
                        DispatchQueue.main.async {
                            self.setup()
                        }
                        
                    }) { (error) in
                        print(error.localizedDescription)
                    }
                }
            }, failure: { (error) in
                print(error.localizedDescription)
            })
            
        }
    }
    
    func filter(filters: [String: Bool]) {
        return
    }
    
    func refresh(event: Event?) {
        EventUpClient.sharedInstance.getEvent(uid: self.event.uid, success: { (event) in
            self.event = event
            self.setup()
        }) { (error) in
            print(error.localizedDescription)
        }
        delegate.refresh(event: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        
        guard let segueID = segue.identifier else {
            return
        }
        
        switch segueID {
        case "editSegue":
            let destination = segue.destination as! EventCreateViewController
            destination.editEvent = event
            destination.editImage = eventView.image
            destination.delegate = self
        case "chatSegue":
            let destination = segue.destination as! EventChatViewController
            destination.event = self.event
        default:
            return
        }
    }
}

extension EventDetailViewController: CLLocationManagerDelegate, MKMapViewDelegate {
    func setupLocation() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.requestWhenInUseAuthorization()
        } else {
            // Tell user to turn on location
        }
        
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
        eventMapView.delegate = self
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        DispatchQueue.main.async {
            if let userLocation = self.locationManager.location?.coordinate {
                
                let coordinateMe = CLLocation(latitude: userLocation.latitude, longitude: userLocation.longitude)
                let coordinateE = CLLocation(latitude: self.event.latitude, longitude: self.event.longitude)
                
                let distance = Int(coordinateE.distance(from: coordinateMe) / 1609.0)
                self.distanceLabel.text = "\(distance)mi"
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let coordinate = CLLocationCoordinate2D(latitude: event.latitude, longitude: event.longitude)
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate, addressDictionary:nil))
        mapItem.name = event.name
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving])
    }
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation
        {
            return nil
        }
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "Pin")
        if annotationView == nil{
            annotationView = EventAnnotationView(annotation: annotation, reuseIdentifier: "Pin")
            annotationView?.canShowCallout = false
        }else{
            annotationView?.annotation = annotation
        }
        
        annotationView?.canShowCallout = true
        annotationView?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        let currDate = Date().timeIntervalSinceReferenceDate
        if currDate >= event.date && currDate <= event.endDate {
            let annotationImage = UIImage(named: "EventAnnotation_green")
            annotationView?.image = annotationImage
        } else if currDate < event.date {
            let annotationImage = UIImage(named: "EventAnnotation")
            annotationView?.image = annotationImage
        } else {
            let annotationImage = UIImage(named: "EventAnnotation_red")
            annotationView?.image = annotationImage
        }
        return annotationView
    }
}
