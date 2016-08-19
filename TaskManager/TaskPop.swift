//
//  TaskPop.swift
//  TaskManager
//
//  Created by 青木孝乃輔 on 2016/08/17.
//  Copyright © 2016年 青木孝乃輔. All rights reserved.
//

import UIKit

class TaskPop: UIViewController {
    @IBOutlet weak var popTitleContent: UILabel!
    @IBOutlet weak var popTimeContent: UILabel!
    @IBOutlet weak var popDetailContent: UILabel!
    @IBOutlet weak var editButton: UIButton!
    
    var mainRect = UIScreen.mainScreen().bounds
    
    override func viewDidLoad() {
        
        if mainRect.height > mainRect.width {
            self.view.layer.frame = CGRectMake(0, 0, mainRect.width, mainRect.height / 5)
        } else if mainRect.width > mainRect.height {
            self.view.layer.frame = CGRectMake(0, 0, mainRect.height, mainRect.width / 5)
        }
        
        self.view.backgroundColor = UIColor.whiteColor()
        
        let rect = self.view.bounds
        let allHeight = rect.height
        let allWidth = rect.width
        
        // タイトル
        let titleWidth = allWidth / 12
        let titleHeight = allHeight / 6
        let titleLabel: UILabel = UILabel(frame: CGRectMake(titleWidth, titleHeight, 100, 50))
        titleLabel.text = "タイトル"
        self.view.addSubview(titleLabel)
        
        // 指定日時
        let timeHeight = titleHeight * 2
        let timeLabel: UILabel = UILabel(frame: CGRectMake(titleWidth, timeHeight, 100, 50))
        timeLabel.text = "日時"
        self.view.addSubview(timeLabel)
        
        // 詳細
        let detailHeight = titleHeight * 3
        let detailLabel: UILabel = UILabel(frame: CGRectMake(titleWidth, detailHeight, 100, 50))
        detailLabel.text = "詳細"
        self.view.addSubview(detailLabel)
        
        // ボタン
        let editHeight = titleHeight * 6
        let editWidth = titleWidth * 9
        let editButton: UIButton = UIButton(frame: CGRectMake(editWidth, editHeight, 50, 50))
        editButton.backgroundColor = UIColor.blueColor()
        editButton.layer.masksToBounds = true
        editButton.layer.cornerRadius = 20.0
        editButton.setTitle("編集", forState: UIControlState.Normal)
        editButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        self.view.addSubview(editButton)
    }

}

