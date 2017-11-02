//
//  RatingViewController.swift
//  EventUp!
//
//  Created by Jackson Didat on 10/4/17.
//  Copyright © 2017 Siraj Zaneer. All rights reserved.
//

import UIKit
import FirebaseAuth

class RatingViewController: UIViewController {

    @IBOutlet weak var displayRating:UILabel!
    
    var rating:Int = 0
    var event: Event!
    var delegate: FilterDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func oneStar(_ sender: Any) {
        rating = 1;
        print(rating)
        displayRating.text = "You rated this event 1 star"
        rate(value: 1.0)
    }
    @IBAction func twoStar(_ sender: Any) {
        rating = 2;
        print(rating)
        displayRating.text = "You rated this event 2 stars"
        rate(value: 2.0)
    }
    @IBAction func threeStar(_ sender: Any) {
        rating = 3;
        print(rating)
        displayRating.text = "You rated this event 3 stars"
        rate(value: 3.0)
    }
    @IBAction func fourStar(_ sender: Any) {
        rating = 4;
        print(rating)
        displayRating.text = "You rated this event 4 stars"
        rate(value: 4.0)
    }
    @IBAction func fiveStar(_ sender: Any) {
        rating = 5;
        print(rating)
        displayRating.text = "You rated this event 5 stars"
        rate(value: 5.0)
    }
    
    
    func rate(value :Double) {
        EventUpClient.sharedInstance.rateEvent(rating: value, event: event, uid: Auth.auth().currentUser!.uid, success: { (newRating) in
            self.event.ratingCount = self.event.ratingCount + 1
            self.event.rating = newRating
            
            self.delegate.refresh(event: nil)
            self.navigationController?.popViewController(animated: true)
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
