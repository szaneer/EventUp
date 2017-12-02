//
//  EventLocationSelectViewController.swift
//  EventUp!
//
//  Created by Siraj Zaneer on 10/19/17.
//  Copyright © 2017 Siraj Zaneer. All rights reserved.
//

import UIKit
import MapKit

class EventLocationSelectViewController: UIViewController {

    @IBOutlet weak var eventLocationView: MKMapView!
    
    var delegate: EventLocationSelectViewControllerDelegate!
    let locationManger = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        locationManger.startUpdatingLocation()
    }
    
    @IBAction func onSelect(_ sender: Any) {
        let alert = UIAlertController(title: "Confirm", message: "Are you sure this is the location?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
            self.delegate.setLocation(coordinate: self.eventLocationView.centerCoordinate)
            self.dismiss(animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        guard let identifier = segue.identifier else {
            return
        }
        
        switch identifier {
        case "tagSelectSegue":
            print("hsads")
        default:
            return
        }
    }
    

}
