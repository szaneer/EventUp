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
    @IBOutlet weak var latField: UITextField!
    @IBOutlet weak var longField: UITextField!
    @IBOutlet weak var infoView: UITextView!
    
    var editEvent: Event?
    var delegate: FilterDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if let editEvent = editEvent {
            setupEdit()
        }
    }

    func setupEdit() {
        nameField.text = editEvent?.name
        //eventInfo["Location"] = locationField.text
        tagsField.text = editEvent!.tags
        dateField.date = Date(timeIntervalSince1970: editEvent!.date)
        latField.text = editEvent!.latitude
        longField.text = editEvent!.longitude
        locationField.text = editEvent!.location
        infoView.text = editEvent!.info
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onCreate(_ sender: Any) {
        validateInput()
        var eventInfo = [String: Any]()
        eventInfo["name"] = nameField.text!
        //eventInfo["Location"] = locationField.text
        eventInfo["tags"] = tagsField.text!
        let date = Double(dateField.date.timeIntervalSince1970)
        eventInfo["date"] = date
        eventInfo["latitude"] = latField.text!
        eventInfo["longitude"] = longField.text!
        eventInfo["location"] = locationField.text!
        eventInfo["info"] = infoView.text
        guard let editEvent = editEvent else {
            EventUpClient.sharedInstance.createEvent(eventData: eventInfo, success: { (event) in
                let alert = UIAlertController(title: "Success!", message: "The event was created successfully", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: {(action: UIAlertAction!) in self.onSuccessfulEventCreation()}))
                self.present(alert, animated: true, completion: nil)
                
            }) { (error) in
                print(error)
            }
            return
        }
        EventUpClient.sharedInstance.editEvent(event: editEvent, eventData: eventInfo, success: { (event) in
            let alert = UIAlertController(title: "Success!", message: "The event was edited successfully", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: {(action: UIAlertAction!) in self.onSuccessfulEventCreation()}))
            self.present(alert, animated: true, completion: nil)
            
        }) { (error) in
            print(error)
        }
        return

    }
    
    func onSuccessfulEventCreation() {
        delegate.refresh(event: nil)
        self.navigationController?.popViewController(animated: true)
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
    
    @IBAction func onTouchScreen(_ sender: Any) {
        resignFirstResponder()
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
