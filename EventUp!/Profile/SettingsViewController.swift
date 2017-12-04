//
//  SettingsViewController.swift
//  EventUp!
//
//  Created by Siraj Zaneer on 10/29/17.
//  Copyright © 2017 Siraj Zaneer. All rights reserved.
//

import UIKit
import Firebase

class SettingsViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var autoSwitch: UISwitch!
    @IBOutlet weak var distanceField: UITextField!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var logoutButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        distanceField.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        autoSwitch.isOn = GeolocationClient.sharedInstance.isActive
        distanceField.text = "\(GeolocationClient.sharedInstance.radius / 1.60934)"
    }
    @IBAction func onLogout(_ sender: Any) {
        let alert = UIAlertController(title: "Logout", message: "Are you sure you want to logout?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
            
            try! Auth.auth().signOut()
            self.performSegue(withIdentifier: "loginSegue", sender: nil)
        }))
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func onDelete(_ sender: Any) {
        let alert = UIAlertController(title: "Delete account", message: "Are you sure you want to delete your account?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
            EventUpClient.sharedInstance.deleteUser(uid: Auth.auth().currentUser!.uid, success: {
                Auth.auth().currentUser?.delete(completion: { (erorr) in
                    
                    self.performSegue(withIdentifier: "loginSegue", sender: nil)
                })
            }) { (error) in
                print(error)
            }
        }))
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func onTap(_ sender: Any) {
        view.endEditing(true)
    }
    
    @IBAction func onRSVPswitch(_ sender: Any) {
        GeolocationClient.sharedInstance.isActive = !GeolocationClient.sharedInstance.isActive
        UserDefaults.standard.set(GeolocationClient.sharedInstance.isActive, forKey: "checkin")
        UserDefaults.standard.synchronize()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        let alert = UIAlertController(title: "Error", message: "Enter valid distance in miles.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        if let text = textField.text {
            if let value = Double(text) {
                GeolocationClient.sharedInstance.radius = value * 1.60934
                UserDefaults.standard.set(GeolocationClient.sharedInstance.isActive, forKey: "radius")
                UserDefaults.standard.synchronize()
            } else {
                present(alert, animated: true, completion: {
                    self.distanceField.becomeFirstResponder()
                })
            }
        } else {
            present(alert, animated: true, completion: {
                self.distanceField.becomeFirstResponder()
            })
        }
    }
}
