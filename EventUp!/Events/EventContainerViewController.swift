//
//  EventContainerViewController.swift
//  EventUp!
//
//  Created by Siraj Zaneer on 11/20/17.
//  Copyright © 2017 Siraj Zaneer. All rights reserved.
//

import UIKit
import SidebarOverlay

class EventContainerViewController: SOContainerViewController, EventContainerViewControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.menuSide = .left
        self.topViewController = self.storyboard?.instantiateViewController(withIdentifier: "eventMain")
        ((topViewController as! UINavigationController).topViewController as! EventsViewController).delegate = self
        self.sideViewController = self.storyboard?.instantiateViewController(withIdentifier: "eventSidebar")
        (sideViewController as! FilterViewController).delegate = ((topViewController as! UINavigationController).topViewController as! EventsViewController)
    }

    func toggleSidebar() {
        so_containerViewController?.isSideViewControllerPresented = !so_containerViewController!.isSideViewControllerPresented
    }
}

protocol EventContainerViewControllerDelegate {
    func toggleSidebar()
}
