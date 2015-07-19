//
//  ListViewController.swift
//  ShareMyList
//
//  Created by Claire Huang on 7/18/15.
//  Copyright (c) 2015 ShareMyListAwesomeness. All rights reserved.
//

import UIKit
import Parse

class ListViewController: UIViewController {

    @IBOutlet weak var addListItemTextField: UITextField!
    @IBOutlet weak var addListItemButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    var myUnboughtItems: [Item] = [] {
        didSet {
//            tableView.reloadSections(<#sections: NSIndexSet#>, withRowAnimation: <#UITableViewRowAnimation#>)
        }
    }
    
    var myBoughtItems: [Item] = [] {
        didSet {
//            tableView.reloadSections(<#sections: NSIndexSet#>, withRowAnimation: <#UITableViewRowAnimation#>)
        }
    }
    
    var friendUnboughtItems: [PFUser : [Item]] = [:] {
        didSet {
//            tableView.reloadSections(<#sections: NSIndexSet#>, withRowAnimation: <#UITableViewRowAnimation#>)
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension ListViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("List Cell", forIndexPath: indexPath) as! ListItemTableViewCell
        
        switch indexPath.section {
        case 0:
            cell.listItem = myUnboughtItems[indexPath.row]
        case 1:
            cell.listItem = myBoughtItems[indexPath.row]
        default:
            let friendKey = friendUnboughtItems.keys.array[indexPath.section - 2]
            let friendItems = friendUnboughtItems[friendKey]!
            cell.listItem = friendItems[indexPath.row]
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        // TODO
        return nil
    }
    
    // section 0: unbought
    // section 1: bought
    // section 2+: friendUnbought
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return myUnboughtItems.count
        case 1:
            return myBoughtItems.count
        default:
            let friendKey = friendUnboughtItems.keys.array[section - 2]
            return friendUnboughtItems[friendKey]?.count ?? 0
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // 2 sections - 1 for myUnbought, 1 for myBought, however many for friendsUnbought
        return 2 + friendUnboughtItems.count
    }
}

extension ListViewController: UITableViewDelegate {
    
    
    
}