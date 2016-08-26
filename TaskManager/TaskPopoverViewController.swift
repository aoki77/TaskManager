//
//  TaskPop.swift
//  TaskManager
//
//  Created by 青木孝乃輔 on 2016/08/17.
//  Copyright © 2016年 青木孝乃輔. All rights reserved.
//

import UIKit

final class TaskPopoverViewController: UIViewController {
    
    // MARK: - アウトレット
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var editButton: UIButton!
    
    // MARK: - ライフサイクル関数

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupContents()
    }
    
    // MARK: - プライベート関数
    
    /// 画面の設定
    private func setupView() {
        /// 背景を白に
        self.view.backgroundColor = UIColor.whiteColor()
    }
    
    private func setupContents() {
        /// ボタン
        editButton.backgroundColor = UIColor.blueColor()
        editButton.layer.masksToBounds = true
        editButton.layer.cornerRadius = 20.0
        editButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
    }

}
