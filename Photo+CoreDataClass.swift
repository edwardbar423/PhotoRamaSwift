//
//  Photo+CoreDataClass.swift
//  PhotoramaSwift
//
//  Created by Andrew Barber on 10/17/16.
//  Copyright © 2016 Invictus. All rights reserved.
//

import UIKit
import CoreData


public class Photo: NSManagedObject {

    var image: UIImage?

    
    override public func awakeFromInsert() {
        title = ""
        photoID = ""
        remoteURL = NSURL()
        photoKey = NSUUID().uuidString
        dateTaken = NSDate()
    }
 
    
    func addTagObject(tag: NSManagedObject) {
        let currentTags = mutableSetValue(forKey: "tags")
        currentTags.add(tag)
    }
    
    func removeTagObject(tag: NSManagedObject) {
        let currentTags = mutableSetValue(forKey: "tags")
        currentTags.remove(tag)
    }
    
}
