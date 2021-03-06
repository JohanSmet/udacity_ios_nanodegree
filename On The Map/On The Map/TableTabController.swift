//
//  TableTabController.swift
//  On The Map
//
//  Created by Johan Smet on 26/06/15.
//  Copyright (c) 2015 Justcode.be. All rights reserved.
//

import Foundation
import UIKit

class TableTabController :  UIViewController,
                            AppDataTab,
                            UITableViewDelegate, UITableViewDataSource {
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // outlets
    //
    
    @IBOutlet weak var studentTable: UITableView!
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // for some reason the top content-inset is set when returning from the InformationPosting-view
        // (when time permits we should find the real cause of this problem)
        studentTable.contentInset.top = 0
        
        refreshData()
    }
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // AppDataTab overrides
    //
    
    func refreshData() {
        studentTable.reloadData()
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
        let cell = tableView.dequeueReusableCellWithIdentifier("StudentCell") as! UITableViewCell 
        
        // set the cell data
        let student = DataContext.instance().studentByIndex(indexPath.row)!
        cell.textLabel?.text    = student.fullName()
        cell.imageView?.image   = UIImage(named: AssetIcons.Pin)
        
        return cell
    }

    ///////////////////////////////////////////////////////////////////////////////////
    //
    // UITableViewDelegate overrides
    //
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let student = DataContext.instance().studentByIndex(indexPath.row)!
        if isValidUrl(student.mediaURL) {
            UIApplication.sharedApplication().openURL(NSURL(string: student.mediaURL)!)
        } else {
            alertOkAsync(self, NSLocalizedString("conInvalidURL", comment: "Invalid URL!"))
        }
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if indexPath.row >= (DataContext.instance().studentLocations.count - 20) {
            // load more data when we're near the end of the table view
            DataLoader.loadExtraData() { error in
                if error == nil {
                    self.refreshData()
                }
            }
        }
    }
}