//
//  EventContainerViewController.swift
//  EventUp!
//
//  Created by Siraj Zaneer on 11/20/17.
//  Copyright © 2017 Siraj Zaneer. All rights reserved.
//

import UIKit
import SidebarOverlay
import RevealingSplashView

class EventContainerViewController: SOContainerViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.menuSide = .left
        self.topViewController = self.storyboard?.instantiateViewController(withIdentifier: "eventMain")
        self.sideViewController = self.storyboard?.instantiateViewController(withIdentifier: "eventSidebar")
        ((sideViewController as! UINavigationController).topViewController as! FilterViewController).delegate = ((topViewController as! UINavigationController).topViewController as! EventsViewController)
        
        
    }

}
