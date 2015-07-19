//
//  ParseHelper.swift
//  ShareMyList
//
//  Created by Claire Huang on 7/18/15.
//  Copyright (c) 2015 ShareMyListAwesomeness. All rights reserved.
//

import Foundation
import Parse

class ParseHelper {
    // MARK: Parse data model constants
    
    //Friend relation
    static let ParseFriendClass = "Friend"
    static let ParseFriendFromUser = "fromUser"
    static let ParseFriendToUser = "toUser"
    
    static let ParseUserUsername = "username"
    static let ParseItemClass = "Item"
    static let ParseItemCreator = "creator"
    static let ParseItemBoughtBy = "boughtBy"
    static let ParseItemIsBought = "isBought"
    static let ParseItemCategory = "category"
    static let ParseItemCreatedAt = "createdAt"
    static let ParseItemUpdatedAt = "updatedAt"
    
    // MARK: friends queries
    
    static func getFriendsForUser(user: PFUser, completionBlock: PFArrayResultBlock) {
        let query = PFQuery(className: ParseFriendClass)
        query.whereKey(ParseFriendFromUser, equalTo: user)
        query.findObjectsInBackgroundWithBlock(completionBlock)
    }
    
    static func addFriendFromUser(user: PFUser, toUser: PFUser) {
        let addFriend = PFObject(className: ParseFriendClass)
        addFriend.setObject(user, forKey: ParseFriendFromUser)
        addFriend.setObject(toUser, forKey: ParseFriendToUser)
        
        addFriend.saveInBackgroundWithBlock(nil)
    }
    
    static func removeFriendFromUser(user: PFUser, toUser: PFUser) {
        let query = PFQuery(className: ParseFriendClass)
        query.whereKey(ParseFriendFromUser, equalTo: user)
        query.whereKey(ParseFriendToUser, equalTo: toUser)
        
        query.findObjectsInBackgroundWithBlock {
            (results: [AnyObject]?, error: NSError?) -> Void in
            
            let results = results as? [PFObject] ?? []
            
            for friend in results {
                friend.deleteInBackgroundWithBlock(nil)
            }
        }
    }
    
    static func allUsers(completionBlock: PFArrayResultBlock) -> PFQuery {
        let query = PFUser.query()!
        // exclude the current user
        query.whereKey(ParseUserUsername, notEqualTo: PFUser.currentUser()!.username!)
        query.orderByAscending(ParseUserUsername)
        
        query.findObjectsInBackgroundWithBlock(completionBlock)
        
        return query
    }
    
    static func searchUsers(searchText: String, completionBlock: PFArrayResultBlock) -> PFQuery {
        let query = PFUser.query()!.whereKey(ParseUserUsername, matchesRegex: searchText, modifiers: "i")
        query.whereKey(ParseUserUsername, notEqualTo: PFUser.currentUser()!.username!)
        query.orderByAscending(ParseUserUsername)
        query.findObjectsInBackgroundWithBlock(completionBlock)
        
        return query
    }
    
    // MARK: items queries
    
    static func unboughtItemsCreatedByUser(user: PFUser, completionBlock: PFArrayResultBlock) {
        let query = PFQuery(className: ParseItemClass)
        query.whereKey(ParseItemCreator, equalTo: user)
        query.whereKey(ParseItemIsBought, equalTo: false)
        query.orderByDescending(ParseItemCreatedAt)
        query.includeKey(ParseItemBoughtBy)
        query.findObjectsInBackgroundWithBlock(completionBlock)
    }
    
    static func filteredItemsCreatedByUser(user: PFUser, filter category: String, completionBlock: PFArrayResultBlock) {
        let query = PFQuery(className: ParseItemClass)
        query.whereKey(ParseItemCreator, equalTo: user)
        query.whereKey(ParseItemIsBought, equalTo: false)
        query.whereKey(ParseItemCategory, equalTo: category)
        query.orderByDescending(ParseItemCreatedAt)
        query.includeKey(ParseItemCreator)
        query.includeKey(ParseItemBoughtBy)
        query.findObjectsInBackgroundWithBlock(completionBlock)
    }
    
    static func boughtItemsCreatedByUser(user: PFUser, completionBlock: PFArrayResultBlock) {
        let query = PFQuery(className: ParseItemClass)
        query.whereKey(ParseItemCreator, equalTo: user)
        query.whereKey(ParseItemIsBought, equalTo: true)
        query.orderByDescending(ParseItemUpdatedAt)
        query.includeKey(ParseItemBoughtBy)
        query.findObjectsInBackgroundWithBlock(completionBlock)
    }
}

extension PFObject : Equatable {
    
}

public func ==(lhs: PFObject, rhs: PFObject) -> Bool {
    return lhs.objectId == rhs.objectId
}

