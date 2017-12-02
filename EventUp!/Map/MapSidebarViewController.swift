//
//  MapSidebarViewController.swift
//  EventUp!
//
//  Created by Siraj Zaneer on 12/2/17.
//  Copyright © 2017 Siraj Zaneer. All rights reserved.
//

import UIKit

class MapSidebarViewController: UITableViewController {

    var delegate: FilterDelegate!
    var filter: [String: Bool] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let background = UIImage(named: "background")!
        self.navigationController!.navigationBar.setBackgroundImage(background, for: .default)
        
        self.navigationController!.navigationBar.tintColor = .black
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 3
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let cell = tableView.cellForRow(at: indexPath)!
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
    }
}
