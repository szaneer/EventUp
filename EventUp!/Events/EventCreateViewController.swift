//
//  EventCreateViewController.swift
//  EventUp!
//
//  Created by Siraj Zaneer on 9/28/17.
//  Copyright © 2017 Siraj Zaneer. All rights reserved.
//

import UIKit
import Firebase
import AVFoundation
import MapKit
import SVProgressHUD

class EventCreateViewController: UIViewController {
    

    @IBOutlet weak var eventView: UIImageView!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var locationField: UITextField!
    @IBOutlet weak var dateField: UIDatePicker!
    @IBOutlet weak var infoView: UITextView!
    
    @IBOutlet weak var submitButton: UIButton!
    
    @IBOutlet weak var plusButton: UIButton!
    @IBOutlet var tagButtons: [UIButton]!
    
    var editEvent: Event?
    var delegate: FilterDelegate!
    var coordinate: CLLocationCoordinate2D?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if editEvent != nil {
            setupEdit()
            setupTags()
        }
    }

    func setupEdit() {
        nameField.text = editEvent!.name
        if let tags = editEvent!.tags {
            for index in 0..<tags.count {
                tagButtons[index].setTitle(tags[index], for: .normal)
            }
        }
        
        dateField.date = Date(timeIntervalSinceReferenceDate: editEvent!.date)
        let coordinate = CLLocationCoordinate2D(latitude: editEvent!.latitude, longitude: editEvent!.longitude)
        self.coordinate = coordinate
        locationField.text = editEvent!.location
        
        infoView.text = editEvent!.info
        
        if let image = editEvent!.image {
            eventView.image = EventUpClient.sharedInstance.base64DecodeImage(image)
        }
        
        submitButton.setTitle("Edit", for: .normal)
        submitButton.setTitle("Edit", for: .highlighted)
    }
    
    func setupTags() {
        guard let tags = editEvent!.tags else {
            return
        }
        
        for index in 0..<tags.count {
            tagButtons[index].setTitle(tags[index], for: .normal)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onCreate(_ sender: Any) {
        if (!validateInput()) {
            return
        }
        
        var eventInfo = [String: Any]()
        var tags: [String] = []
        
        for tagButton in  tagButtons {
            if tagButton.titleLabel!.text! != "+" {
               tags.append(tagButton.titleLabel!.text!)
            }
        }
        
        if tags.count > 0 {
            eventInfo["tags"] = tags
        }
        
        
        eventInfo["name"] = nameField.text!
        
        let date = Double(dateField.date.timeIntervalSinceReferenceDate)
        eventInfo["date"] = date
        
        eventInfo["latitude"] = coordinate!.latitude
        eventInfo["longitude"] = coordinate!.longitude
        eventInfo["location"] = locationField.text!
        
        eventInfo["info"] = infoView.text
        
        eventInfo["owner"] = Auth.auth().currentUser!.uid
        eventInfo["rsvpList"] = [Auth.auth().currentUser!.uid]
        
        guard let editEvent = editEvent else {
            EventUpClient.sharedInstance.createEvent(eventData: eventInfo, eventImage: eventView.image, success: { (event) in
                
                let alert = UIAlertController(title: "Success!", message: "The event was created successfully", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: {(action: UIAlertAction!) in self.onSuccessfulEventCreation()}))
                self.present(alert, animated: true, completion: nil)
                self.view.isUserInteractionEnabled = true
                SVProgressHUD.dismiss()
                
                self.dismiss(animated: true, completion: nil)
            }) { (error) in
                print(error)
            }
            return
        }
        
        EventUpClient.sharedInstance.editEvent(event: editEvent, eventData: eventInfo, eventImage: eventView.image, success: { (event) in
            let alert = UIAlertController(title: "Success!", message: "The event was edited successfully", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: {(action: UIAlertAction!) in self.onSuccessfulEventCreation()}))
            self.present(alert, animated: true, completion: nil)
            self.view.isUserInteractionEnabled = true
            SVProgressHUD.dismiss()
            self.dismiss(animated: true, completion: nil)
        }) { (error) in
            print(error)
        }
        
    }
    
    @IBAction func onCancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func onSuccessfulEventCreation() {
        delegate.refresh(event: nil)
        self.navigationController?.popViewController(animated: true)
    }
    
    func validateInput() -> Bool {
        view.isUserInteractionEnabled = false
        SVProgressHUD.show()
        
        guard let name = nameField.text, !name.isEmpty else {
            let alert = UIAlertController(title: "Error", message: "Enter an event name.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
            view.isUserInteractionEnabled = true
            SVProgressHUD.dismiss()
            return false
        }
        
        guard let location = locationField.text, !location.isEmpty else {
            let alert = UIAlertController(title: "Error", message: "Enter location name.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
            view.isUserInteractionEnabled = true
            SVProgressHUD.dismiss()
            return false
        }
        
        guard coordinate != nil else {
            let alert = UIAlertController(title: "Error", message: "Select a location.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
            view.isUserInteractionEnabled = true
            SVProgressHUD.dismiss()
            return false
        }
        
        guard let description = infoView.text, !description.isEmpty else {
            let alert = UIAlertController(title: "Error", message: "Enter event description.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
            view.isUserInteractionEnabled = true
            SVProgressHUD.dismiss()
            return false
        }
        
        return true
    }
    
   
    
    @IBAction func onTouchScreen(_ sender: Any) {
        view.endEditing(true)
    }
    
    @IBAction func onTag(_ sender: Any) {
        let sender = sender as! UIButton
        performSegue(withIdentifier: "tagSelectSegue", sender: sender.tag)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        guard let identifier = segue.identifier else {
            return
        }
        
        switch identifier {
        case "locationSelectSegue":
            let destination = segue.destination as! EventLocationSelectViewController
            destination.delegate = self
        case "tagSelectSegue":
            let destination = segue.destination as! EventTagSelectViewController
            
            destination.delegate = self
            destination.index = sender as! Int
        default:
            return
        }
    }
}

extension EventCreateViewController {
    func setLocation(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
    }
    
    
    func setTag(tag: String, index: Int) {
        tagButtons[index].setTitle(tag, for: .normal)
    }
    
}

extension EventCreateViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    @IBAction func onImage(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let image = info[UIImagePickerControllerEditedImage] as? UIImage else {
            picker.dismiss(animated: true, completion: nil)
            return
        }
        
        plusButton.setTitle("", for: .normal)
        plusButton.setTitle("", for: .highlighted)
        eventView.image = image
        picker.dismiss(animated: true, completion: nil)
        
    }
}

extension EventCreateViewController: EventLocationSelectViewControllerDelegate {
    
}

extension EventCreateViewController: EventTagSelectViewControllerDelegate {
    
}
