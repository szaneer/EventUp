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
    var filter: [String: Bool] = [:]
    var isSugg = false
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if (!isSugg) {
            
            delegate.refresh(event: nil)
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 5
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if section == 4 {
            return 1
        }
        if section == 3 {
            return 3
        }
        return 2
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)!
        tableView.deselectRow(at: indexPath, animated: true)
        
        if (indexPath.section == 4) {
            if (cell.accessoryType == .checkmark) {
                cell.accessoryType = .none
                filter["sugg"] = false
                delegate.filter(filters: filter)
            } else {
                cell.accessoryType = .checkmark
                filter["sugg"] = true
                delegate.filter(filters: filter)
            }
            return
        } else if indexPath.section == 3 {
            switch indexPath.row {
            case 0:
                if (cell.accessoryType == .checkmark) {
                    cell.accessoryType = .none
                    filter["past"] = false
                    delegate.filter(filters: filter)
                } else {
                    cell.accessoryType = .checkmark
                    filter["past"] = true
                    delegate.filter(filters: filter)
                }
            case 1:
                if (cell.accessoryType == .checkmark) {
                    cell.accessoryType = .none
                    filter["current"] = false
                    delegate.filter(filters: filter)
                } else {
                    cell.accessoryType = .checkmark
                    filter["current"] = true
                    delegate.filter(filters: filter)
                }
            case 2:
                if (cell.accessoryType == .checkmark) {
                    cell.accessoryType = .none
                    filter["future"] = false
                    delegate.filter(filters: filter)
                } else {
                    cell.accessoryType = .checkmark
                    filter["future"] = true
                    delegate.filter(filters: filter)
                }
            default:
                break
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
                filter["name"] = true
                delegate.filter(filters: filter)
            } else {
                filter["name"] = false
                delegate.filter(filters: filter)
            }
        case 1:
            if indexPath.row == 0 {
                filter["distance"] = true
                delegate.filter(filters: filter)
            } else {
                filter["distance"] = false
                delegate.filter(filters: filter)
            }
        case 2:
            if indexPath.row == 0 {
                filter["date"] = true
                delegate.filter(filters: filter)
            } else {
                filter["date"] = false
                delegate.filter(filters: filter)
            }
        default:
            return
        }
        
    }
}
