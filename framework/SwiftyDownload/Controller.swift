//
//  Controller.swift
//  SwiftyDownload
//
//  Created by 樊半缠 on 16/8/1.
//  Copyright © 2016年 reformation.tech. All rights reserved.
//

import Foundation


final public class Controller {
    public static let singleton = Controller()
    
    public var tasks: [Int: Task] = [:]
    
    public init(config: NSURLSessionConfiguration) {
        self.raw = NSURLSession(configuration: config,
                                delegate: ControllerDelegate.singleton,
                                delegateQueue: NSOperationQueue.mainQueue())// maybe nil
        self.raw.sessionDescription = SwiftyIdentifier.SessionDescription.rawValue
    }
    public convenience init() {
        /**
         backgroundSessionConfiguration
         */
        let config = NSURLSessionConfiguration.backgroundSessionConfigurationWithIdentifier(SwiftyIdentifier.Session.rawValue)
//        config.HTTPMaximumConnectionsPerHost = 1
        self.init(config: config)
    }
    
    internal func downloadTaskWithURL(url: NSURL) -> NSURLSessionDownloadTask{
        
        return self.raw.downloadTaskWithURL(url)
    }
    
    //  MARK: private vars
    private let raw: NSURLSession
}
//  MARK: actions
extension Controller{
    
    internal func newDownload(task: Task)   ->  (Task)
    {
        task.raw.resume()
        return self.Generator(task)
    }
    
    internal func resume(task: Task)  ->  (Task)
    {
        if let download = tasks[task.raw.taskIdentifier] {
            if task.resumeData != nil {
                let downloadTask = self.raw.downloadTaskWithResumeData(task.resumeData!)
            }
        }
        return task
    }
    
    internal func pause(task: Task)   ->  (Task) {
        
        if task.isDownloading {
            task.cancelByProducingResumeData({ (data) in
                
                if data != nil {
                    task.resumeData = data
                }
            })
            task.isDownloading = false
        }
        return task
    }
    
    internal func cancel(task: Task)   ->  (Task) {
        
        if let download = tasks[task.raw.taskIdentifier] {
            
            download.cancel()
            self.tasks[task.raw.taskIdentifier] = nil
        }
        return task
    }
}

//  MARK: status
extension Controller{
    
    public func tasksFilter(state objective: NSURLSessionTaskState?) -> [Task] {
        
        return self.tasks.filter({ (aInt, aTask) -> Bool in
            return (objective != nil) ? aTask.raw.state == objective : true
        }).map({ (bInt, bTask) -> Task in
            return bTask
        })
        
    }
    
    private func Generator(task: Task) -> Task {
        self.tasks[task.raw.taskIdentifier] = task
        
        return task
    }
}
//  MARK: - internal Delegate implements
final class ControllerDelegate: NSObject, NSURLSessionDownloadDelegate{
    
    public static let singleton = ControllerDelegate()
    
    var acceptableStatusCodes: Range<Int>{
        get{
            return 200...299
        }
    }
    func validateResponse(response: NSHTTPURLResponse) -> Bool {
        return self.acceptableStatusCodes.contains(response.statusCode)
    }
    
    // MARK: NSURLSessionDownloadDelegate
    
    public func URLSession(session: NSURLSession,
                           downloadTask: NSURLSessionDownloadTask,
                           didResumeAtOffset fileOffset: Int64,
                           expectedTotalBytes: Int64) {
        print("Resume at offset: \(fileOffset) total expected: \(expectedTotalBytes)")
    }
    
    public func URLSession(session: NSURLSession,
                           downloadTask: NSURLSessionDownloadTask,
                           didWriteData bytesWritten: Int64,
                           totalBytesWritten: Int64,
                           totalBytesExpectedToWrite: Int64)
    {
        let task = Controller.singleton.tasks[downloadTask.taskIdentifier]!
        let progress = totalBytesExpectedToWrite == NSURLSessionTransferSizeUnknown ? -1 : Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
        
        task.progress = progress
        
        dispatch_async(dispatch_get_main_queue()) {
            task.progressor?(progress: progress, totalBytesWritten: totalBytesWritten, totalBytesExpectedToWrite: totalBytesExpectedToWrite)
            return
        }
    }
    
    public func URLSession(session: NSURLSession,
                           downloadTask: NSURLSessionDownloadTask,
                           didFinishDownloadingToURL location: NSURL) {
        let task = Controller.singleton.tasks[downloadTask.taskIdentifier]!
        var fileError: NSError?
        var resultingURL: NSURL?
        print(session, task, location, separator: " | ", terminator: " ... ")
//        do {
//            let qux_destination = task.destination
//            
//            try NSFileManager.defaultManager().replaceItemAtURL(task.destination,
//                                                                withItemAtURL: location,
//                                                                backupItemName: nil,
//                                                                options: [],
//                                                                resultingItemURL: &resultingURL)
//            task.destination = resultingURL
//        } catch let barError as NSError {
//            fileError = barError
//            task.error = fileError
//        }
    }
    
    public func URLSession(session: NSURLSession,
                           task: NSURLSessionTask,
                           didCompleteWithError sessionError: NSError?)
    {
        var error: NSError? = sessionError //?? downloadTask.error
        // Handle possible HTTP errors
        if let response = task.response as? NSHTTPURLResponse {
            // NSURLErrorDomain errors are not supposed to be reported by this delegate
            // according to https://developer.apple.com/library/ios/documentation/Cocoa/Conceptual/URLLoadingSystem/NSURLSessionConcepts/NSURLSessionConcepts.html
            // so let's ignore them as they sometimes appear there for now. (But WTF?)
            if !validateResponse(response) && (error == nil || error!.domain == NSURLErrorDomain) {
                error = NSError(domain: SwiftyErrorDomain,
                                code: SwiftyError.HTTPError.rawValue,
                                userInfo: [SwiftyErrorKey.Description.rawValue : "Erroneous HTTP status code: \(response.statusCode)",
                                    SwiftyErrorKey.FailingURL.rawValue : task.originalRequest!.URL!,
                                    SwiftyErrorKey.HTTPStatus.rawValue : response.statusCode])
            }
        }
        
        if let downloadTask: Task = Controller.singleton.tasks[task.taskIdentifier] {
            // Remove the reference to the download
            Controller.singleton.tasks.removeValueForKey(task.taskIdentifier)
            
            dispatch_async(dispatch_get_main_queue()) {
                downloadTask.completer?(error: error, location: downloadTask.destination)
                return
            }
        }
    }
}