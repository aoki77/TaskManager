//
//  TaskPopoverViewController.swift
//  TaskManager
//
//  Created by 青木孝乃輔 on 2016/08/17.
//  Copyright © 2016年 青木孝乃輔. All rights reserved.
//

import UIKit

final class TaskPopoverViewController: UIViewController {
    
    // MARK: - アウトレット
    
    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var timeLabel: UILabel!
    @IBOutlet weak private var detailLabel: UILabel!
    @IBOutlet weak private var editButton: UIButton!
    
    // MARK: - ライフサイクル関数

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
