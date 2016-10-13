//
//  PhotoStore.swift
//  PhotoramaSwift
//
//  Created by Andrew Barber on 10/12/16.
//  Copyright © 2016 Invictus. All rights reserved.
//

import UIKit

class PhotoStore {
    
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
        
        let photoURL = photo.remoteURL
        let request = URLRequest(url: photoURL)
        
        let task = session.dataTask(with: request) {
            (data, response, error) -> Void in
            
            let result = self.processImageRequest(data: data, error: error)
            if case let .Success(image) = result {
                photo.image = image
            }
            completion(result)
        }
        task.resume()
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
            
            let result = self.processRecentPhotosRequest(data: data, error: error)
            completion(result)
        }
        task.resume()
    }
    
    func processRecentPhotosRequest(data: Data?, error: Error?) -> PhotosResult {
        
        guard let jsonData = data else {
            
            return .Failure(error!)
            
        }
        return FlickrAPI.photosFromJSONData(data: jsonData)
    }
    
}
