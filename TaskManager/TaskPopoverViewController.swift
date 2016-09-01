//
//  TaskPop.swift
//  TaskManager
//
//  Created by 青木孝乃輔 on 2016/08/17.
//  Copyright © 2016年 青木孝乃輔. All rights reserved.
//

import UIKit

// デリゲートを宣言
protocol columnPopDelegate: class {
    func cellSelectPop(columnNum: Int)
}

final class TaskPopoverViewController: UIViewController, columnDelegate {
    
    // MARK: - アウトレット
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var editButton: UIButton!
    
    // MARK: - 変数プロパティ
    private var column: String?
    private var row: Int?
    private var mainRect = UIScreen.mainScreen().bounds
    
    // MARK: - ライフサイクル関数

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupContents()
        let controller = ViewController()
        controller.delegate = self
        print(controller.delegate)
    }
    
    // MARK: - プライベート関数
    
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
    
    func cellDate(title: String, startTime: NSDate, finishTime: NSDate, Detial: String) {
        print("delegate来た")
        
    }
    
    // MARK: - パブリック関数

    func cellSelect(columnNum: Int) {
        print("delegateTEST")
        print(columnNum)
        let delegate: columnPopDelegate! = nil
        delegate?.cellSelectPop(columnNum)
    }
    
    // MARK: - アクション
    @IBAction func clickEditButton(sender: UIButton) {
        let storyboard: UIStoryboard = UIStoryboard(name: "Edit", bundle: nil)
        let next: UIViewController = storyboard.instantiateInitialViewController()! as UIViewController
        presentViewController(next, animated: true, completion: nil)
    }

}
