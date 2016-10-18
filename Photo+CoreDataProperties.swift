//
//  Photo+CoreDataProperties.swift
//  PhotoramaSwift
//
//  Created by Andrew Barber on 10/17/16.
//  Copyright © 2016 Invictus. All rights reserved.
//

import Foundation
import CoreData

extension Photo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Photo> {
        return NSFetchRequest<Photo>(entityName: "Photo");
    }

    @NSManaged public var photoID: String
    @NSManaged public var photoKey: String
    @NSManaged public var title: String
    @NSManaged public var dateTaken: NSDate
    @NSManaged public var remoteURL: NSURL
    @NSManaged public var tags: Set<NSManagedObject>
    
}
