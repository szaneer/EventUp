//
//  EventCreateViewController.swift
//  EventUp!
//
//  Created by Siraj Zaneer on 9/28/17.
//  Copyright © 2017 Siraj Zaneer. All rights reserved.
//

import UIKit
import Firebase

class EventCreateViewController: UIViewController {

    @IBOutlet weak var eventView: UIImageView!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var locationField: UITextField!
    @IBOutlet weak var dateField: UIDatePicker!
    @IBOutlet weak var tagsField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onCreate(_ sender: Any) {
        validateInput()
        var eventInfo = [String: String]()
        eventInfo["Name"] = nameField.text
        eventInfo["Location"] = locationField.text
        eventInfo["Tags"] = tagsField.text
        let date = dateField.date.timeIntervalSince1970.magnitude
        eventInfo["Date"] = String(date)
        EventUpClient.sharedInstance.createEvent(eventData: eventInfo, success: { (event) in
            print("Success")
        }) { (error) in
            print(error)
        }
    }
    
    func validateInput() {
        guard let name = nameField.text, !name.isEmpty else {
            return //Need to check if there is a first and last name
        }
        guard let location = locationField.text, !location.isEmpty else {
            return
        }
        guard let tags = tagsField.text, !tags.isEmpty else {
            return //Could have no tags?
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
