//
//  EventAnnotationCalloutView.swift
//  EventUp!
//
//  Created by Siraj Zaneer on 12/3/17.
//  Copyright © 2017 Siraj Zaneer. All rights reserved.
//

import UIKit

class EventAnnotationCalloutView: UIView {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var navigateButton: UIButton!
    @IBOutlet weak var detailButton: UIButton!
    var event: Event!
}
