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
            tableView.reloadData()
        }
    }
    
    var myBoughtItems: [Item] = [] {
        didSet {
//            tableView.reloadSections(<#sections: NSIndexSet#>, withRowAnimation: <#UITableViewRowAnimation#>)
        }
    }
    
    var friendUnboughtItems: [PFUser : [Item]]?
    
    
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
        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // TODO: return actual number
        return myUnboughtItems.count
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
}

extension ListViewController: UITableViewDelegate {
    
    
    
}