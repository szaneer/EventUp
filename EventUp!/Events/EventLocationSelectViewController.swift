//
//  EventLocationSelectViewController.swift
//  EventUp!
//
//  Created by Siraj Zaneer on 10/19/17.
//  Copyright © 2017 Siraj Zaneer. All rights reserved.
//

import UIKit
import MapKit

protocol EventLocationSelectViewControllerDelegate {
    func setLocation(coordinate: CLLocationCoordinate2D)
}

class EventLocationSelectViewController: ViewController {

    @IBOutlet weak var eventLocationView: MKMapView!
    
    var delegate: EventLocationSelectViewControllerDelegate!
    let locationManger = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        locationManger.startUpdatingLocation()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onSelect(_ sender: Any) {
        delegate.setLocation(coordinate: eventLocationView.centerCoordinate)
        self.dismiss(animated: true, completion: nil)
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
