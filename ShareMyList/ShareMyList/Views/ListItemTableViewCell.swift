//
//  ListItemTableViewCell.swift
//  ShareMyList
//
//  Created by Claire Huang on 7/18/15.
//  Copyright (c) 2015 ShareMyListAwesomeness. All rights reserved.
//

import UIKit
import Parse

class ListItemTableViewCell: UITableViewCell {

    @IBOutlet weak var listItemLabel: UILabel!
    @IBOutlet weak var checkBoxButton: UIButton!
    
    @IBOutlet weak var buyerLabel: UILabel!
    
    var listItem: Item! {
        didSet {
            listItemLabel.text = listItem.text
            updateIsBought()
            
            if let user = PFUser.currentUser() {
                if listItem.isBought && user != listItem.boughtBy {
                    buyerLabel.text = listItem.boughtBy!.username
                } else {
                    buyerLabel.removeFromSuperview()
                }
            }
        }
    }
    
    func updateIsBought() {        
        // change text color
        if listItem.isBought {
            listItemLabel.textColor = UIColor.grayColor()
            checkBoxButton.imageView?.image = UIImage(named: "checked box")
        } else {
            listItemLabel.textColor = UIColor.blackColor()
            checkBoxButton.imageView?.image = UIImage(named: "unchecked box")
        }
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
