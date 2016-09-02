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
    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var finishTimeLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var editButton: UIButton!
    
    // MARK: - 変数プロパティ
    private var column: String?
    private var row: Int?
    private var mainRect = UIScreen.mainScreen().bounds
    
    var cellDate:TaskDate?
    

    func celltest() {
        print("test")
    }
    
    // MARK: - ライフサイクル関数

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupLabel()
        setupContents()
    }
    
    // MARK: - プライベート関数
    
    /// viewcontrollerからセルのデータを受け取り、ラベルにセットする
    private func setupLabel() {
        let dateformatter = NSDateFormatter()
        dateformatter.dateFormat = "yyyy/MM/dd HH時"
        guard let guardCellDate = cellDate else { return }
        
        titleLabel.text = guardCellDate.title
        startTimeLabel.text = dateformatter.stringFromDate(guardCellDate.start_time)
        finishTimeLabel.text = dateformatter.stringFromDate(guardCellDate.finish_time)
        detailLabel.text = guardCellDate.detail
    }
    
    
    /// 画面の設定
    private func setupView() {
        /// 背景を白に
        self.view.backgroundColor = UIColor.whiteColor()
    }
    
    func setupContents() {
        /// ボタン
        editButton.backgroundColor = UIColor.blueColor()
        editButton.layer.masksToBounds = true
        editButton.layer.cornerRadius = 20.0
        editButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
    }
    
    
    // MARK: - パブリック関数
    
    // MARK: - アクション
    @IBAction func clickEditButton(sender: UIButton) {
        let storyboard: UIStoryboard = UIStoryboard(name: "Edit", bundle: nil)
        let next: UIViewController = storyboard.instantiateInitialViewController()! as UIViewController
        presentViewController(next, animated: true, completion: nil)
    }

}
