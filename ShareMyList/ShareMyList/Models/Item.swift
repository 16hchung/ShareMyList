//
//  Item.swift
//  ShareMyList
//
//  Created by Claire Huang on 7/18/15.
//  Copyright (c) 2015 ShareMyListAwesomeness. All rights reserved.
//

import Foundation
import Parse

class Item: PFObject, PFSubclassing {
    // MARK: properties from Parse
    
    @NSManaged var creator: PFUser
    @NSManaged var boughtBy: PFUser
    @NSManaged var text: String
    @NSManaged var category: String
    @NSManaged var isBought: Bool
    
    // MARK: categories
    
    static let itemCategoryDictionary: [String: String] = ["toothpaste" : "drugstore", "apples" : "grocery store"]
    
    /// set the category of the list item and save item to parse
    func saveItem(callback: PFBooleanResultBlock) {
        self.category = Item.itemCategoryDictionary[text] ?? "" // set the category
        self.saveInBackgroundWithBlock(callback)
    }
    
    // MARK: PFSubclassing Protocol
    
    static func parseClassName() -> String {
        return "Item"
    }
    
    override init() {
        super.init()
    }
    
    override class func initialize() {
        var onceToken : dispatch_once_t = 0;
        dispatch_once(&onceToken) {
            // inform Parse about this subclass
            self.registerSubclass()
        }
    }

}

