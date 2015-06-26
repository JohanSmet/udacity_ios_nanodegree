//
//  TableTabController.swift
//  On The Map
//
//  Created by Johan Smet on 26/06/15.
//  Copyright (c) 2015 Justcode.be. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class TableTabController :  UIViewController,
                            UITableViewDelegate, UITableViewDataSource {
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // outlets
    //
    
    @IBOutlet weak var studentTable: UITableView!
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // UIViewController overrides
    //
    
    override func viewDidLoad() {
    }
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // UITableViewDataSource overrides
    //
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return DataContext.instance().studentLocations.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // get a cell
        let cell = tableView.dequeueReusableCellWithIdentifier("StudentCell") as! UITableViewCell // as! MemeTableCell
        
        // set the cell data
        let student = DataContext.instance().studentLocations[indexPath.row]
        cell.textLabel?.text = student.firstName + " " + student.lastName;
        
        return cell
    }

    ///////////////////////////////////////////////////////////////////////////////////
    //
    // actions
    //
    
}