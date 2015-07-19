//
//  FriendViewController.swift
//  ShareMyList
//
//  Created by Claire Huang on 7/18/15.
//  Copyright (c) 2015 ShareMyListAwesomeness. All rights reserved.
//

import UIKit
import Parse

class FriendViewController: UIViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    //stores all the users that match the current search query
    var users: [PFUser]? {
        didSet {
            tableView.reloadData()
        }
    }

    
    var addedFriends: [PFUser]? {
        didSet {
            tableView.reloadData()
        }
    }
    
    var query: PFQuery? {
        didSet {
            oldValue?.cancel()
        }
    }
    
    enum State {
        case DefaultMode
        case SearchMode
    }
    
    var state: State = .DefaultMode {
        didSet{
            switch (state) {
            case .DefaultMode:
                query = ParseHelper.allUsers(updateList)
                
            case .SearchMode:
                let searchText = searchBar?.text ?? ""
                query = ParseHelper.searchUsers(searchText, completionBlock: updateList)
            }
        }
    }
    
    func updateList(results: [AnyObject]?, error: NSError?) {
        self.users = results as? [PFUser] ?? []
        
        tableView.reloadData()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        state = .DefaultMode
        
        ParseHelper.getFriendsForUser(PFUser.currentUser()!) {
            (results: [AnyObject]?, error: NSError?) -> Void in
            // relations = [friend objects]
            let relations = results as? [PFObject] ?? []
            
            self.addedFriends = relations.map {
                $0[ParseHelper.ParseFriendToUser] as! PFUser
            }
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        // Do any additional setup after loading the view.
    }
    
}

extension FriendViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection seciton: Int) -> Int {
        return self.users?.count ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Friend Cell", forIndexPath: indexPath) as! FriendTableViewCell
        
        let user = users![indexPath.row]
        cell.friend = user
        
        if let addedFriends = addedFriends {
            cell.isFriended = contains(addedFriends, user)
        }
        
        cell.delegate = self
        return cell
    }
    
    
    
}

extension FriendViewController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
        state = .SearchMode
        
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        ParseHelper.searchUsers(searchText, completionBlock:updateList)
    }
    
}

extension FriendViewController: FriendTableViewCellSelectionDelegate {
    func cell(cell: FriendTableViewCell, didSelectFriendUser user: PFUser) {
        ParseHelper.addFriendFromUser(PFUser.currentUser()!, toUser: user)
        
        addedFriends?.append(user)
    }
    
    func cell(cell: FriendTableViewCell, didSelectUnfriendUser user: PFUser) {
        
        if var addedFriends = addedFriends {
            ParseHelper.removeFriendFromUser(PFUser.currentUser()!, toUser: user)
            
            //removeObject(user, fromArray: &addedFriends)
            self.addedFriends = addedFriends
        }
    }
}

extension FriendViewController: UITableViewDelegate {
    
    
    
}