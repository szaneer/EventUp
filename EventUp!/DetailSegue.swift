//
//  DetailSegue.swift
//  Flicker
//
//  Created by Siraj Zaneer on 11/24/17.
//  Copyright © 2017 Siraj Zaneer. All rights reserved.
//

import UIKit

class DetailSegue: UIStoryboardSegue {
    
    var index: Int!
    var event: Event!
    
    override func perform() {
        let sourceController = source as! EventsViewController
        let indexPath = IndexPath(row: index, section: 0)
        let cell = sourceController.tableView.cellForRow(at: indexPath) as! EventCell
        
        let sourceView = source.view!
        let destinationView = destination.view!
        
        let window = UIApplication.shared.keyWindow
        
        let blurEffect = UIBlurEffect(style: .regular)
        let blurVisualEffectView = UIVisualEffectView(effect: blurEffect)
        blurVisualEffectView.frame = sourceView.bounds
        blurVisualEffectView.alpha = 0.0
        blurVisualEffectView.frame = blurVisualEffectView.frame.offsetBy(dx: 0, dy: (sourceController.navigationController?.navigationBar.frame.height ?? 0) + UIApplication.shared.statusBarFrame.height - sourceController.tableView.contentOffset.y)
        window?.insertSubview(blurVisualEffectView, aboveSubview: destinationView)
        
        cell.removeFromSuperview()
        cell.frame = cell.frame.offsetBy(dx: 0, dy: -sourceController.tableView.contentOffset.y)
        cell.backgroundColor = .clear
        
        window?.insertSubview(cell, aboveSubview: blurVisualEffectView)
        
        sourceController.tableView.separatorStyle = .none
        UIView.animate(withDuration: 0.4, animations: {
            cell.frame = CGRect(x: 0, y: (sourceController.navigationController?.navigationBar.frame.height ?? 0) + UIApplication.shared.statusBarFrame.height, width: cell.frame.width, height: cell.frame.height + 30)
            
            blurVisualEffectView.alpha = 1.0
        }) { (finished) in
            
            self.source.navigationController?.pushViewController(self.destination, animated: true)
            UIView.animate(withDuration: 0.4, animations: {
                cell.alpha = 0.0
                blurVisualEffectView.alpha = 0.0
            }, completion: { (finished) in
                    //                        destinationController.titleLabel.sizeToFit()
                    //                        destinationController.overviewLabel.sizeToFit()
                    //                        destinationController.titleLabel.isHidden = false
                    //                        destinationController.posterView.isHidden = false
                    //                        destinationController.overviewLabel.isHidden = false
                    blurVisualEffectView.removeFromSuperview()
                    cell.removeFromSuperview()
                    sourceController.tableView.dataSource = nil
                    sourceController.tableView.reloadData()
                    sourceController.tableView.dataSource = sourceController
                    sourceController.tableView.reloadData()
                    sourceController.tableView.separatorStyle = .singleLine
                    sourceView.isHidden = false
                
            })
        }
        
    }
}
