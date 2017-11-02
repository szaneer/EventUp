//
//  FilterViewController.swift
//  EventUp!
//
//  Created by Siraj Zaneer on 9/27/17.
//  Copyright © 2017 Siraj Zaneer. All rights reserved.
//

import UIKit

class FilterViewController: UITableViewController, UINavigationBarDelegate {

    var delegate: FilterDelegate!
    
    var filter: [String: Any]!
    
    override func viewDidAppear(_ animated: Bool) {
        for (key, value) in filter {
            let valBool = value as! Bool
            switch key {
            case "name":
                if (valBool) {
                    let indexPath = IndexPath(row: 0, section: 0)
                    tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
                } else {
                    let indexPath = IndexPath(row: 1, section: 0)
                    tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
                }
            case "distance":
                if (valBool) {
                    let indexPath = IndexPath(row: 0, section: 1)
                    tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
                } else {
                    let indexPath = IndexPath(row: 1, section: 1)
                    tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
                }
            case "date":
                if (valBool) {
                    let indexPath = IndexPath(row: 0, section: 2)
                    tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
                } else {
                    let indexPath = IndexPath(row: 1, section: 2)
                    tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
                }
            case "past":
                if (valBool) {
                    let indexPath = IndexPath(row: 0, section: 3)
                    tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
                }
            default:
                break
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        delegate.refresh(event: nil)
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 4
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if (section == 3) {
            return 1
        }
        return 2
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)!
        tableView.deselectRow(at: indexPath, animated: true)
        if (indexPath.section == 3) {
            if (cell.accessoryType == .checkmark) {
                cell.accessoryType = .none
                
                delegate.filter(type: "past", order: false)
            } else {
                cell.accessoryType = .checkmark
                
                delegate.filter(type: "past", order: true)
            }
            return
        }
        
        let row = indexPath.row
        let otherPath: IndexPath!
        if row == 0 {
            otherPath = IndexPath(row: indexPath.row + 1, section: indexPath.section)
        } else {
            otherPath = IndexPath(row: indexPath.row - 1, section: indexPath.section)
        }
        let otherCell = tableView.cellForRow(at: otherPath)!
        otherCell.accessoryType = UITableViewCellAccessoryType.none
        cell.accessoryType = UITableViewCellAccessoryType.checkmark
        
        
        
        switch indexPath.section {
        case 0:
            if indexPath.row == 0 {
                delegate.filter(type: "name", order: true)
            } else {
                delegate.filter(type: "name", order: false)
            }
        case 1:
            if indexPath.row == 0 {
                delegate.filter(type: "distance", order: true)
            } else {
                delegate.filter(type: "distance", order: false)
            }
        case 2:
            if indexPath.row == 0 {
                delegate.filter(type: "date", order: true)
            } else {
                delegate.filter(type: "date", order: false)
            }
        default:
            return
        }
        
    }
}
