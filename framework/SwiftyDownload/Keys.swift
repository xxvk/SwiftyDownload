//
//  Keys.swift
//  SwiftyDownload
//
//  Created by 樊半缠 on 16/8/3.
//  Copyright © 2016年 reformation.tech. All rights reserved.
//

import Foundation

enum SwiftyIdentifier: String{
    case Session = "SwiftyDownload_controller_downloads"
    
    case SessionDescription = "SwiftyDownload_controller_session"
}
public let SwiftyErrorDomain = "reform.SwiftyDownload.error"
enum SwiftyErrorKey: String{
    case Description = "SwiftyDownloadErrorDescriptionKey"
    case HTTPStatus = "SwiftyDownloadErrorHTTPStatusKey"
    case FailingURL = "SwiftyDownloadFailingURLKey"
}
public enum SwiftyError: Int {
    case HTTPError = 1
}