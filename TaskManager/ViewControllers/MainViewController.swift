//
//  MainViewController.swift
//  TaskManager
//
//  Created by 青木孝乃輔 on 2016/08/12.
//  Copyright © 2016年 青木孝乃輔. All rights reserved.
//

import UIKit

internal final class MainViewController: UIViewController {
    
    // MARK: - アウトレット
    
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var taskTimeLineCollectionView: UICollectionView!
    @IBOutlet private weak var tommorowButton: UIButton!
    @IBOutlet private weak var yesterdayButton: UIButton!
    @IBOutlet private weak var timeTableView: UITableView!
    
    // MARK: - 定数プロパティ
    
    /// カレンダー
    private let calendar: NSCalendar  = NSCalendar(identifier: NSCalendarIdentifierGregorian)!
    
    /// 日付用のフォーマッター
    private let dateFormatter: NSDateFormatter = {
        let dateFormatter = NSDateFormatter()
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US")
        dateFormatter.dateFormat = "yyyy/MM/dd"
        return dateFormatter
    }()
    
    /// タスク
    private let taskList: [String] = {
        var taskList = [String]()
        for taskIndex in 0..<3 {
            taskList.append("タスク\(taskIndex)")
        }
        
        return taskList
    }()
    
    /// 表示時間
    private let hourTimeList: [String] = {
        var hourTimeList = [String]()
        for timeIndex in 0..<24 {
            hourTimeList.append("\(timeIndex)時")
        }
        
        return hourTimeList
    }()
    
    // MARK: - 変数プロパティ
    
    /// 表示している日付
    private var currentDate: NSDate = NSDate() {
        didSet {
            dateLabel.text = dateFormatter.stringFromDate(currentDate)
            
            tommorowDate = calendar.dateByAddingUnit(.Day, value: 1, toDate: currentDate, options: NSCalendarOptions())!
            yesterdayDate = calendar.dateByAddingUnit(.Day, value: -1, toDate: currentDate, options: NSCalendarOptions())!
        }
    }
    
    /// 翌日の日付
    private var tommorowDate: NSDate = NSDate() {
        didSet {
            tommorowButton.setTitle(dateFormatter.stringFromDate(tommorowDate), forState: .Normal)
        }
    }
    
    /// 前日の日付
    private var yesterdayDate: NSDate = NSDate() {
        didSet {
            yesterdayButton.setTitle(dateFormatter.stringFromDate(yesterdayDate), forState: .Normal)
        }
    }
    
    /// 表示行数
    private var visibleRowCount: Int {
        switch UIApplication.sharedApplication().statusBarOrientation {
        case .LandscapeLeft, .LandscapeRight:
            return 10
        case .Portrait, .PortraitUpsideDown, .Unknown:
            return 16
        }
    }
    
    /// popoverのサイズ
    private var popoverSize: CGSize {
        switch UIApplication.sharedApplication().statusBarOrientation {
        case .LandscapeLeft, .LandscapeRight:
            return CGSize(width: view.bounds.width / 3, height: view.bounds.height)
        case .Portrait, .PortraitUpsideDown, .Unknown:
            return CGSize(width: view.bounds.width, height: view.bounds.height / 3)
        }
    }
    
    /// popoverの表示元セルのIndexPath
    private var popoverSourceCellIndexPath: NSIndexPath?
    
    /// popoverの表示元セル
    private var popoverSourceCell: UICollectionViewCell? {
        guard let popoverSourceCellIndexPath = popoverSourceCellIndexPath else {
            return nil
        }
        
        return taskTimeLineCollectionView.cellForItemAtIndexPath(popoverSourceCellIndexPath)
    }
    
    // MARK: - アクション
    
    /// 日付を翌日に更新
    @IBAction func goTommorow(_: UIButton) {
        currentDate = tommorowDate
    }
    
    /// 日付を昨日に更新
    @IBAction func goYesterday(_: UIButton) {
        currentDate = yesterdayDate
    }
    
    /// セル長押し時の処理
    func cellLongPressed(sender : UILongPressGestureRecognizer) {
        if sender.state == .Began {
            // 押された位置でcellのpathを取得
            let point = sender.locationInView(taskTimeLineCollectionView)
            let indexPath = taskTimeLineCollectionView.indexPathForItemAtPoint(point)
            print("\(indexPath!.row + 1)が長押しされました")
            
            // TODO: 完了か未完了かを把握して変更する処理をここに記載
        }
    }
    
    // MARK: - ライフサイクル
    
    // 画面ロード時
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // viewの初期化
        setupViews()
        
        // 日付の設定
        currentDate = NSDate()
        
