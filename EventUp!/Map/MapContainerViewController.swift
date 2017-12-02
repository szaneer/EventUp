//
//  MapContainerViewController.swift
//  EventUp!
//
//  Created by Siraj Zaneer on 12/1/17.
//  Copyright © 2017 Siraj Zaneer. All rights reserved.
//

import UIKit
import SidebarOverlay

class MapContainerViewController: SOContainerViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.menuSide = .left
        self.topViewController = self.storyboard?.instantiateViewController(withIdentifier: "mapMain")
        self.sideViewController = self.storyboard?.instantiateViewController(withIdentifier: "mapSidebar")
        ((self.sideViewController as! UINavigationController).topViewController! as! MapSidebarViewController).delegate = ((self.topViewController as! UINavigationController).topViewController! as! MapViewController)
    }

}
