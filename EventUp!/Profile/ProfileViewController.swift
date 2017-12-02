//
//  ProfileViewController.swift
//  EventUp!
//
//  Created by Siraj Zaneer on 10/18/17.
//  Copyright © 2017 Siraj Zaneer. All rights reserved.
//

import UIKit
import SVProgressHUD
import Firebase
import MapKit

class ProfileViewController: UIViewController {
    @IBOutlet weak var userImageView: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emailField: UILabel!
    
    var user: EventUser!
    
    
    var events = [Event]()
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let background = UIImage(named: "background")!
        self.navigationController!.navigationBar.setBackgroundImage(background, for: .default)
        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        setupLocation()
        setup()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setup()
    }
    
    func setup() {
        view.isUserInteractionEnabled = false
        SVProgressHUD.show()
        
        guard let user = Auth.auth().currentUser else {
            return
        }
        
        EventUpClient.sharedInstance.getUserInfo(user: user, success: { (user) in
            DispatchQueue.main.async {
                guard let user = user else {
                    try! Auth.auth().signOut()
                    SVProgressHUD.dismiss()
                    self.view.isUserInteractionEnabled = true
                    return
                }
                self.user = user
                self.nameLabel.text = user.name
                self.ratingLabel.text = String(format: "%.2f", user.rating)
                self.emailField.text = user.email
                if let image = user.image {
                    self.userImageView.image = EventUpClient.sharedInstance.base64DecodeImage(image)

                }
                self.userImageView.layer.cornerRadius = 5
                self.userImageView.clipsToBounds = true
                self.setupEvents()
                
            }
        }) { (error) in
            self.view.isUserInteractionEnabled = true
            SVProgressHUD.dismiss()
        }
    }

    func setupEvents() {
        EventUpClient.sharedInstance.getPastUserEvents(uid: Auth.auth().currentUser!.uid, success: { (events) in
            self.events = events
            self.tableView.reloadData()
            SVProgressHUD.dismiss()
            self.view.isUserInteractionEnabled = true
        }) { (error) in
            print(error.localizedDescription)
            SVProgressHUD.dismiss()
            self.view.isUserInteractionEnabled = true
        }
    }

}

extension ProfileViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return events.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EventCell", for: indexPath) as! EventCell
        
        // Configure the cell...
        
        let event: Event
            event = events[indexPath.row]
        
        
        let date = Date(timeIntervalSinceReferenceDate: event.date)
        cell.nameLabel.text = event.name
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        cell.dateLabel.text = dateFormatter.string(from: date)
        cell.dateLabel.text = dateFormatter.string(from: date)
        cell.ratingCountLabel.text = String(format: "%d ratings", event.ratingCount)
        if let tags = event.tags {
            var first = true
            for tag in tags {
                if first {
                    
                    cell.tagLabel.text = tag
                    first = false
                } else {
                    cell.tagLabel.text = cell.tagLabel.text! + ", " + tag
                }
            }
        }
//        if let image = event.image {
//            cell.eventView.image = EventUpClient.sharedInstance.base64DecodeImage(image)
//            cell.eventView.layer.cornerRadius = 5
//            cell.eventView.clipsToBounds = true
//        }
        if let userLocation = locationManager.location?.coordinate {
            let coordinateMe = CLLocation(latitude: userLocation.latitude, longitude: userLocation.longitude)
            let coordinateE = CLLocation(latitude: event.latitude, longitude: event.longitude)
            
            let distance = Int(coordinateE.distance(from: coordinateMe) / 1609.0)
            cell.distanceLabel.text = "\(distance)mi"
        }
        
        
        return cell
    }
}


extension ProfileViewController: CLLocationManagerDelegate {
    
    func setupLocation() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.requestWhenInUseAuthorization()
        } else {
            // Tell user to turn on location
        }
        
        locationManager.delegate = self
    }
    
}
