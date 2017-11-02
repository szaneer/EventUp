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
    
    override func viewWillAppear(_ animated: Bool) {
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
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 2
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)!
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
        
        tableView.deselectRow(at: indexPath, animated: true)
        
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
