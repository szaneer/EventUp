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

class ProfileViewController: UIViewController, FilterDelegate {
    
    @IBOutlet weak var userImageView: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emailField: UILabel!
    @IBOutlet weak var settingsButton: UIButton!
    
    var user: EventUser!
    
    var events = [Event]()
    var ogEvents = [Event]()
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let sidebarIcon = UIImageView(image: UIImage(named: "settingsIcon"))
        sidebarIcon.frame = CGRect(x: 0, y: 0, width: settingsButton.frame.height, height: settingsButton.frame.height)
        settingsButton.frame = CGRect(x: 0, y: 0, width: settingsButton.frame.height, height: settingsButton.frame.height)
        settingsButton.addSubview(sidebarIcon)
        
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
        
        EventUpClient.sharedInstance.getUserInfo(user: Auth.auth().currentUser!.uid, success: { (user) in
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
        EventUpClient.sharedInstance.getUserEvents(uid: Auth.auth().currentUser!.uid, success: { (events) in
            self.events = events
            self.ogEvents = events
            self.onTimeChange(nil)
            self.tableView.reloadData()
            SVProgressHUD.dismiss()
            self.view.isUserInteractionEnabled = true
            
        }) { (error) in
            print(error.localizedDescription)
            SVProgressHUD.dismiss()
            self.view.isUserInteractionEnabled = true
        }
    }

    func filter(filters: [String : Bool]) {
        return
    }
    
    func refresh(event: Event?) {
        setupEvents()
    }
    
    @IBAction func onTimeChange(_ sender: Any?) {
        let currDate = Date().timeIntervalSince1970
        guard let segmentControl = sender as? UISegmentedControl else {
            events = ogEvents.filter({ (event) -> Bool in
                return event.endDate < currDate
            })
            tableView.reloadData()
            return
        }
        
        switch segmentControl.selectedSegmentIndex {
        case 0:
            events = ogEvents.filter({ (event) -> Bool in
                return event.endDate < currDate
            })
        case 1:
            events = ogEvents.filter({ (event) -> Bool in
                return event.endDate >= currDate && event.date <= currDate
            })
        case 2:
            events = ogEvents.filter({ (event) -> Bool in
                return event.date > currDate
            })
        default:
            return
        }
        tableView.reloadData()
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
        
        let event = events[indexPath.row]
        //cell.eventView.image = nil
        cell.distanceLabel.text = ""
        
        cell.nameLabel.text = event.name
        cell.ratingView.value = CGFloat(event.rating)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        let date = Date(timeIntervalSince1970: event.date)
        
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
        } else {
            cell.tagLabel.text = ""
        }
        
        if let userLocation = locationManager.location?.coordinate {
            
            let coordinateMe = CLLocation(latitude: userLocation.latitude, longitude: userLocation.longitude)
            let coordinateE = CLLocation(latitude: event.latitude, longitude: event.longitude)
            
            let distance = Int(coordinateE.distance(from: coordinateMe) / 1609.0)
            cell.distanceLabel.text = "\(distance)mi"
        }
        
        cell.tag = indexPath.row
        cell.eventView.image = nil
        EventUpClient.sharedInstance.getEventImage(uid: event.uid, success: { (image) in
            DispatchQueue.main.async {
                if cell.tag == indexPath.row {
                    cell.eventView.image = image
                    cell.eventView.clipsToBounds = true
                    cell.eventView.layer.cornerRadius = 5
                }
            }
        }) { (error) in
            print(error)
        }
        
        
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let segueID = segue.identifier else {
            return
        }
        
        switch segueID {
        case "detailSegue":
            let destination = segue.destination as! EventDetailViewController
            let cell = sender as! EventCell
            let indexPath = tableView.indexPath(for: cell)!
            let event = events[indexPath.row]
            
            destination.event = event
            destination.eventImage = cell.eventView.image
            destination.delegate = self
            
            let detailSegue = segue as! DetailSegue
            detailSegue.event = event
            detailSegue.index = indexPath.row
        default:
            return
        }
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
