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
    @IBOutlet weak private var startTimeLabel: UILabel!
    @IBOutlet weak private var finishTimeLabel: UILabel!
    @IBOutlet weak private var detailLabel: UILabel!
    @IBOutlet weak private var editButton: UIButton!
    
    // MARK: - 変数プロパティ
    var taskNum: Int?
    private var row: Int?
    private var mainRect = UIScreen.mainScreen().bounds
    
    var cellData:TaskDate?
    
    // MARK: - ライフサイクル関数

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupLabel()
        setupContents()
    }
    
    // MARK: - プライベート関数
    
    /// 各種コンテンツの初期設定
    private func setupContents() {
        // ボタン
        editButton.layer.masksToBounds = true
        editButton.layer.cornerRadius = 20.0
        editButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
    }
    
    /// viewcontrollerからセルのデータを受け取り、ラベルにセットする
    private func setupLabel() {
        let dateformatter = NSDateFormatter()
        dateformatter.dateFormat = "yyyy/MM/dd HH時"
        guard let guardCellData = cellData else { return }
        
        titleLabel.text = guardCellData.title
        startTimeLabel.text = dateformatter.stringFromDate(guardCellData.start_time)
        finishTimeLabel.text = dateformatter.stringFromDate(guardCellData.finish_time)
        detailLabel.text = guardCellData.detail
    }
    
    /// 画面の設定
    private func setupView() {
        /// 背景を白に
        self.view.backgroundColor = .whiteColor()
    }
    
    // MARK: - アクション
    @IBAction func clickEditButton(sender: UIButton) {
        let storyboard: UIStoryboard = UIStoryboard(name: "Edit", bundle: NSBundle.mainBundle())
        let naviView = storyboard.instantiateInitialViewController() as! UINavigationController
        let editView: EditViewController = naviView.visibleViewController as! EditViewController
        editView.cellData = cellData
        
        presentViewController(naviView, animated: true, completion: nil)
    }

}
