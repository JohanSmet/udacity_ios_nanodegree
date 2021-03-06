//
//  FlickrApiClient.swift
//  Virtual Tourist
//
//  Created by Johan Smet on 09/08/15.
//  Copyright (c) 2015 Justcode.be. All rights reserved.
//

import Foundation

class FlickrClient : WebApiClient {
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // constants
    //
    
    static let API_KEY : String = "07a2c17566b035226e91de9a4ff0980d"
    static let BASE_URL : String = "https://api.flickr.com/services/rest/"
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // initializers
    //
    
    override init() {
        super.init(dataOffset: 0)
    }
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // request interface
    //
    
    func searchPhotoByGeo(latitude : Double, longitude : Double, maxResults : Int, page : Int, completionHandler : (photos : [AnyObject]?, pages : Int, error : String?) -> Void) {
        
        let parameters : [String : AnyObject] = [
            "method"    : "flickr.photos.search",
            "api_key"   : FlickrClient.API_KEY,
            "format"    : "json",
            "nojsoncallback" : "1",
            "lat"       : "\(latitude)",
            "lon"       : "\(longitude)",
            "per_page"  : "\(maxResults)",
            "page"      : "\(page)"
        ]
        
        // make request
        startTaskGET(FlickrClient.BASE_URL, method: "", parameters: parameters) { result, error in
            if let basicError = error as? NSError {
                completionHandler(photos: nil, pages : 0, error: FlickrClient.formatBasicError(basicError))
            } else if let httpError = error as? NSHTTPURLResponse {
                completionHandler(photos : nil, pages : 0, error: FlickrClient.formatHttpError(httpError))
            } else {
                let httpResult = result as! NSDictionary;
                
                let photos = httpResult.valueForKey("photos") as! NSDictionary
                let photo  = photos.valueForKey("photo") as? [AnyObject]
                var pages  = (photos.valueForKey("pages") as? Int) ?? 0
                
                // flickr returns at most 4000 matches - cap the number of pages
                if maxResults != 0 && pages > (4000 / maxResults) {
                    pages = 4000 / maxResults
                }
                
                completionHandler(photos: photo, pages : pages, error: nil)
            }
        }
    }
    
    func urlForPhoto (flickrPhoto : [String : AnyObject], size : String) -> String {
        let farm    = flickrPhoto["farm"] as! Int
        let server  = flickrPhoto["server"] as! String
        let id      = flickrPhoto["id"] as! String
        let secret  = flickrPhoto["secret"] as! String
        
        return "https://farm\(farm).staticflickr.com/\(server)/\(id)_\(secret)_\(size).jpg"
    }
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // helper functions
    //
    
    private class func formatBasicError(error : NSError) -> String {
        return error.localizedDescription
    }
    
    private class func formatHttpError(response : NSHTTPURLResponse) -> String {
        
        if (response.statusCode == 403) {
            return NSLocalizedString("cliInvalidCredentials", comment:"Invalid username or password")
        } else {
            return "HTTP-error \(response.statusCode)"
        }
    }
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // singleton
    //
    
    static let instance	= FlickrClient()
}


func flickrClient() -> FlickrClient {
    return FlickrClient.instance
}