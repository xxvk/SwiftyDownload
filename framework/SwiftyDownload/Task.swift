//
//  Task.swift
//  SwiftyDownload
//
//  Created by 樊半缠 on 16/8/1.
//  Copyright © 2016年 reformation.tech. All rights reserved.
//

import Foundation
//  MARK: Foundation Elements of Task
public final class Task {

    public let destination: NSURL!
    public let fileName: String!
    
    public var progress: Float = 0.0
    public var isDownloading = false
    public var resumeData: NSData?
    
    init(resource url: NSURL!, to destination: NSURL?, name: String?){
        let NSTask = Controller.singleton.downloadTaskWithURL(url)
        self.raw = NSTask
        //TODO: -   may be nil if no response has been received (use dispatch)
        let fooName = name ?? NSTask.response?.suggestedFilename
        self.fileName = fooName
        
        let destinationPath = destination ?? NSURL(fileURLWithPath: NSTemporaryDirectory())
        self.destination = NSURL(string: self.fileName!, relativeToURL: destinationPath)!.URLByStandardizingPath!
    }

    ///Closure raw handle
    public var progressor: Closure.progressor?
    public var completer: Closure.completer?
    
    
    //  MARK: private var
    internal let raw: NSURLSessionDownloadTask!
}

//  MARK: Status
extension Task {
    internal func cancelByProducingResumeData(completer: (NSData?) -> Void) {
        self.raw.cancelByProducingResumeData(completer)
        self.isDownloading = false
    }
}

//  MARK: Closure
extension Task {
    /// Task Closure
    public class Closure {
        public typealias progressor = ((progress: Float, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) -> Void)!
        public typealias completer = ((error: NSError?, location: NSURL?) -> Void)!
    }
    
    public convenience init(resource url: NSURL!, to destination: NSURL?, name: String?, progressor: Closure.progressor?, completer: Closure.completer?)
    {
        self.init(resource: url, to: destination, name: name)
        self.progressor = progressor
        self.completer = completer
    }
}
//  MARK: Controller Extension for Task
extension Task {
    public func start() {
        Controller.singleton.newDownload(self)
        self.isDownloading = true
    }
    
    public func cancel() {
        Controller.singleton.cancel(self)
        self.isDownloading = false
    }
    
    public func suspend() {
        Controller.singleton.pause(self)
        self.isDownloading = false
    }

    public func resume() {
        Controller.singleton.resume(self)
        self.isDownloading = true
    }
    
    // TODO: remaining time
    // TODO: instanciable Task
}

// MARK: Print
extension Task: CustomStringConvertible {
    public var description: String {
        var parts: [String] = []
        var state: String
        
        switch self.raw.state {
        case .Running: state = "running"; break
        case .Completed: state = "completed"; break
        case .Canceling: state = "canceling"; break
        case .Suspended: state = "suspended"; break
        }
        
        parts.append("Task")
        parts.append("from URL: \(self.raw.originalRequest!.URL)")
        parts.append("To: \(self.destination)")
        parts.append("Named: \(self.fileName)")
        parts.append("Current state: \(state)")
        
        return parts.joinWithSeparator(" , ")
    }
}