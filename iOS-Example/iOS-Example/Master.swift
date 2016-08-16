//
//  Master.swift
//  iOS-Example
//
//  Created by 樊半缠 on 16/8/15.
//  Copyright © 2016年 reformation.tech. All rights reserved.
//

import UIKit
import SwiftyDownload

class Master: UITableViewController {
    lazy var spliter: UISplitViewController! = {
        return self.splitViewController!
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nib = UINib(nibName: "TaskCell", bundle: nil)
        self.tableView.registerNib(nib, forCellReuseIdentifier: "TaskCell")
    }
    override func viewWillAppear(animated: Bool) {
        self.clearsSelectionOnViewWillAppear = self.splitViewController!.collapsed
        super.viewWillAppear(animated)
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.tableView.reloadData()
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
//  MARK: Actions
extension Master {
    @IBAction func showNetDetail(sender: UIButton) {
        
    }

    @IBAction func showDownloadAdder(sender: UIButton) {
        if let adder: DownloadAdder = (UIStoryboard.init(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("DownloadAdder") as! DownloadAdder){
            self.spliter.showDetailViewController(adder, sender: self)
        }
    }
}
//  MARK: Data source
extension Master {
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return SwiftyDownload.DataSource.Downloading.numberOfSectionsInTableView(tableView)
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SwiftyDownload.DataSource.Downloading.tableView(tableView, numberOfRowsInSection: section)
    }
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 70.0
    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TaskCell") as! TaskCell
        
        let the_task = SwiftyDownload.DataSource.Downloading.tableView(self.tableView, taskForRowAtIndexPath: indexPath) as! Task!
        cell.labelFileName.text = the_task.fileName
        cell.labelDownload.text = the_task.description
        
        if the_task.progressor == nil {
            the_task.progressor = SwiftyDownload.Task.Closure.progressor.init({ (progress, totalBytesWritten, totalBytesExpectedToWrite) in
                
                let progress = Float.init(totalBytesWritten) / Float.init(totalBytesExpectedToWrite)
                
                the_task.progress = progress
                
                let the_tableView = self.tableView
                let the_cell = the_tableView.cellForRowAtIndexPath(indexPath) as! TaskCell
                
                the_cell.progress = progress
            })
        }
        
        return cell
    }
    override func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
}
//  MARK: - Spliter :
class Spliter: UISplitViewController {
    func splitView_setup() {
        self.presentsWithGesture = false
        self.preferredDisplayMode = .AllVisible
        self.minimumPrimaryColumnWidth = 320
        self.maximumPrimaryColumnWidth = 500
        self.preferredPrimaryColumnWidthFraction = 0.3
    }
    //  MARK:  life cycle:生命周期
    override func viewDidLoad() {
        super.viewDidLoad()
        self.splitView_setup()
        
    }
}