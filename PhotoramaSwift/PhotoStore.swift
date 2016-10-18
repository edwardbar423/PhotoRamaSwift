//
//  PhotoStore.swift
//  PhotoramaSwift
//
//  Created by Andrew Barber on 10/12/16.
//  Copyright © 2016 Invictus. All rights reserved.
//

import UIKit
import CoreData

class PhotoStore {
    
    let coreDataStack = CoreDataStack(modelName: "Photorama")
    let imageStore = ImageStore()
    
    
    enum ImageResult {
        
        case Success(UIImage)
        case Failure(Error)
        
    }
    
    enum PhotoError: Error {
        case ImageCreationError
    }
    
    let session: URLSession = {
        
        let config = URLSessionConfiguration.default
        return URLSession(configuration: config)
        
    }()
    
    func fetchImageForPhoto(photo: Photo, completion: @escaping (ImageResult) -> Void) {
        
        let photoKey = photo.photoKey
        if let image = imageStore.imageForKey(photoKey as NSString) {
            
            photo.image = image
            completion(.Success(image))
            return
            
        }
        
        let photoURL = photo.remoteURL
        let request = URLRequest(url: photoURL as URL)
        
        let task = session.dataTask(with: request) {
            (data, response, error) -> Void in
            
            let result = self.processImageRequest(data: data, error: error)
            if case let .Success(image) = result {
                photo.image = image
                self.imageStore.setImage(image, forKey: photoKey)
            }
            completion(result)
        }
        task.resume()
    }
    
    
    
    func fetchMainQueuePhotos(predicate: NSPredicate? = nil,
                              sortDescriptors: [NSSortDescriptor]? = nil) throws -> [Photo] {
        
        let fetchRequest : NSFetchRequest<Photo> = Photo.fetchRequest()
        fetchRequest.sortDescriptors = sortDescriptors
        fetchRequest.predicate = predicate
        
        let mainQueueContext = self.coreDataStack.mainQueueContext
        var mainQueuePhotos: [Photo]?
        var fetchRequestError: Error?
        mainQueueContext.performAndWait() {
            do {
              mainQueuePhotos = try mainQueueContext.fetch(fetchRequest)
            } catch let error {
                fetchRequestError = error
            }
        }
        guard let photos = mainQueuePhotos else {
            throw fetchRequestError!
        }
        return photos
    }
    
    
    
    func processImageRequest(data: Data?, error: Error?) -> ImageResult {
        
        guard let imageData = data,
            let image = UIImage(data: imageData) else {
                if data == nil {
                    return .Failure(error!)
                } else {
                    return .Failure(PhotoError.ImageCreationError)
                }
        }
        return .Success(image)
    }
    
    func fetchRecentPhotos(completion: @escaping (PhotosResult) -> Void) {
        
        let url = FlickrAPI.recentPhotosURL()
        let request = URLRequest(url: url)
        let task = session.dataTask(with: request) {
            
            (data, response, error) -> Void in
            
            var result = self.processRecentPhotosRequest(data: data, error: error)
            
            if case let .Success(photos) = result {
                
                let mainQueueContext = self.coreDataStack.mainQueueContext
                mainQueueContext.performAndWait() {
                    try! mainQueueContext.obtainPermanentIDs(for: photos)
                }
                
                let objectIDs = photos.map{ $0.objectID }
                let predicate = NSPredicate(format: "self IN %@", objectIDs)
                let sortByDateTaken = NSSortDescriptor(key: "dateTaken", ascending: true)
                
                do {
                    try self.coreDataStack.saveChanges()
                    let mainQueuePhotos = try self.fetchMainQueuePhotos(predicate: predicate,
                    sortDescriptors: [sortByDateTaken])
                    result = .Success(mainQueuePhotos)
                    
                }
                catch let error {
                    result = .Failure(error)
                }
            }
            
            completion(result)
        }
        task.resume()
    }
    
    func processRecentPhotosRequest(data: Data?, error: Error?) -> PhotosResult {
        
        guard let jsonData = data else {
            
            return .Failure(error!)
            
        }
        return FlickrAPI.photosFromJSONData(data: jsonData, inContext: self.coreDataStack.mainQueueContext)
    }
    
}












