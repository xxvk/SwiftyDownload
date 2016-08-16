//
//  TaskCell.swift
//  iOS-Example
//
//  Created by 樊半缠 on 16/8/1.
//  Copyright © 2016年 reformation.tech. All rights reserved.
//

import UIKit

class TaskCell: UITableViewCell {
    @IBOutlet weak var labelDownload: UILabel!
    
    @IBOutlet weak var labelFileName: UILabel!
    
    @IBOutlet weak var buttonPause: UIButton!
    
    @IBOutlet weak var buttonCancel: UIButton!
    
    @IBOutlet weak var progressView: UIProgressView!
    
    var progress: Float = 0 {
        didSet {
            progress = min(1, progress)
            progress = max(0, progress)
            self.progressView.progress = progress
        }
    }
}
