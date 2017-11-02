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
    var filterButton: UIBarButtonItem!
    var createButton: UIBarButtonItem!
    var currFilter = [String: Any]()
    let locationManager = CLLocationManager()
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if (UserDefaults.standard.object(forKey: "notifyUID") != nil) {
            performSegue(withIdentifier: "notifySegue", sender: nil)
            return
        }
        searchController.searchBar.scopeButtonTitles = ["All", "Social", "Learning", "Other"]
        
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchController.searchBar.placeholder = "Search Events"
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = true
        
        definesPresentationContext = true
        navigationItem.searchController = searchController
        
        
        tableView.rowHeight = UITableViewAutomaticDimension
        SVProgressHUD.show()
        
        
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(self.loadEvents), for: .valueChanged)
        
        setupLocation()
        view.isUserInteractionEnabled = false
        SVProgressHUD.show()
        loadEvents()
    }
    
    @objc func loadEvents() {
        EventUpClient.sharedInstance.getEvents(filters: currFilter, success: { (events) in
            self.events = events
            self.tableView.reloadData()
            SVProgressHUD.dismiss()
            self.view.isUserInteractionEnabled = true
            self.refreshControl?.endRefreshing()
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
        
        let date = Date(timeIntervalSinceReferenceDate: event.date)
        cell.nameLabel.text = event.name
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        cell.dateLabel.text = dateFormatter.string(from: date)
        cell.attendeesLabel.text = "Attendees: \(event.rsvpCount!)"
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
            destination.filter = currFilter
        case "notifySegue":
            let destination = segue.destination as! EventDetailViewController
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
    
    
    func filter(type: String, order: Bool) {
        currFilter[type] = true && order
    }
}

extension EventsViewController: UISearchResultsUpdating, UISearchBarDelegate {
    func updateSearchResults(for searchController: UISearchController) {
        //let scope = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
        searchEvents(searchController.searchBar.text!, scope: "All")
    }
    
    func searchBarIsEmpty() -> Bool {
        // Returns true if the text is empty or nil
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func searchEvents(_ searchText: String, scope: String = "All") {
        filteredEvents = events.filter({ (event) -> Bool in
            var doesCategoryMatch = (scope == "All")
            if let tags = event.tags {
                for tag in tags {
                    if tag.lowercased() == scope.lowercased() {
                        doesCategoryMatch = true
                    }
                }
            }
            if searchBarIsEmpty() {
                return doesCategoryMatch
            } else {
                return doesCategoryMatch && event.name.lowercased().contains(searchText.lowercased())
            }
        })
        
        tableView.reloadData()
    }
    
    func isFiltering() -> Bool {
        let searchBarScopeIsFiltering = searchController.searchBar.selectedScopeButtonIndex != 0
        return searchController.isActive && (!searchBarIsEmpty() || searchBarScopeIsFiltering)
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        return true
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        filterButton = navigationItem.rightBarButtonItem
        navigationItem.rightBarButtonItem = nil
        createButton = navigationItem.leftBarButtonItem
        navigationItem.leftBarButtonItem = nil
        
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        //searchController.searchBar.showsScopeBar = false
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        navigationItem.rightBarButtonItem = filterButton
        navigationItem.leftBarButtonItem = createButton
    }
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        searchEvents(searchBar.text!, scope: searchBar.scopeButtonTitles![selectedScope])
    }
}
