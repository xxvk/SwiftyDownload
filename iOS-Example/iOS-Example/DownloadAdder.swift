//
//  DownloadAdder.swift
//  iOS Example
//
//  Created by 樊半缠 on 13/08/18.
//  Copyright (c) 2016 reformation.tech. All rights reserved.
//

import UIKit
import SwiftyDownload

class DownloadAdder: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var fieldURL: UITextField!
    
    @IBOutlet weak var fieldName: UITextField!
    
    let downloads = [ SwiftyDownload.Task.init(resource: NSURL(string: "http://ipv4.download.thinkbroadband.com/10MB.zip"), to: nil, name: "10MB", progressor: nil, completer: nil),
                      SwiftyDownload.Task.init(resource: NSURL(string: "http://speed.myzone.cn/pc_elive_1.1.rar"), to: nil, name: "60MB", progressor: nil, completer: nil),
                      SwiftyDownload.Task.init(resource: NSURL(string: "http://219.150.241.26/WindowsXP_SP2.exe"), to: nil, name: "300MB", progressor: nil, completer: nil),
                      SwiftyDownload.Task.init(resource: NSURL(string: "http://zt.bdinfo.net/speedtest/wo3G.rar"), to: nil, name: "1024MB", progressor: nil, completer: nil)]

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func onCancel(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func onAddDownload(sender: UIBarButtonItem) {
        self.addDownload(fromString: self.fieldURL.text!)
    }

    func addDownload(fromString string: String) {
        let downloadURL = NSURL(string: string)
        let downloadTask = SwiftyDownload.Task.init(resource: downloadURL, to: nil, name: self.fieldName.text ?? nil, progressor: { (progress, totalBytesWritten, totalBytesExpectedToWrite) in
            
            }) { (error, location) in
                
        }
        downloadTask.start()

        self.dismiss()
    }

    // MARK: UITableViewDataSource

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.downloads.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("addDownloadCell", forIndexPath: indexPath) 

        cell.textLabel?.text = self.downloads[indexPath.row].fileName
        
        return cell
    }

    // MARK: UITableViewDelegate

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        
        if let foo: Task = self.downloads[indexPath.row] {
            foo.start()
            
            self.dismiss()
        }
    }

    func dismiss() -> Void {
        
        let master_navi = self.splitViewController?.viewControllers.first as! UINavigationController
        
        let fooVC = master_navi.viewControllers.first as! Master
        
        
        
        defer{
            self.splitViewController?.showDetailViewController(UIViewController(), sender: self)
            
            fooVC.tableView.reloadData()
        }
    }
}
