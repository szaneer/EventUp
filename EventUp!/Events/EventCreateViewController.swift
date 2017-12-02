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
import TextFieldEffects
import CoreML
import Vision

class EventCreateViewController: UIViewController {
    
    @IBOutlet weak var containingView: UIView!
    @IBOutlet weak var eventView: UIImageView!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var locationField: UITextField!
    @IBOutlet weak var infoView: UITextField!
    
    @IBOutlet weak var startDateButton: UIButton!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var endDateButton: UIButton!
    
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var plusButton: UIButton!
    @IBOutlet var tagButtons: [UIButton]!
    
    var editEvent: Event?
    var editImage: UIImage?
    var delegate: FilterDelegate!
    var coordinate: CLLocationCoordinate2D?
    var startDate = Date().timeIntervalSince1970
    var endDate = Date().timeIntervalSince1970 + 60
    let dateFormatter = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dateFormatter.dateFormat = "MM/dd/yyyy h:mma"
        dateFormatter.timeZone = Calendar.current.timeZone
        dateFormatter.locale = Calendar.current.locale
        
        let start = Date(timeIntervalSince1970: startDate)
        let end = Date(timeIntervalSince1970: endDate)
        startDateButton.setTitle("Start: \(dateFormatter.string(from: start))", for: .normal)
        endDateButton.setTitle("End: \(dateFormatter.string(from: end))", for: .normal)
        
        containingView.layer.borderColor = UIColor.lightGray.cgColor
        containingView.layer.borderWidth = 0.5
        
        infoView.delegate = self
        
        if editEvent != nil {
            setupEdit()
            setupTags()
        }
    }

    func setupEdit() {
        deleteButton.isHidden = false
        nameField.text = editEvent!.name
        if let tags = editEvent!.tags {
            for index in 0..<tags.count {
                tagButtons[index].setTitle(tags[index], for: .normal)
            }
        }
        
        
        let coordinate = CLLocationCoordinate2D(latitude: editEvent!.latitude, longitude: editEvent!.longitude)
        self.coordinate = coordinate
        locationField.text = editEvent!.location
        
        infoView.text = editEvent!.info
        
        if let image = editImage {
            eventView.image = image
            eventView.clipsToBounds = true
            eventView.layer.cornerRadius = 10
        }
        
        let start = Date(timeIntervalSince1970: editEvent!.date)
        let end = Date(timeIntervalSince1970: editEvent!.endDate)
        startDateButton.setTitle("Start: \(dateFormatter.string(from: start))", for: .normal)
        endDateButton.setTitle("End: \(dateFormatter.string(from: end))", for: .normal)
        self.endDate = editEvent!.endDate
        self.startDate = editEvent!.date
        
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
        
        let date = Double(startDate)
        let endDate = Double(self.endDate)
        eventInfo["date"] = date
        eventInfo["endDate"] = endDate
        
        eventInfo["latitude"] = coordinate!.latitude
        eventInfo["longitude"] = coordinate!.longitude
        eventInfo["location"] = locationField.text!
        
        eventInfo["info"] = infoView.text
        
        eventInfo["owner"] = Auth.auth().currentUser!.uid
        
        guard let editEvent = editEvent else {
            EventUpClient.sharedInstance.createEvent(eventData: eventInfo, eventImage: eventView.image, success: { (event) in
                
                let alert = UIAlertController(title: "Success!", message: "The event was created successfully", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: {(action: UIAlertAction!) in self.onSuccessfulEventCreation()}))
                self.present(alert, animated: true, completion: nil)
                self.view.isUserInteractionEnabled = true
                SVProgressHUD.dismiss()
                
                
            }) { (error) in
                print(error)
            }
            return
        }
        
        EventUpClient.sharedInstance.editEvent(event: editEvent, eventData: eventInfo, eventImage: eventView.image, success: {
            let alert = UIAlertController(title: "Success!", message: "The event was edited successfully", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: {(action: UIAlertAction!) in self.onSuccessfulEventCreation()}))
            self.present(alert, animated: true, completion: nil)
            self.view.isUserInteractionEnabled = true
            SVProgressHUD.dismiss()
        }) { (error) in
            print(error)
        }
        
    }
    
    func onSuccessfulEventCreation() {
        delegate.refresh(event: nil)
        navigationController?.popViewController(animated: true)
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
        
        if startDate > endDate {
            let alert = UIAlertController(title: "Error", message: "End date must be after start date.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
            view.isUserInteractionEnabled = true
            SVProgressHUD.dismiss()
            return false
        }
        
        return true
    }
    
    @IBAction func onDelete(_ sender: Any) {
        EventUpClient.sharedInstance.deleteEvent(event: editEvent!, success: {
            self.navigationController?.popToRootViewController(animated: true)
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    
    @IBAction func onTouchScreen(_ sender: Any) {
        view.endEditing(true)
    }
    
    @IBAction func onTag(_ sender: Any) {
        let sender = sender as! UIButton
        performSegue(withIdentifier: "tagSelectSegue", sender: sender.tag)
    }
    
    @IBAction func onStartDate(_ sender: Any) {
        performSegue(withIdentifier: "dateSegue", sender: createDateType.startDate)
    }
    
    @IBAction func onEndDate(_ sender: Any) {
        performSegue(withIdentifier: "dateSegue", sender: createDateType.endDate)
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
        case "dateSegue":
            let destination = segue.destination as! EventCreateCalendarViewController
            destination.delegate = self
            let type = sender as! createDateType
            destination.dateType = type
            if type == .startDate {
                destination.date = startDate
            } else {
                destination.date = endDate
            }
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
        eventView.layer.cornerRadius = 10
        eventView.clipsToBounds = true
        picker.dismiss(animated: true, completion: nil)
        
    }
}

extension EventCreateViewController: UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let text = textField.text {
            if text.lowercased().contains("social") {
                let alert = UIAlertController(title: "Tag", message: "EventUp thinks this might be a social event, want to add a tag for it?.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
                    self.setTag(tag: "Social", index: 0)
                }))
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
            } else if text.lowercased().contains("learning") {
                let alert = UIAlertController(title: "Tag", message: "EventUp thinks this might be a learning event, want to add a tag for it?.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
                    self.setTag(tag: "Learning", index: 0)
                }))
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
            } else {
                let alert = UIAlertController(title: "Tag", message: "EventUp thinks this might be an other event, want to add a tag for it?.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
                    self.setTag(tag: "Other", index: 0)
                }))
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
}

extension EventCreateViewController: EventLocationSelectViewControllerDelegate {
    
}

extension EventCreateViewController: EventTagSelectViewControllerDelegate {
    
}

extension EventCreateViewController: EventCreateCalendarDelegate {
    func setDate(date: TimeInterval, which: createDateType) {
        if which == .startDate {
            startDate = date
        } else {
            endDate = date
        }
        
        let start = Date(timeIntervalSince1970: startDate)
        let end = Date(timeIntervalSince1970: endDate)
        startDateButton.setTitle("Start: \(dateFormatter.string(from: start))", for: .normal)
        endDateButton.setTitle("End: \(dateFormatter.string(from: end))", for: .normal)
    }
}

protocol EventCreateCalendarDelegate {
    func setDate(date: TimeInterval, which: createDateType)
}

enum createDateType {
    case startDate
    case endDate
}
