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
import SidebarOverlay


class EventsViewController: UITableViewController {
    
    var events = [Event]()
    var eventsOG = [Event]()
    var tempEvents = [Event]()
    var filteredEvents = [Event]()
    var filterButton: UIBarButtonItem!
    var createButton: UIBarButtonItem!
    var currFilter = [String: Any]()
    let locationManager = CLLocationManager()
    let searchController = UISearchController(searchResultsController: nil)
    var isSugg = false
    var delegate: EventContainerViewControllerDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if (UserDefaults.standard.object(forKey: "notifyUID") != nil) {
            performSegue(withIdentifier: "notifySegue", sender: nil)
            return
        }
        let image = UIImage(named: "background")!
        tableView.backgroundView = UIImageView(image: image)
        tableView.backgroundColor = .clear
        searchController.searchBar.scopeButtonTitles = ["All", "Social", "Learning", "Other"]
        
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchController.searchBar.placeholder = "Search Events"
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = true
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 975
        
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
        print("hello")
        if isSugg {
            SVProgressHUD.dismiss()
            self.view.isUserInteractionEnabled = true
            return
        }
        EventUpClient.sharedInstance.getEvents(filters: currFilter, success: { (events) in
            self.events = events
            self.eventsOG = events
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
    
    func filterProfaneEvents() {
        events = events.filter({ (event) -> Bool in
            if event.name.contains("Bad words") || event.description.contains("Bad words") {
                return false
            }
            return true
        })
        
        tableView.reloadData()
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
        
        let event: Event
        
        if isFiltering() {
            event = filteredEvents[indexPath.row]
        } else {
            event = events[indexPath.row]
        }
        
        cell.eventView.image = nil
        cell.distanceLabel.text = ""
        let date = Date(timeIntervalSinceReferenceDate: event.date)
        cell.nameLabel.text = event.name
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        cell.dateLabel.text = dateFormatter.string(from: date)
        cell.attendeesLabel.text = "Attendees: \(event.rsvpCount!)"
        cell.ratingLabel.text = String(format: "%.2f", event.rating)
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
        
        if let userLocation = locationManager.location?.coordinate {
            
            let coordinateMe = CLLocation(latitude: userLocation.latitude, longitude: userLocation.longitude)
            let coordinateE = CLLocation(latitude: event.latitude, longitude: event.longitude)
            
            let distance = Int(coordinateE.distance(from: coordinateMe) / 1609.0)
            cell.distanceLabel.text = "\(distance)mi"
        }
        
        cell.tag = indexPath.row
        
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
    
    
    @IBAction func onSidebar(_ sender: Any) {
        delegate.toggleSidebar()
    }
    @IBAction func onTimeSwitch(_ sender: Any) {
    }
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
            destination.eventImage = cell.eventView.image
            destination.delegate = self
        case "filterSegue":
            let destination = segue.destination as! FilterViewController
            destination.delegate = self
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
        
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("wow")
        tableView.reloadData()
    }
    
}

extension EventsViewController: FilterDelegate {
    
    func refresh(event: Event?) {
        SVProgressHUD.show()
        loadEvents()
    }
    
    
    func filter(filters: [String: Bool]) {
        self.events = eventsOG
        searchEvents(searchController.searchBar.text!, scope: "ALL")
        for (key, value) in filters {
            switch key {
            case "name":
                if value {
                    events.sort(by: { (second, first) -> Bool in
                        return first.name.lowercased() > second.name.lowercased()
                    })
                    
                    filteredEvents.sort(by: { (second, first) -> Bool in
                        return first.name.lowercased() > second.name.lowercased()
                    })
                } else {
                    events.sort(by: { (first, second) -> Bool in
                        return first.name.lowercased() > second.name.lowercased()
                    })
                    
                    filteredEvents.sort(by: { (first, second) -> Bool in
                        return first.name.lowercased() > second.name.lowercased()
                    })
                }
            case "distance":
                if let userLocation = locationManager.location?.coordinate {
                    
                    let coordinateMe = CLLocation(latitude: userLocation.latitude, longitude: userLocation.longitude)
                    
                    
                    if value {
                        events.sort(by: { (second, first) -> Bool in
                            let coordinateS = CLLocation(latitude: second.latitude, longitude: second.longitude)
                            let coordinateF = CLLocation(latitude: first.latitude, longitude: first.longitude)
                            let distanceS = Int(coordinateS.distance(from: coordinateMe) / 1609.0)
                            let distanceF = Int(coordinateF.distance(from: coordinateMe) / 1609.0)
                            return distanceF > distanceS
                        })
                        
                        filteredEvents.sort(by: { (second, first) -> Bool in
                            let coordinateS = CLLocation(latitude: second.latitude, longitude: second.longitude)
                            let coordinateF = CLLocation(latitude: first.latitude, longitude: first.longitude)
                            let distanceS = Int(coordinateS.distance(from: coordinateMe) / 1609.0)
                            let distanceF = Int(coordinateF.distance(from: coordinateMe) / 1609.0)
                            return distanceF > distanceS
                        })
                    } else {
                        events.sort(by: { (first, second) -> Bool in
                            let coordinateS = CLLocation(latitude: second.latitude, longitude: second.longitude)
                            let coordinateF = CLLocation(latitude: first.latitude, longitude: first.longitude)
                            let distanceS = Int(coordinateS.distance(from: coordinateMe) / 1609.0)
                            let distanceF = Int(coordinateF.distance(from: coordinateMe) / 1609.0)
                            return distanceF > distanceS
                            return first.name.lowercased() > second.name.lowercased()
                        })
                        
                        filteredEvents.sort(by: { (first, second) -> Bool in
                            let coordinateS = CLLocation(latitude: second.latitude, longitude: second.longitude)
                            let coordinateF = CLLocation(latitude: first.latitude, longitude: first.longitude)
                            let distanceS = Int(coordinateS.distance(from: coordinateMe) / 1609.0)
                            let distanceF = Int(coordinateF.distance(from: coordinateMe) / 1609.0)
                            return distanceF > distanceS
                        })
                    }
                }
            case "date":
                if value {
                    events.sort(by: { (second, first) -> Bool in
                        return first.date > second.date
                    })
                    
                    filteredEvents.sort(by: { (second, first) -> Bool in
                        return first.date > second.date
                    })
                } else {
                    events.sort(by: { (first, second) -> Bool in
                        return first.date > second.date
                    })
                    
                    filteredEvents.sort(by: { (first, second) -> Bool in
                        return first.date > second.date
                    })
                }
            case "sugg":
                if value {
                    events = events.filter({ (event) -> Bool in
                        if let tags = event.tags {
                            return tags.contains("social")
                        }
                        return false
                    })
                    filteredEvents = filteredEvents.filter({ (event) -> Bool in
                        if let tags = event.tags {
                            return tags.contains("social")
                        }
                        return false
                    })
                }
            default:
                continue
            }
        }
        var past = false
        var current = false
        var future = false
        if filters["past"] != nil {
            past = filters["past"]!
        }
        
        if filters["current"] != nil {
            current = filters["current"]!
        }
        
        if filters["future"] != nil {
            future = filters["future"]!
        }
        
        if ((!past && !current && !future) || (past && current && future)) {
            tableView.reloadData()
            return
        }
        if past && current {
            events = events.filter({ (event) -> Bool in
                return event.date <= Date().timeIntervalSinceReferenceDate
            })
            filteredEvents = filteredEvents.filter({ (event) -> Bool in
                return event.date <= Date().timeIntervalSinceReferenceDate
            })
        } else if current, future {
            events = events.filter({ (event) -> Bool in
                return event.date >= Date().timeIntervalSinceReferenceDate
            })
            filteredEvents = filteredEvents.filter({ (event) -> Bool in
                return event.date >= Date().timeIntervalSinceReferenceDate
            })
        } else if past, future {
            events = events.filter({ (event) -> Bool in
                return event.endDate < Date().timeIntervalSinceReferenceDate || event.date > Date().timeIntervalSinceReferenceDate
            })
            filteredEvents = filteredEvents.filter({ (event) -> Bool in
                return event.endDate < Date().timeIntervalSinceReferenceDate || event.date > Date().timeIntervalSinceReferenceDate
            })
        } else if past {
            events = events.filter({ (event) -> Bool in
                return event.endDate < Date().timeIntervalSinceReferenceDate
            })
            filteredEvents = filteredEvents.filter({ (event) -> Bool in
                return event.endDate <= Date().timeIntervalSinceReferenceDate
            })
        } else if current {
            events = events.filter({ (event) -> Bool in
                return event.date <= Date().timeIntervalSinceReferenceDate && event.endDate >= Date().timeIntervalSinceReferenceDate
            })
            filteredEvents = filteredEvents.filter({ (event) -> Bool in
                return event.date <= Date().timeIntervalSinceReferenceDate && event.endDate >= Date().timeIntervalSinceReferenceDate
            })
        } else if future {
            events = events.filter({ (event) -> Bool in
                return event.date > Date().timeIntervalSinceReferenceDate
            })
            filteredEvents = filteredEvents.filter({ (event) -> Bool in
                return event.date > Date().timeIntervalSinceReferenceDate
            })
        }
        
        
        
        tableView.reloadData()
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
