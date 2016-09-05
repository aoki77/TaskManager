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
        setupContents()
    }
    
    // MARK: - プライベート関数
    
    /// 各種コンテンツの初期設定
    private func setupContents() {
        // ボタン
        editButton.backgroundColor = UIColor.blueColor()
        editButton.layer.masksToBounds = true
        editButton.layer.cornerRadius = 20.0
        editButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
    }
}
