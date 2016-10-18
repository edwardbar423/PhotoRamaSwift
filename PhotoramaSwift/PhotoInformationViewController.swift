//
//  PhotoInformationViewController.swift
//  PhotoramaSwift
//
//  Created by Andrew Barber on 10/15/16.
//  Copyright © 2016 Invictus. All rights reserved.
//

import UIKit

class PhotoInformationViewController : UIViewController {
    
    @IBOutlet var imageView: UIImageView!
 
    var photo: Photo! {
        
        didSet {
            navigationItem.title = photo.title
        }
    }
    
    var store: PhotoStore!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        store.fetchImageForPhoto(photo: photo, completion: { (result) -> Void in
            switch result {
            case let .Success(image):
                OperationQueue.main.addOperation() {
                    self.imageView.image = image
                }
            case let .Failure(error):
                print("Error fetching image for photo: \(error)")
            }
            
        })
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "ShowTags" {
            let navController = segue.destination as! UINavigationController
            let tagController = navController.topViewController as! TagsViewController
            
            tagController.store = store
            tagController.photo = photo
        }
        
    }
    
}
