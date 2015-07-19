//
//  FriendTableViewCell.swift
//  ShareMyList
//
//  Created by Claire Huang on 7/18/15.
//  Copyright (c) 2015 ShareMyListAwesomeness. All rights reserved.
//

import UIKit
import Parse

protocol FriendTableViewCellSelectionDelegate: class {
    func cell(cell: FriendTableViewCell, didSelectFriendUser: PFUser)
    func cell(cell: FriendTableViewCell, didSelectUnfriendUser: PFUser)
}

class FriendTableViewCell: UITableViewCell {

    @IBOutlet weak var friendButton: UIButton!
    @IBOutlet weak var friendLabel: UILabel!
    
    weak var delegate: FriendTableViewCellSelectionDelegate?
    
    var friend: PFUser? {
        didSet {
            if friend != nil { friendLabel.text = friend?.username }
        }
    }
    
    var isFriended: Bool = false {
        didSet {
            friendButton.selected = isFriended
        }
    }
    
    @IBAction func friendButtonTapped(sender: AnyObject) {
        if isFriended {
            delegate?.cell(self, didSelectUnfriendUser: friend!)
        } else {
            delegate?.cell(self, didSelectFriendUser: friend!)
        }
        
        isFriended = !isFriended
    }
    
    
}
