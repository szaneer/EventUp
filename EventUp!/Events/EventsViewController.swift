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
import RevealingSplashView

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
    
    @IBOutlet weak var sidebarButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let revealingSplashView = RevealingSplashView(iconImage: UIImage(named: "icon")!,iconInitialSize: CGSize(width: 70, height: 70), backgroundColor: UIColor(red:54.0/255.0, green:100.0/255.0, blue:183.0/255.0, alpha:1.0))
        revealingSplashView.animationType = SplashAnimationType.squeezeAndZoomOut
        
        let window = UIApplication.shared.keyWindow
        window?.insertSubview(revealingSplashView, aboveSubview: tabBarController!.view)
        
        //Starts animation
        
        revealingSplashView.startAnimation(){
            
            let sidebarIcon = UIImageView(image: UIImage(named: "sidebarIcon"))
            sidebarIcon.frame = CGRect(x: 0, y: 0, width: self.sidebarButton.frame.height, height: self.sidebarButton.frame.height)
            self.sidebarButton.frame = CGRect(x: 0, y: 0, width: self.sidebarButton.frame.height, height: self.sidebarButton.frame.height)
            self.sidebarButton.addSubview(sidebarIcon)
            
            let background = UIImage(named: "background")!
            self.navigationController!.navigationBar.setBackgroundImage(background, for: .default)
            
            self.navigationController!.navigationBar.tintColor = .black
            if (UserDefaults.standard.object(forKey: "notifyUID") != nil) {
                self.performSegue(withIdentifier: "notifySegue", sender: nil)
                return
            }
            
            //tableView.backgroundColor = .clear
            self.searchController.searchBar.scopeButtonTitles = ["All", "Social", "Learning", "Other"]
            
            self.searchController.searchResultsUpdater = self
            self.searchController.searchBar.delegate = self
            self.searchController.searchBar.placeholder = "Search Events"
            self.searchController.obscuresBackgroundDuringPresentation = false
            
            self.tableView.rowHeight = UITableViewAutomaticDimension
            self.tableView.estimatedRowHeight = 116
            
            self.definesPresentationContext = true
            self.navigationItem.searchController = self.searchController
            
            SVProgressHUD.show()
            
            
            self.refreshControl = UIRefreshControl()
            self.refreshControl?.addTarget(self, action: #selector(self.loadEvents), for: .valueChanged)
            
            self.setupLocation()
            self.view.isUserInteractionEnabled = false
            SVProgressHUD.show()
            self.loadEvents()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadEvents()
    }
    
    @objc func loadEvents() {
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
        so_containerViewController?.isSideViewControllerPresented = !so_containerViewController!.isSideViewControllerPresented
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
            
            let detailSegue = segue as! DetailSegue
            detailSegue.event = event
            detailSegue.index = indexPath.row
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
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
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