        // レイアウトの更新
        refreshLayout()
    }
    
    // 画面回転時の処理
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        
        coordinator.animateAlongsideTransition(nil) { [weak self] _ in
            print("test回転")
            
            self?.refreshLayout()
        }
    }
    
    // MARK: - プライベート関数
    
    /// 各Viewの初期処理
    private func setupViews() {
        // 日付
        // 中央寄せ
        dateLabel.textAlignment = .Center
        dateLabel.textColor = .blackColor()
        
        // タスクコレクション
        // viewにロングタップの使用宣言を追加
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(MainViewController.cellLongPressed(_:)))
        //collectionにrecognizerを設定
        taskTimeLineCollectionView.addGestureRecognizer(longPressGestureRecognizer)
        taskTimeLineCollectionView.backgroundColor = UIColor.whiteColor()
        taskTimeLineCollectionView.delegate = self
        taskTimeLineCollectionView.dataSource = self
        
        // 時間帯テーブル
        timeTableView.allowsSelection = false
        timeTableView.separatorInset = UIEdgeInsetsZero
        // セル名の登録をおこなう
        timeTableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "MyCell")
        // スクロールバー非表示
        timeTableView.showsVerticalScrollIndicator = false
        // 羅線の色を設定
        timeTableView.separatorColor = .blackColor()
        timeTableView.dataSource = self
        timeTableView.delegate = self
    }
    
    /// popover処理
    private func presentPopover(animated animated: Bool) {
        guard let sourceView = popoverSourceCell else {
            return
        }
        
        let popoverViewController = TaskSummaryPopoverViewController()
        popoverViewController.modalPresentationStyle = .Popover
        popoverViewController.preferredContentSize = popoverSize
        
        if let popoverController = popoverViewController.popoverPresentationController {
            popoverController.delegate = self
            // 出す向き
            popoverController.permittedArrowDirections = .Any
            
            // どこから出た感じにするか
            popoverController.sourceView = sourceView
            popoverController.sourceRect = sourceView.bounds
        }
        
        presentViewController(popoverViewController, animated: animated, completion: nil)
    }
    
    /// レイアウト更新
    private func refreshLayout() {
        if let timeLineLayout = taskTimeLineCollectionView.collectionViewLayout as? TimeLineLayout {
            timeLineLayout.updateCount(taskList.count, timeCount: hourTimeList.count, visibleTimeCount: visibleRowCount)
        }
        
        timeTableView.reloadData()
        
        if let popoverViewController = presentedViewController {
            let animated: Bool = false
            
            // 吹き出し位置を再調整するために再表示
            popoverViewController.dismissViewControllerAnimated(animated) { [weak self] in
                self?.presentPopover(animated: animated)
            }
        }
    }
}

// MARK: - UITableViewDataSource

extension MainViewController: UITableViewDataSource {
    
    // セルの総数を返す
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return hourTimeList.count
    }
    
    // セルに値を設定
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // 再利用するセルを取得
        let cell = tableView.dequeueReusableCellWithIdentifier("MyCell", forIndexPath: indexPath)
        
        // セルに値を設定
        cell.textLabel!.text = "\(hourTimeList[indexPath.row])"
        
        // セルの羅線の太さを設定
        cell.layer.borderWidth = 0.5
        
        return cell
    }
}

// MARK: - UITableViewDelegate

extension MainViewController: UITableViewDelegate {
    
    // セルが選択された際に呼び出す
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("Num: \(indexPath.row)")
        print("Value: \(hourTimeList[indexPath.row])")
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return tableView.frame.height / CGFloat(visibleRowCount)
    }
}

// MARK: - UICollectionViewDataSource

extension MainViewController: UICollectionViewDataSource {
    
    /// データの個数を返す
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return taskList.count * hourTimeList.count
    }
    
    // データを返す
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        // コレクションビューから識別子「TestCell」のセルを取得する。
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! CustomCell
        
        // セルの背景色を白に設定する。
        cell.backgroundColor = .whiteColor()
        
        // セルのラベルに番号を設定する。
        cell.time.text = String(indexPath.row + 1)
        
        // セルの羅線の太さを設定
        cell.layer.borderWidth = 0.5
        
        return cell
    }
}

// MARK: - UICollectionViewDelegate

extension MainViewController: UICollectionViewDelegate {
    
    // セルクリック時の処理
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        print("選択しました: \(indexPath.row)")
        popoverSourceCellIndexPath = indexPath
        presentPopover(animated: true)
    }
}

// MARK: - UIScrollViewDelegate

extension MainViewController: UIScrollViewDelegate {
    
    // スクロール時の処理
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView == timeTableView {
            taskTimeLineCollectionView.contentOffset = timeTableView.contentOffset
        } else if scrollView == taskTimeLineCollectionView {
            timeTableView.contentOffset = taskTimeLineCollectionView.contentOffset
        }
    }
}

// MARK: - UIPopoverPresentationControllerDelegate

extension MainViewController: UIPopoverPresentationControllerDelegate {
    
    // popoverをiPhoneに対応させる
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .None
    }
}
