
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

class EventDetailViewController: UIViewController, FilterDelegate {
    @IBOutlet weak var eventView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var tagsLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var attendeesLabel: UILabel!
    @IBOutlet weak var eventMapView: MKMapView!
    @IBOutlet weak var editButton: UIButton!
    
    var event: Event!
    var delegate: FilterDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if event.owner == Auth.auth().currentUser!.uid {
            editButton.isHidden = false
        }
        // Do any additional setup after loading the view.
        setup()
    }
    
    func setup() {
        
        EventUpClient.sharedInstance.getUserInfo(uid: event.owner, success: { (user) in
            print(user.rating)
        }) { (error) in
            print(error.localizedDescription)
            
        }
        //nameLabel.text = event.name
        descriptionLabel.text = event.info
        descriptionLabel.sizeToFit()
        let date = Date(timeIntervalSince1970: event.date)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        dateLabel.text = dateFormatter.string(from: date)
        //locationLabel.text = event.location
        //tagsLabel.text = event.tags
        if let image = event.image {
            eventView.image = EventUpClient.sharedInstance.base64DecodeImage(image)
        }
        // Display the number of people that RSVP'd to the event
        attendeesLabel.text = "Attendees: \(event.rsvpCount!)"
        eventMapView.removeAnnotations(eventMapView.annotations)
        eventMapView.addAnnotation(eventMapView.userLocation)
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: event.latitude, longitude: event.longitude)
        annotation.title = event.name
        let region = MKCoordinateRegion(center: annotation.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
        eventMapView.removeAnnotations(eventMapView.annotations)
        eventMapView.setRegion(region, animated: true)
        eventMapView.addAnnotation(annotation)
    }
    @IBAction func deleteEvent(_ sender: Any) {
        let alert = UIAlertController(title: "Delete " + event.name, message: "Are you sure you want to delete this event?", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: {(action: UIAlertAction!) in
            EventUpClient.sharedInstance.deleteEvent(event: self.event, success: {_ in 
                self.onSuccessful()
            }) { (error) in
                print(error)
            }
        
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
            
        self.present(alert, animated: true, completion: nil)
        
    }
    func onSuccessful() {
        self.delegate.refresh(event: nil)
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func rsvpUser(_ sender: Any) {
        EventUpClient.sharedInstance.rsvpEvent(event: event, uid: Auth.auth().currentUser!.uid, success: {(already) in
            if (already) {
                let alert = UIAlertController(title: "Error!", message: "You already have RSVP'd to the event", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: {(action: UIAlertAction!) in self.onSuccessful()}))
                self.present(alert, animated: true, completion: nil)
            } else {
                self.event.rsvpCount = self.event.rsvpCount + 1
                self.setup()
                let alert = UIAlertController(title: "Success!", message: "You RSVP'd to the event", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: {(action: UIAlertAction!) in self.onSuccessful()}))
                self.present(alert, animated: true, completion: nil)
            }
            
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    func filter(type: String, order: Bool) {
        return
    }
    
    func refresh(event: Event?) {
        if let event = event {
            self.event = event
            setup()
        }
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
            destination.delegate = self
        case "ratingSegue":
            let destination = segue.destination as! RatingViewController
            destination.event = event
            destination.delegate = self
        case "chatSegue":
            let destination = segue.destination as! EventChatViewController
            destination.event = self.event
            
        default:
            return
        }
    }
    

}
