//
//  EventCell.swift
//  EventUp!
//
//  Created by Siraj Zaneer on 9/25/17.
//  Copyright © 2017 Siraj Zaneer. All rights reserved.
//

import UIKit

class EventCell: UITableViewCell {

    @IBOutlet weak var eventView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var tagLabel: UILabel!
    // added the attendees label here
    @IBOutlet weak var attendeesLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func draw(_ rect: CGRect) {
        let bubbleSpace = CGRect(x: 20.0, y: self.bounds.origin.y, width: self.bounds.width - 20, height: self.bounds.height)
        _ = UIBezierPath(roundedRect: bubbleSpace, byRoundingCorners: .bottomRight, cornerRadii: CGSize(width: 20.0, height: 20.0))
        
        let bubblePath = UIBezierPath(roundedRect: bubbleSpace, cornerRadius: 20.0)
        
        UIColor.green.setStroke()
        UIColor.green.setFill()
        bubblePath.stroke()
        bubblePath.fill()
        
        var triangleSpace = CGRect(x: 0.0, y: self.bounds.height - 20, width: 20, height: 20.0)
        var trianglePath = UIBezierPath()
        var startPoint = CGPoint(x: 20.0, y: self.bounds.height - 40)
        var tipPoint = CGPoint(x: 0.0, y: self.bounds.height - 30)
        var endPoint = CGPoint(x: 20.0, y: self.bounds.height - 20)
        trianglePath.move(to: startPoint)
        trianglePath.addLine(to: tipPoint)
        trianglePath.addLine(to: endPoint)
        trianglePath.close()
        UIColor.green.setStroke()
        UIColor.green.setFill()
        trianglePath.stroke()
        trianglePath.fill()
    }

}
