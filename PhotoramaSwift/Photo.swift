//
//  Photo.swift
//  PhotoramaSwift
//
//  Created by Andrew Barber on 10/12/16.
//  Copyright © 2016 Invictus. All rights reserved.
//

import UIKit

class Photo {
    
    let title: String
    let remoteURL: URL
    let photoID: String
    let dateTaken: Date
    var image: UIImage?
    
    init(title: String, remoteURL: URL, photoID: String, dateTaken: Date) {
        
        self.title = title
        self.remoteURL = remoteURL
        self.photoID = photoID
        self.dateTaken = dateTaken
        
    }
    
}

extension Photo: Equatable {
    
    static func == (lhs: Photo, rhs: Photo) -> Bool {
        
        return lhs.photoID == rhs.photoID
        
    }
}
