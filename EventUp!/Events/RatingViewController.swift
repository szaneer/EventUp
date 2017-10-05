//
//  RatingViewController.swift
//  EventUp!
//
//  Created by Jackson Didat on 10/4/17.
//  Copyright © 2017 Siraj Zaneer. All rights reserved.
//

import UIKit

class RatingViewController: UIViewController {
    
    var rating:Int = 0
    @IBOutlet weak var displayRating:UILabel!
    
    @IBAction func oneStar(_ sender: Any) {
        rating = 1;
        print(rating)
        displayRating.text = "You rated this event 1 star"
    }
    @IBAction func twoStar(_ sender: Any) {
        rating = 2;
        print(rating)
        displayRating.text = "You rated this event 2 stars"
    }
    @IBAction func threeStar(_ sender: Any) {
        rating = 3;
        print(rating)
        displayRating.text = "You rated this event 3 stars"
    }
    @IBAction func fourStar(_ sender: Any) {
        rating = 4;
        print(rating)
        displayRating.text = "You rated this event 4 stars"
    }
    @IBAction func fiveStar(_ sender: Any) {
        rating = 5;
        print(rating)
        displayRating.text = "You rated this event 5 stars"
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
