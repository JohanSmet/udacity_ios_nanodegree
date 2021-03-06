//
//  DataContext.swift
//  Virtual Tourist
//
//  Created by Johan Smet on 08/08/15.
//  Copyright (c) 2015 Justcode.be. All rights reserved.
//

import Foundation
import CoreData

class DataContext {
    
    ////////////////////////////////////////////////////////////////////////////////
    //
    // variables
    //
    
    var pins : [Pin] = []
    
    ////////////////////////////////////////////////////////////////////////////////
    //
    // pin management
    //
    
    func fetchAllPins() -> [Pin] {
        let error: NSErrorPointer = nil
        
        // create fetch request
        let fetchRequest = NSFetchRequest(entityName: "Pin")
        
        // execute the fetch request
        let results: [AnyObject]?
        do {
            results = try coreDataStackManager().managedObjectContext!.executeFetchRequest(fetchRequest)
        } catch let error1 as NSError {
            error.memory = error1
            results = nil
        }
        
        // save results
        self.pins = results as! [Pin]
        
        return self.pins
    }
    
    func createPin(latitude : Double, longitude : Double) -> Pin {
        // create pin
        let pin = Pin(latitude: latitude, longitude: longitude, context: coreDataStackManager().managedObjectContext!)
        pins.append(pin)
        
        // save all changes
        coreDataStackManager().saveContext()
        
        return pin
    }
    
    ////////////////////////////////////////////////////////////////////////////////
    //
    // photo management
    //
    
    func deletePhotos(photos : [Photo]) {
        for photo in photos {
            coreDataStackManager().managedObjectContext!.deleteObject(photo)
        }
        
        coreDataStackManager().saveContext()
    }
    
    func deletePhotosOfPin(location : Pin) {
        let fetchRequest = NSFetchRequest(entityName: "Photo")
        fetchRequest.predicate       = NSPredicate(format: "location == %@", location)
        
        deletePhotos((try! coreDataStackManager().managedObjectContext!.executeFetchRequest(fetchRequest)) as! [Photo])
    }
    
    func fetchIncompletePhotosOfPin(location : Pin) -> [Photo] {
        let fetchRequest = NSFetchRequest(entityName: "Photo")
        fetchRequest.predicate       = NSPredicate(format: "location == %@ && localUrl = nil", location)
        return (try! coreDataStackManager().managedObjectContext!.executeFetchRequest(fetchRequest)) as! [Photo]
    }
    
    func allPhotosOfPinComplete(location : Pin) ->  Bool {
        let fetchRequest = NSFetchRequest(entityName: "Photo")
        fetchRequest.predicate       = NSPredicate(format: "location == %@ && localUrl = nil", location)
        
        let incomplete = coreDataStackManager().managedObjectContext!.countForFetchRequest(fetchRequest, error: nil)
        return incomplete == 0
    }
    
    ////////////////////////////////////////////////////////////////////////////////
    //
    // student management
    //
    
    func fetchStudentForKeys(keys : [String]) -> [Student] {
        
        let fetchRequest = NSFetchRequest(entityName: "Student")
        fetchRequest.predicate = NSPredicate(format: "uniqueKey IN %@", keys)
        
        return (try! coreDataStackManager().managedObjectContext!.executeFetchRequest(fetchRequest)) as! [Student]
    }
    
    func countStudentsNearLocation(location : Pin) -> Int {
        
        // just a quick formula to find students near a location (wont work when latitude/longitude wraps around)
        let fetchRequest = NSFetchRequest(entityName: "Student")
        fetchRequest.predicate = NSPredicate(format: "abs(latitude - \(location.latitude as Double)) < 1.0 && abs(longitude - \(location.longitude as Double)) < 1.0")
        
        return coreDataStackManager().managedObjectContext!.countForFetchRequest(fetchRequest, error: nil)
    }

    ////////////////////////////////////////////////////////////////////////////////
    //
    // singleton
    //
    
    static let sharedInstance = DataContext()
}

func dataContext() -> DataContext {
    return DataContext.sharedInstance
}