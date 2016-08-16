//
//  DataSource.swift
//  SwiftyDownload
//
//  Created by 樊半缠 on 16/8/1.
//  Copyright © 2016年 reformation.tech. All rights reserved.
//
import UIKit
// MARK: UITableViewDataSource
final public class DataSource {
    
    public class Downloading{
        public class func numberOfSectionsInTableView(tableView: UITableView) -> Int {
            return 1
        }
        
        public class func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return Controller.singleton.tasks.count
        }
        
        public class func tableView(tableView: UITableView,
                                    taskForRowAtIndexPath indexPath: NSIndexPath) -> Task?
        {
            var index = 0
            
            for foo in Controller.singleton.tasks.values{
                if index == indexPath.row {
                    if  let bar: Task = foo {
                        return bar
                    }
                }
                index = index + 1
            }
            return  nil
        }
    }
    
    //TODO: - woiw
    public class Finished{
        public class func numberOfSectionsInTableView(tableView: UITableView) -> Int {
            return 1
        }
        
        public class func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return Controller.singleton.tasks.count
        }
        
        public class func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCellWithIdentifier("identifier")
            return cell!
        }
    }
    
}
