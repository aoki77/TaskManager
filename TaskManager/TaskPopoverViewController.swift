//
//  TaskPop.swift
//  TaskManager
//
//  Created by 青木孝乃輔 on 2016/08/17.
//  Copyright © 2016年 青木孝乃輔. All rights reserved.
//

import UIKit

final class TaskPop: UIViewController {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var editButton: UIButton!
    
    // 画面の最大サイズ
    private let mainRect = UIScreen.mainScreen().bounds
    
    private var allHeight: CGFloat?
    private var allWidth: CGFloat?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupContents()
    }
    
    // 画面の設定
    private func setupView() {
        // 画面サイズを設定
            let orientation: UIInterfaceOrientation = UIApplication.sharedApplication().statusBarOrientation
            switch (orientation) {
            case UIInterfaceOrientation.Portrait:
                self.view.bounds.size = CGSize(width: mainRect.width, height: mainRect.height / 5)
            case UIInterfaceOrientation.LandscapeLeft, UIInterfaceOrientation.LandscapeRight:
                self.view.bounds.size = CGSize(width: mainRect.height, height: mainRect.width / 5)
            default:
                break
            }
        
        allWidth = self.view.bounds.size.width
        allHeight = self.view.bounds.size.height
        
        // 背景を白に
        self.view.backgroundColor = UIColor.whiteColor()
    }
    
    private func setupContents() {
        guard let guardWidth = allWidth else { return }
        guard let guardHeight = allHeight else { return }
        
        let labelSize = CGSize(width: 100.0, height: 50.0)
        let buttonSize = CGSize(width: 50.0, height: 50.0)
        
        // タイトル
        let titleWidth = guardWidth / 12
        let titleHeight = guardHeight / 6
        let titleLabel: UILabel = UILabel(frame: CGRectMake(titleWidth, titleHeight, labelSize.width, labelSize.height))
        titleLabel.text = "タイトル"
        self.view.addSubview(titleLabel)
        // 指定日時
        let timeHeight = titleHeight * 2
        let timeLabel: UILabel = UILabel(frame: CGRectMake(titleWidth, timeHeight, labelSize.width, labelSize.height))
        timeLabel.text = "日時"
        self.view.addSubview(timeLabel)
        
        // 詳細
        let detailHeight = titleHeight * 3
        let detailLabel: UILabel = UILabel(frame: CGRectMake(titleWidth, detailHeight, labelSize.width, labelSize.height))
        detailLabel.text = "詳細"
        self.view.addSubview(detailLabel)
        
        // ボタン
        let editHeight = titleHeight * 6
        let editWidth = titleWidth * 9
        let editButton: UIButton = UIButton(frame: CGRectMake(editWidth, editHeight, buttonSize.width, buttonSize.height))
        editButton.backgroundColor = UIColor.blueColor()
        editButton.layer.masksToBounds = true
        editButton.layer.cornerRadius = 20.0
        editButton.setTitle("編集", forState: UIControlState.Normal)
        editButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        self.view.addSubview(editButton)
    }

}
