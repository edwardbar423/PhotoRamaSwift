//
//  FlickrAPI.swift
//  PhotoramaSwift
//
//  Created by Andrew Barber on 10/12/16.
//  Copyright © 2016 Invictus. All rights reserved.
//

import Foundation
import CoreData

enum Method: String {
    
    case RecentPhotos = "flickr.photos.getRecent"
    
}

enum PhotosResult {
    
    case Success([Photo])
    case Failure(Error)
    
}

enum FlickrError: Error {
    case InvalidJSONData
}



struct FlickrAPI {
    
    private static let baseURLString = "https://api.flickr.com/services/rest"
    private static let APIKey = "a6d819499131071f158fd740860a5a88"
    
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter
        
        
    }()
    
    private static func photoFromJSONObject(json: [String : AnyObject], inContext context: NSManagedObjectContext) -> Photo? {
        
        guard let photoID = json["id"] as? String,
            let title = json["title"] as? String,
            let dateString = json["datetaken"] as? String,
            let photoURLString = json["url_h"] as? String,
            let url = URL(string: photoURLString),
            let dateTaken = dateFormatter.date(from: dateString) else {
                return nil
        }
        
        let fetchRequest : NSFetchRequest<Photo> = Photo.fetchRequest()
        let predicate = NSPredicate(format: "photoID == \(photoID)")
        fetchRequest.predicate = predicate
        
        var fetchedPhotos: [Photo]?
        context.performAndWait() {
            do {
                fetchedPhotos = try context.fetch(fetchRequest)
            } catch {
            }
        }
        guard let photos = fetchedPhotos else {
            return nil
        }
        if (photos.count) > 0 {
            return photos.first
        }
        
        var photo: Photo!
        context.performAndWait() {
            
            photo = NSEntityDescription.insertNewObject(forEntityName: "Photo", into: context) as! Photo
            photo.title = title
            photo.photoID = photoID
            photo.remoteURL = url as NSURL
            photo.dateTaken = dateTaken as NSDate
            
        }
        return photo
    }
    
    private static func flickrURL(method: Method, parameters: [String:String]?) -> URL {
        
        var components = URLComponents(string: baseURLString)!
        var queryItems = [URLQueryItem]()
        
        let baseParams = ["method": method.rawValue,
                          "format": "json",
                          "nojsoncallback": "1",
                          "api_key": APIKey]
        
        for (key, value) in baseParams {
            
            let item = URLQueryItem(name: key, value: value)
            queryItems.append(item)
            
        }
        
        if let additionalParams = parameters {
            
            for (key, value) in additionalParams {
                let item = URLQueryItem(name: key, value: value)
                queryItems.append(item)
            }
            
        }
        components.queryItems = queryItems
        
        return components.url!
    }
    
    static func recentPhotosURL() -> URL {
        
        return flickrURL(method: .RecentPhotos,
                         parameters: ["extras": "url_h,date_taken"]) as URL
        
    }
    
    static func photosFromJSONData(data: Data, inContext context: NSManagedObjectContext) -> PhotosResult {
        
        do {
            let jsonObject: Any = try JSONSerialization.jsonObject(with: data, options: [])
            
            guard let
                jsonDictionary = jsonObject as? [String: AnyObject],
                let photos = jsonDictionary["photos"] as? [String: AnyObject],
                let photosArray = photos["photo"] as? [[String: AnyObject]] else {
                    return .Failure(FlickrError.InvalidJSONData)
            }
            
            var finalPhotos = [Photo] ()
            
            for photoJSON in photosArray {
                
                if let photo = photoFromJSONObject(json: photoJSON, inContext: context) {
                    finalPhotos.append(photo)
                }
                
            }
            
            if finalPhotos.count == 0 && photosArray.count > 0 {
                
                return .Failure(FlickrError.InvalidJSONData)
                
            }
            
            return .Success(finalPhotos)
        }
        catch let error {
            
            return .Failure(error)
            
        }
    }
    
}












