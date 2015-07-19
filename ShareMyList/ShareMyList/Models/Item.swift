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
    @NSManaged var boughtBy: PFUser?
    @NSManaged var text: String
    @NSManaged var category: String
    @NSManaged var isBought: Bool
    
    // MARK: categories
    
    /// set the category of the list item and save item to parse
    func saveItem(callback: PFBooleanResultBlock) {
        findCategory()
        self.isBought = false
        self.creator = PFUser.currentUser()!
        self.saveInBackgroundWithBlock(callback)
    }
    
    private func findCategory() {
        let insertableText = text.stringByReplacingOccurrencesOfString(" ", withString: "+")
        let urlPath = "https://api.idolondemand.com/1/api/sync/querytextindex/v1?text=\(insertableText)&indexes=store-association&apikey=a6703c28-6b7c-409a-8b34-b16ad72a5e17"
        let url = NSURL(string: urlPath)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithURL(url!, completionHandler: {data, response, error -> Void in
            if(error != nil) {
                // If there is an error in the web request, print it to the console
                println(error.localizedDescription)
            }
            
            // no error...
            var err: NSError?
            if let jsonResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &err) as? NSDictionary {
                if(err != nil) {
                    // If there is an error parsing JSON, print it to the console
                    println("JSON Error \(err!.localizedDescription)")
                }
                if let docs = jsonResult["documents"] as? NSArray {
                    let category = docs[0]["title"] as? String
                    self.category = category!
                    println(category!)
                    self.saveInBackground()
//                    dispatch_async(dispatch_get_main_queue(), {
////                        self.tableData = results
////                        self.appsTableView!.reloadData()
//                    })
                }
            }
        })
        
        // The task is just an object with all these properties set
        // In order to actually make the web request, we need to "resume"
        task.resume()
    }
    
    func buyItem(callback: PFBooleanResultBlock) {
        self.isBought = true
        self.boughtBy = PFUser.currentUser()
        self.saveInBackgroundWithBlock(callback)
    }
    
    func toggleBought(isBought: Bool, callback: PFBooleanResultBlock) {
        self.isBought = isBought
        if isBought { self.boughtBy = PFUser.currentUser() }
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

