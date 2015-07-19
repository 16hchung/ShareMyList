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
    
    var myUnboughtItems: [Item] = []
    var myBoughtItems: [Item] = []
    var friendUnboughtItems: [PFUser : [Item]] = [:]
    
    // TODO: MAKE THESE NOT HARDCODED VALUES
    var atLocation: Bool = true
    var currentStoreType: String = "grocery"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.estimatedRowHeight = 88
        tableView.rowHeight = UITableViewAutomaticDimension
        
        addListItemButton.enabled = false
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        reloadItemsData()
    }
    
    private func reloadItemsData() {
        reloadUnboughtItems()
        reloadBoughtItems()
        if atLocation { reloadFriendItems() }
    }
    
    private func reloadUnboughtItems() {
        if (atLocation) {
            ParseHelper.filteredItemsCreatedByUser(PFUser.currentUser()!, filter: currentStoreType) { (result: [AnyObject]?, error: NSError?) -> Void in
                self.myUnboughtItems = result as? [Item] ?? []
                self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.Top)
            }
        } else {
            ParseHelper.unboughtItemsCreatedByUser(PFUser.currentUser()!) { (result: [AnyObject]?, error: NSError?) -> Void in
                self.myUnboughtItems = result as? [Item] ?? []
                self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.Top)
            }
        }
    }
    
    private func reloadBoughtItems() {
        ParseHelper.boughtItemsCreatedByUser(PFUser.currentUser()!) { (result: [AnyObject]?, error: NSError?) -> Void in
            self.myBoughtItems = result as? [Item] ?? []
            self.tableView.reloadSections(NSIndexSet(index: 1), withRowAnimation: UITableViewRowAnimation.Top)
        }
    }
    
    private func reloadFriendItems() {
        var friends = [PFUser]()
        
        ParseHelper.getFriendsForUser(PFUser.currentUser()!) { (result: [AnyObject]?, error: NSError?) -> Void in
            let results = result as? [PFObject] ?? []
            friends = results.map { $0.objectForKey(ParseHelper.ParseFriendToUser) as! PFUser }
            
            for i in 0..<friends.count {
                let friend = friends[i]
                println(friend)
                ParseHelper.filteredItemsCreatedByUser(friend, filter: self.currentStoreType) { (result: [AnyObject]?, error: NSError?) -> Void in
                    self.friendUnboughtItems[friend] = result as? [Item]
//                    self.tableView.reloadSections(NSIndexSet(index: i + 2), withRowAnimation: UITableViewRowAnimation.Top)
//                    println(result)
                    self.tableView.reloadData()
                }
            }
        }
    }

    
    // MARK: IBActions
    
    
    @IBAction func editedItemToAdd(sender: UITextField) {
        if addListItemTextField.text != "" {
            addListItemButton.enabled = true
        } else {
            addListItemButton.enabled = false
        }
    }
    
    @IBAction func addListItem(sender: UIButton) {
        // load item into parse
        var addedItem = Item()
        addedItem.text = addListItemTextField.text
        addedItem.saveItem() { (success, error) in
            // deal with textField appearance + keyboard stuff
            self.addListItemTextField.text = ""
            self.addListItemButton.enabled = false
            self.addListItemTextField.resignFirstResponder()
            
            // edit tableView
            ParseHelper.unboughtItemsCreatedByUser(PFUser.currentUser()!) { (result: [AnyObject]?, error: NSError?) -> Void in
                self.myUnboughtItems = result as? [Item] ?? []
                self.insertNewItemInSection(0)
            }

        }
        
    }
    
    private func insertNewItemInSection(section: Int) {
        // create index paths being inserted/deleted
        var paths = [NSIndexPath]()
        paths.append(NSIndexPath(forRow: 0, inSection: section))
        
        // animate row insertion/deletion
        tableView.beginUpdates()
        tableView.insertRowsAtIndexPaths(paths, withRowAnimation: UITableViewRowAnimation.Top)
        tableView.endUpdates()
    }
    
    private func deleteItemInSection(section: Int) {
        // create index paths being inserted/deleted
        var paths = [NSIndexPath]()
        paths.append(NSIndexPath(forRow: 0, inSection: section))
        
        // animate row insertion/deletion
        tableView.beginUpdates()
        tableView.deleteRowsAtIndexPaths(paths, withRowAnimation: UITableViewRowAnimation.Top)
        tableView.endUpdates()
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
            cell.userInteractionEnabled = true
        case 1:
            cell.listItem = myBoughtItems[indexPath.row]
            cell.userInteractionEnabled = false
        default:
            let friendKey = friendUnboughtItems.keys.array[indexPath.section - 2]
            let friendItems = friendUnboughtItems[friendKey]!
            cell.listItem = friendItems[indexPath.row]
            cell.userInteractionEnabled = true
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "To Buy"
        case 1:
            return "Bought"
        default:
            let friendKey = friendUnboughtItems.keys.array[section - 2]
            return friendKey.username
        }
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
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch indexPath.section {
        case 0: // unbought
            let item = myUnboughtItems[indexPath.row]
            item.toggleBought(true) { (success, error) in
                if (self.atLocation) {
                    ParseHelper.filteredItemsCreatedByUser(PFUser.currentUser()!, filter: self.currentStoreType) { (result: [AnyObject]?, error: NSError?) -> Void in
                        self.myUnboughtItems = result as? [Item] ?? []
                        self.deleteItemInSection(0)
                    }
                } else {
                    ParseHelper.unboughtItemsCreatedByUser(PFUser.currentUser()!) { (result: [AnyObject]?, error: NSError?) -> Void in
                        self.myUnboughtItems = result as? [Item] ?? []
                        self.deleteItemInSection(0)
                    }
                }
                
                ParseHelper.boughtItemsCreatedByUser(PFUser.currentUser()!) { (result: [AnyObject]?, error: NSError?) -> Void in
                    self.myBoughtItems = result as? [Item] ?? []
                    self.insertNewItemInSection(1)
                }
            }
        case 1: // bought
            return
        default: // friends unbought
            let friend = friendUnboughtItems.keys.array[indexPath.section - 2]
            let friendItems = friendUnboughtItems[friend]
            let item = friendItems![indexPath.row]
            item.toggleBought(true) { (success, error) in
                // QUERY
                var friends = [PFUser]()
                
                ParseHelper.getFriendsForUser(PFUser.currentUser()!) { (result: [AnyObject]?, error: NSError?) -> Void in
                    let results = result as? [PFObject] ?? []
                    friends = results.map { $0.objectForKey(ParseHelper.ParseFriendToUser) as! PFUser }
                    
                    for i in 0..<friends.count {
                        let friend = friends[i]
                        ParseHelper.filteredItemsCreatedByUser(friend, filter: self.currentStoreType) { (result: [AnyObject]?, error: NSError?) -> Void in
                            self.friendUnboughtItems[friend] = result as? [Item]
                            self.deleteItemInSection(i + 2)
                            self.tableView.reloadData()
                        }
                    }
                }
            }
        }
        
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
    }
}