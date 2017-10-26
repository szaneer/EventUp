//
//  EventsViewController.swift
//  EventUp!
//
//  Created by Siraj Zaneer on 9/25/17.
//  Copyright © 2017 Siraj Zaneer. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD
import MapKit

protocol FilterDelegate {
    func filter(type: String)
    func refresh(event: Event?)
}

class EventsViewController: UITableViewController, CLLocationManagerDelegate, FilterDelegate {

    var events: [Event] = []
    var currFilter: String?
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        tableView.estimatedRowHeight = 155
        tableView.rowHeight = UITableViewAutomaticDimension
        SVProgressHUD.show()
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(self.loadEvents), for: .valueChanged)
        view.isUserInteractionEnabled = false
        loadEvents()
    }
    
    func setupLocation() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.requestWhenInUseAuthorization()
        } else {
            // Tell user to turn on location
        }
        
        locationManager.delegate = self
    }
    
    func refresh(event: Event?) {
        SVProgressHUD.show()
        loadEvents()
    }
    
    @objc func loadEvents() {
        EventUpClient.sharedInstance.getEvents(success: { (events) in
            self.events = events
            self.tableView.reloadData()
            SVProgressHUD.dismiss()
            self.view.isUserInteractionEnabled = true
            self.refreshControl?.endRefreshing()
            guard let filter = self.currFilter else {
                print("hello")
                return
            }
            self.filter(type: filter)
        }) { (error) in
            print(error.localizedDescription)
            SVProgressHUD.dismiss()
            self.view.isUserInteractionEnabled = true
            self.refreshControl?.endRefreshing()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return events.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EventCell", for: indexPath) as! EventCell

        // Configure the cell...

        let event = events[indexPath.row]
        let date = Date(timeIntervalSince1970: event.date)
        cell.nameLabel.text = event.name
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        cell.dateLabel.text = dateFormatter.string(from: date)
        cell.tagLabel.text = event.tags
        cell.attendeesLabel.text = "Attendees: \(event.peopleCount!)"
        cell.locationLabel.text = event.location
        cell.ratingLabel.text = "\(event.rating!)"
        if let image = event.image {
            cell.eventView.image = EventUpClient.sharedInstance.base64DecodeImage(image)
        }
        if let userLocation = locationManager.location?.coordinate {
            let coordinateMe = CLLocation(latitude: userLocation.latitude, longitude: userLocation.longitude)
            let coordinateE = CLLocation(latitude: event.latitude, longitude: event.longitude)
            
            let distance = Int(coordinateE.distance(from: coordinateMe) / 1609.0)
            cell.distanceLabel.text = "\(distance)mi"
        }
        
        
        return cell
    }
    
    func filter(type: String) {
        currFilter = type
        switch type {
        case "name":
            events.sort(by: { (first, second) -> Bool in
                first.name.lowercased() < second.name.lowercased()
            })
            break
        case "distance":
            events.sort(by: { (first, second) -> Bool in
                if let userLocation = locationManager.location?.coordinate {
                    let coordinateMe = CLLocation(latitude: userLocation.latitude, longitude: userLocation.longitude)
                    let coordinateFirst = CLLocation(latitude: first.latitude, longitude: first.longitude)
                    let coordinateSecond = CLLocation(latitude: second.latitude, longitude: second.longitude)
                    let distanceFirst = Int(coordinateFirst.distance(from: coordinateMe) / 1609.0)
                    let distanceSecond = Int(coordinateSecond.distance(from: coordinateMe) / 1609.0)
                    if distanceFirst > distanceSecond {
                        return true
                    }
                    return false
                }
                return false
            })
            break
        case "time":
            events.sort(by: { (first, second) -> Bool in
                first.date < second.date
            })
            break
        default:
            return
        }
        
        tableView.reloadData()
    }
    
    @IBAction func onTimeSwitch(_ sender: Any) {
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
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
            destination.delegate = self
        case "filterSegue":
            let destination = segue.destination as! FilterViewController
            destination.delegate = self
        case "createSegue":
            let destination = segue.destination as! EventCreateViewController
            destination.delegate = self
        default:
            return
        }
    }
    

}
