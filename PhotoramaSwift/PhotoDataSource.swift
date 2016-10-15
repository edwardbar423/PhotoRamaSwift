//
//  PhotoDataSource.swift
//  PhotoramaSwift
//
//  Created by Andrew Barber on 10/13/16.
//  Copyright © 2016 Invictus. All rights reserved.
//

import UIKit

class PhotoDataSource : NSObject, UICollectionViewDataSource {

    var photos = [Photo]()
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let identifier = "UICollectionViewCell"
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as! PhotoCollectionViewCell
        
        
        return cell
    }
    
    
    
}
