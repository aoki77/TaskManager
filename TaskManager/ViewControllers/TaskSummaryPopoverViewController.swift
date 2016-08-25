//
//  TaskSummaryPopoverViewController.swift
//  TaskManager
//
//  Created by 青木孝乃輔 on 2016/08/17.
//  Copyright © 2016年 青木孝乃輔. All rights reserved.
//

import UIKit

internal final class TaskSummaryPopoverViewController: UIViewController {
    
    // MARK: - ライフサイクル
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
    }
    
    // MARK: - プライベート関数
    
    /// 各Viewの初期処理
    private func setupViews() {
        
        let contentsPadding: CGPoint = CGPoint(x: 10.0, y: 10.0)
        let contentsRect: CGRect = CGRect(x: contentsPadding.x,
                                          y: contentsPadding.y,
                                          width: view.bounds.width - (contentsPadding.x * 2),
                                          height: 50.0)
        
        // 自身
        view.backgroundColor = .whiteColor()
        
        // タイトル
        let titleLabelRect: CGRect = CGRect(x: contentsRect.minX,
                                            y: contentsRect.minY,
                                            width: contentsRect.width,
                                            height: contentsRect.height)
        let titleLabel: UILabel = UILabel(frame: titleLabelRect)
        titleLabel.autoresizingMask = [.FlexibleRightMargin, .FlexibleBottomMargin]
        titleLabel.text = "タイトル"
        view.addSubview(titleLabel)
        
        // 指定日時
        let timeLabelRect: CGRect = CGRect(x: contentsRect.minX,
                                           y: titleLabel.frame.maxY,
                                           width: contentsRect.width,
                                           height: contentsRect.height)
        let timeLabel: UILabel = UILabel(frame: timeLabelRect)
        timeLabel.autoresizingMask = [.FlexibleRightMargin, .FlexibleBottomMargin]
        timeLabel.text = "指定日時"
        view.addSubview(timeLabel)
        
        // 詳細
        let detailLabelRect: CGRect = CGRect(x: contentsRect.minX,
                                             y: timeLabel.frame.maxY,
                                             width: contentsRect.width,
                                             height: contentsRect.height)
        let detailLabel: UILabel = UILabel(frame: detailLabelRect)
        detailLabel.autoresizingMask = [.FlexibleRightMargin, .FlexibleBottomMargin]
        detailLabel.text = "詳細"
        view.addSubview(detailLabel)
        
        // ボタン
        let buttonWidth: CGFloat = 50.0
        let editButtonRect: CGRect = CGRect(x: contentsRect.maxX - buttonWidth,
                                            y: view.bounds.height - contentsPadding.y - contentsRect.height,
                                            width: buttonWidth,
                                            height: contentsRect.height)
        let editButton: UIButton = UIButton(frame: editButtonRect)
        editButton.autoresizingMask = [.FlexibleLeftMargin, .FlexibleTopMargin]
        editButton.backgroundColor = .blueColor()
        editButton.setTitle("編集", forState: .Normal)
        editButton.setTitleColor(.whiteColor(), forState: .Normal)
        editButton.layer.masksToBounds = true
        editButton.layer.cornerRadius = 20.0
        view.addSubview(editButton)
    }
}
