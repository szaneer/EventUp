//
//  WelcomeViewController.swift
//  EventUp!
//
//  Created by Siraj Zaneer on 11/7/17.
//  Copyright © 2017 Siraj Zaneer. All rights reserved.
//

import UIKit

class WelcomeViewController: UIViewController {

    @IBOutlet weak var welcomeLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        UIView.animate(withDuration: 1, animations: {
            self.welcomeLabel.transform = CGAffineTransform(scaleX: 5.0, y: 5.0)
        }) { (finished) in
            self.performSegue(withIdentifier: "mainSegue", sender: nil)
        }
    }
}
