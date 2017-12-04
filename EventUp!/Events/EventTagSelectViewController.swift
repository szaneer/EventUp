//
//  EventTagSelectViewController.swift
//  EventUp!
//
//  Created by Siraj Zaneer on 10/26/17.
//  Copyright © 2017 Siraj Zaneer. All rights reserved.
//

import UIKit

class EventTagSelectViewController: UITableViewController {

    var delegate: EventTagSelectViewControllerDelegate!
    
    var index: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        let cell = tableView.cellForRow(at: indexPath)
        delegate.setTag(tag: cell!.textLabel!.text!, index: index)
        navigationController?.popViewController(animated: true)
    }

}
