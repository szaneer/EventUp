//
//  SettingsViewController.swift
//  EventUp!
//
//  Created by Siraj Zaneer on 10/29/17.
//  Copyright © 2017 Siraj Zaneer. All rights reserved.
//

import UIKit
import Firebase

class SettingsViewController: UIViewController {

    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var logoutButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onLogout(_ sender: Any) {
        try! Auth.auth().signOut()
        performSegue(withIdentifier: "loginSegue", sender: nil)
    }
    
    @IBAction func onDelete(_ sender: Any) {
        EventUpClient.sharedInstance.deleteUser(uid: Auth.auth().currentUser!.uid, success: {
            Auth.auth().currentUser?.delete(completion: { (erorr) in
                
                self.performSegue(withIdentifier: "loginSegue", sender: nil)
            })
        }) { (error) in
            print(error)
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
