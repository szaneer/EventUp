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


class EventsViewController: UITableViewController {

    var events = [Event]()
    var filteredEvents = [Event]()
    var currFilter: String?
    let locationManager = CLLocationManager()
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        var contentOffset = tableView.contentOffset
        contentOffset.y += (tableView.tableHeaderView?.frame.height)!
        tableView.contentOffset = contentOffset
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchController.searchResultsUpdater = self
        searchController.searchBar.placeholder = "Search Candies"
        searchController.obscuresBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        
        tableView.rowHeight = UITableViewAutomaticDimension
        SVProgressHUD.show()
        
        
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(self.loadEvents), for: .valueChanged)
        
        
        view.isUserInteractionEnabled = false
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

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if isFiltering() {
            return filteredEvents.count
        }
        
        return events.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EventCell", for: indexPath) as! EventCell

        // Configure the cell...

        let event: Event
        
        if isFiltering() {
            event = filteredEvents[indexPath.row]
        } else {
            event = events[indexPath.row]
        }
        
        let date = Date(timeIntervalSince1970: event.date)
        cell.nameLabel.text = event.name
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        cell.dateLabel.text = dateFormatter.string(from: date)
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
    
    
    @IBAction func onTimeSwitch(_ sender: Any) {
        
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
        case "detailSegue":
            let destination = segue.destination as! EventDetailViewController
            let cell = sender as! EventCell
            let indexPath = tableView.indexPath(for: cell)!
            let event: Event
            if isFiltering() {
                event = filteredEvents[indexPath.row]
            } else {
                event = events[indexPath.row]
            }
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

extension EventsViewController: CLLocationManagerDelegate {
    
    
    func setupLocation() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.requestWhenInUseAuthorization()
        } else {
            // Tell user to turn on location
        }
        
        locationManager.delegate = self
    }
    
}

extension EventsViewController: FilterDelegate {
    
    
    func refresh(event: Event?) {
        SVProgressHUD.show()
        loadEvents()
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
}

extension EventsViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        searchEvents(searchController.searchBar.text!)
    }
    
    func searchBarIsEmpty() -> Bool {
        // Returns true if the text is empty or nil
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func searchEvents(_ searchText: String, scope: String = "All") {
        filteredEvents = events.filter({ (event) -> Bool in
            var tagMatch = false
            if let tags = event.tags {
                for tag in tags {
                    if tag.lowercased().contains(searchText.lowercased()) {
                        tagMatch = true
                    }
                }
            }
            return event.name.lowercased().contains(searchText.lowercased()) || tagMatch
        })
        
        tableView.reloadData()
    }
    
    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }
}
