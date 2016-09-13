//
//  ViewController.swift
//  TaskManager
//
//  Created by 青木孝乃輔 on 2016/08/12.
//  Copyright © 2016年 青木孝乃輔. All rights reserved.
//

import UIKit
import RealmSwift

final class ViewController: UIViewController, UIGestureRecognizerDelegate {
    
    // MARK: - アウトレット
    
    @IBOutlet weak private var dateLabel: UILabel!
    @IBOutlet weak private var timeLineCollectionView: UICollectionView!
    @IBOutlet weak private var tommorowButton: UIButton!
    @IBOutlet weak private var yesterdayButton: UIButton!
    @IBOutlet weak private var dayTimeTableView: UITableView!
    @IBOutlet weak private var dayTimeWidthLayoutConstraint: NSLayoutConstraint!
    
    // MARK: - 定数プロパティ
    
    /// カレンダー
    let calendar = NSCalendar(identifier: NSCalendarIdentifierGregorian)!
    
    // 色を格納した配列
    private let colors = [UIColor.redColor(), UIColor.orangeColor(), UIColor.yellowColor()]
    
    /// 日付用のフォーマッター
    private let dateFormatter: NSDateFormatter = {
        let dateFormatter = NSDateFormatter()
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US")
        dateFormatter.dateFormat = "yyyy/MM/dd"
        return dateFormatter
    }()
    
    /// 時間
    private let hourTime = { () -> NSMutableArray in
        let time: NSMutableArray = []
        for num in 0 ... 23 {
            time.addObject(String(num) + "時")
        }
        return time
    }
    
    // MARK: - 変数プロパティ
    
    var cellData: TaskDate?
    
    /// 当日の日付
    var currentDate = NSDate()
    
    /// 選択されたセルのインデックスパス
    private var selectedCellIndexPath: NSIndexPath?
    
    /// 翌日の日付
    private var nextDate: NSDate = NSDate() {
        didSet {
            tommorowButton.setTitle(dateFormatter.stringFromDate(nextDate), forState: UIControlState.Normal)
        }
    }
    /// 昨日の日付
    private var previousDate: NSDate = NSDate() {
        didSet {
            yesterdayButton.setTitle(dateFormatter.stringFromDate(previousDate), forState: UIControlState.Normal)
        }
    }
    
    /// popoverのサイズ
    private var popoverSize: CGSize {
        switch UIApplication.sharedApplication().statusBarOrientation {
        case .Portrait, .PortraitUpsideDown, .Unknown:
            return CGSize(width: view.bounds.width, height: view.bounds.height / 3)
        case .LandscapeLeft, .LandscapeRight:
            return CGSize(width: view.bounds.width / 3, height: view.bounds.height)
        }
    }
    
    /// popoverの方向
    private var popoverDirection: UIPopoverArrowDirection {
        switch UIApplication.sharedApplication().statusBarOrientation {
        case .Portrait, .PortraitUpsideDown, .Unknown:
            return [.Up, .Down]
        case .LandscapeLeft, .LandscapeRight:
            return [.Left, .Right]
        }
    }
    
    // MARK: - ライフサイクル関数
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupDate()
        setupTable()
        setupCollection()
    }
    
    /// 画面回転時の処理
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        coordinator.animateAlongsideTransition(nil) { [weak self] _ in
            guard let guardSelf = self else { return }
            guardSelf.setupView()
            guardSelf.dayTimeTableView.reloadData()
            if let TimeLineLayout = guardSelf.timeLineCollectionView.collectionViewLayout as? TimeLineLayout{
                TimeLineLayout.updateLayout()
            }
            if let indexPath = guardSelf.selectedCellIndexPath {
                guardSelf.presentPopover(guardSelf.timeLineCollectionView, indexPath: indexPath)
            }
        }
    }
    
    // MARK: - プライベート関数
    
    /// 初期値を設定
    private func setupView() {
        switch UIApplication.sharedApplication().statusBarOrientation {
        case .Portrait, .PortraitUpsideDown, .Unknown:
            dayTimeTableView.rowHeight = self.view.frame.size.height / 16
            dayTimeWidthLayoutConstraint.constant = self.view.frame.size.width / 4
        case .LandscapeLeft, .LandscapeRight:
            dayTimeTableView.rowHeight = self.view.frame.size.height / 10
            dayTimeWidthLayoutConstraint.constant = self.view.frame.size.width / 4
        }
    }
    
    /// テーブルの設定
    private func setupTable() {
        dayTimeTableView.allowsSelection = false
        dayTimeTableView.separatorInset = UIEdgeInsetsZero
        
        // セル名の登録をおこなう.
        dayTimeTableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "tableCell")
        
        // スクロールバー非表示
        dayTimeTableView.showsVerticalScrollIndicator = false
        
        // 羅線の色を設定
        dayTimeTableView.separatorColor = UIColor.blackColor()
        
        // DataSourceの設定
        dayTimeTableView.dataSource = self
        
        // Delegateを設定
        dayTimeTableView.delegate = self
        
    }
    
    /// コレクションの設定
    private func setupCollection() {
        timeLineCollectionView.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: "collectionCell")
        timeLineCollectionView.backgroundColor = .whiteColor()
        
        timeLineCollectionView.delegate = self
        timeLineCollectionView.dataSource = self
        
        longTap()
    }
    
    /// ロングタップの設定
    private func longTap() {
        // viewにロングタップの使用宣言を追加
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(ViewController.cellLongPressed(_:)))
        
        longPressGestureRecognizer.delegate = self
        
        // collectionにrecognizerを設定
        timeLineCollectionView.addGestureRecognizer(longPressGestureRecognizer)
    }
    
    /// 日付の設定
    private func setupDate() {
        nextDate = calendar.dateByAddingUnit(.Day, value: 1, toDate: currentDate, options: NSCalendarOptions())!
        previousDate = calendar.dateByAddingUnit(.Day, value: -1, toDate: currentDate, options: NSCalendarOptions())!
        
        // 日付ラベルの設定
        dateLabel.text = dateFormatter.stringFromDate(currentDate)
        dateLabel.textAlignment = NSTextAlignment.Center
        dateLabel.textColor = UIColor.blackColor()
    }
    
    /// popover処理
    private func presentPopover(collectionView: UICollectionView, indexPath: NSIndexPath) {
        let sourceView = collectionView.cellForItemAtIndexPath(indexPath)
        let storyboard: UIStoryboard = UIStoryboard(name: "TaskPop", bundle: NSBundle.mainBundle())
        let next = storyboard.instantiateViewControllerWithIdentifier("TaskPop") as! TaskPopoverViewController
        let taskNum = selectTaskNum(indexPath)
        next.cellData = cellData
        next.taskNum = taskNum
        next.modalPresentationStyle = .Popover
        next.preferredContentSize = popoverSize
        if let popoverViewController = presentedViewController {
            let animated: Bool = false
            // popoverを閉じる
            popoverViewController.dismissViewControllerAnimated(animated, completion: nil)
        }
        
        if let popoverController = next.popoverPresentationController {
            popoverController.delegate = self
            // 出す向き
            popoverController.permittedArrowDirections = popoverDirection
            
            // どこから出た感じにするか
            popoverController.sourceView = sourceView
            guard let guardSourceView = sourceView else { return }
            popoverController.sourceRect = guardSourceView.bounds
        }
        presentViewController(next, animated: true, completion: nil)
    }
    
    /// 何列目(何タスク目)をクリックしたかを判別する
    private func selectTaskNum(indexPath: NSIndexPath) -> Int {
        // 列数を入れる配列
        let taskNum = [1, 2, 3]
        if indexPath.row <= 23 {
            return taskNum[0]
        } else if 24 <= indexPath.row && indexPath.row <= 47 {
            return taskNum[1]
        } else if 48 <= indexPath.row && indexPath.row <= 71 {
            return taskNum[2]
        }
        return 0
    }
    
    /// DB内にデータがある時間のセルを重要度に応じて色を変更する
    private func dateCheck(cell: UICollectionViewCell, indexPath: NSIndexPath) {
        let realm = realmMigrations()
        let tasks = realm.objects(TaskDate)
        let dateformatter = NSDateFormatter()
        dateformatter.dateFormat = "yyyy/MM/dd"
        let hourFormatter = NSDateFormatter()
        hourFormatter.dateFormat = "HH"
        
        for task in tasks {
            let path = selectIndexPath(task)
            // 日付が同じデータのみを抽出
            if dateformatter.stringFromDate(task.start_time).compare(dateformatter.stringFromDate(currentDate)) == NSComparisonResult.OrderedSame {
                let schedulePeriod: Int?
                // スケジュールが次の日までまたいでいるかどうかで分岐
                if dateformatter.stringFromDate(task.start_time).compare(dateformatter.stringFromDate(task.finish_time)) == NSComparisonResult.OrderedSame {
                    schedulePeriod = Int(hourFormatter.stringFromDate(task.finish_time))! - Int(hourFormatter.stringFromDate(task.start_time))!
                } else {
                    // 開始時間の行から最終行（23時）まで塗る
                    schedulePeriod = 23 - Int(hourFormatter.stringFromDate(task.start_time))!
                }
                guard let guardSchedulePeriod = schedulePeriod else { return }
                for i in 0 ... guardSchedulePeriod {
                    if (path + i)  == indexPath.row {
                        if task.complete_flag {
                            cell.backgroundColor = .grayColor()
                        } else {
                            cell.backgroundColor = colors[task.color]
                        }
                    }
                }
            } else {
                let formatter = NSDateFormatter()
                formatter.dateFormat = "yyyy/MM/dd:HH"
                var num: Int?
                if task.task_no == 1 {
                    num = 0
                } else if task.task_no == 2 {
                    num = 24
                } else if task.task_no == 3 {
                    num = 48
                }
                guard let guardNum = num else { return }
                // 前日の23時のカラムにデータがあるかないかで今日のデータの有無を判定
                let date = dateformatter.stringFromDate(previousDate) + ":23"
                if date.compare(formatter.stringFromDate(task.start_time)) == NSComparisonResult.OrderedDescending &&
                    date.compare(formatter.stringFromDate(task.finish_time)) == NSComparisonResult.OrderedAscending {
                    if dateformatter.stringFromDate(task.finish_time).compare(dateformatter.stringFromDate(currentDate)) == NSComparisonResult.OrderedSame {
                        // 0時から終了時間まで塗る
                        guard let guardNum = num else { return }
                        for i in 0 ... Int(hourFormatter.stringFromDate(task.finish_time))! {
                            if (guardNum + i)  == indexPath.row {
                                if task.complete_flag {
                                    cell.backgroundColor = .grayColor()
                                } else {
                                    cell.backgroundColor = colors[task.color]
                                }
                            }
                        }
                    } else {
                        // 前日から始まりまた日付をまたぐ場合は0じから23時まで全て塗る
                        for i in 0 ... 23 {
                            if (guardNum + i)  == indexPath.row {
                                if task.complete_flag {
                                    cell.backgroundColor = .grayColor()
                                } else {
                                    cell.backgroundColor = colors[task.color]
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    /// タスクナンバー（何列目）と時間からインデックスパスを特定する
    private func selectIndexPath(task: TaskDate) -> Int {
        // 一行の長さ
        let column = 24
        
        let hourFormatter = NSDateFormatter()
        hourFormatter.dateFormat = "HH"
        
        if task.task_no == 1 {
            return Int(hourFormatter.stringFromDate(task.start_time))!
        }else if task.task_no == 2 {
            return Int(hourFormatter.stringFromDate(task.start_time))! + column
        } else if task.task_no == 3 {
            return Int(hourFormatter.stringFromDate(task.start_time))! + (column * 2)
        }
        return 0
    }
    
    /// クリックされたセルに合うデータがある場合は、cellDateに入れてtrueを返す
    private func selectDate(taskNum: Int, indexPath: NSIndexPath) -> Bool {
        let realm = realmMigrations()
        let tasks = realm.objects(TaskDate)
        let dateformatter = NSDateFormatter()
        let hourFormatter = NSDateFormatter()
        dateformatter.dateFormat = "yyyy/MM/dd"
        hourFormatter.dateFormat = "HH"
        
        var num: Int?
        if taskNum == 1 {
            num = 0
        } else if taskNum == 2 {
            num = 24
        } else if taskNum == 3 {
            num = 48
        }
        guard let guardNum = num else { return false }
        for task in tasks{
            if dateformatter.stringFromDate(task.start_time).compare(dateformatter.stringFromDate(currentDate)) == NSComparisonResult.OrderedSame {
                let schedulePeriod: Int?
                if dateformatter.stringFromDate(task.start_time).compare(dateformatter.stringFromDate(task.finish_time)) == NSComparisonResult.OrderedSame {
                    schedulePeriod = Int(hourFormatter.stringFromDate(task.finish_time))! - Int(hourFormatter.stringFromDate(task.start_time))!
                } else {
                    // 開始時間の行から最終行（23時）までの情報を返す
                    schedulePeriod = 23 - Int(hourFormatter.stringFromDate(task.start_time))!
                }
                
                guard let guardSchedulePeriod = schedulePeriod else { return false }
                // 開始時間から終わりまで表示させる
                for i in 0 ... guardSchedulePeriod {
                    // 日付及び時間、列番号が同じセルのみを選択
                    if taskNum == task.task_no && (Int(hourFormatter.stringFromDate(task.start_time))! + guardNum + i) == indexPath.row {
                        cellData = task
                        return true
                    }
                }
            } else {
                let formatter = NSDateFormatter()
                formatter.dateFormat = "yyyy/MM/dd:HH"
                // 前日の23時のカラムにデータがあるかないかで今日のデータの有無を判定
                let date = dateformatter.stringFromDate(previousDate) + ":23"
                if date.compare(formatter.stringFromDate(task.start_time)) == NSComparisonResult.OrderedDescending &&
                    date.compare(formatter.stringFromDate(task.finish_time)) == NSComparisonResult.OrderedAscending {
                    if dateformatter.stringFromDate(task.finish_time).compare(dateformatter.stringFromDate(currentDate)) == NSComparisonResult.OrderedSame {
                        // 0時から終了時間まで
                        for i in 0 ... Int(hourFormatter.stringFromDate(task.finish_time))! {
                            // 日付及び時間、列番号が同じセルのみを選択
                            if  taskNum == task.task_no && (guardNum + i) == indexPath.row {
                                print("haitta")
                                cellData = task
                                return true
                            }
                        }
                    } else {
                        // 前日から始まりまた日付をまたぐ場合は0時から23時まで
                        for i in 0 ... 23 {
                            // 日付及び時間、列番号が同じセルのみを選択
                            if  taskNum == task.task_no && (guardNum + i) == indexPath.row {
                                print("kotti")
                                cellData = task
                                return true
                            }
                        }
                    }
                }
            }
        }
        return false
    }
    
        /// インデックスパスを投げると日時を返してくれる
        private func setTime(indexPath: NSIndexPath) -> Int {
            // 列数を入れる配列
            if indexPath.row <= 23 {
                return indexPath.row
            } else if 24 <= indexPath.row && indexPath.row <= 47 {
                return indexPath.row - 24
            } else if 48 <= indexPath.row && indexPath.row <= 71 {
                return indexPath.row - 48
            }
            return 0
        }
        
        /// マイグレーション
        private func realmMigrations() -> Realm {
            // Realmのインスタンスを取得
            let config = Realm.Configuration(
                schemaVersion: 4,
                migrationBlock: { migration, oldSchemaVersion in
                    if (oldSchemaVersion < 1) {}
            })
            Realm.Configuration.defaultConfiguration = config
            let realm = try! Realm()
            return realm
        }
        
        // MARK: - アクション
        
        /// 日付を翌日に更新
        @IBAction func goTommorow(sender: AnyObject) {
            currentDate = nextDate
            setupDate()
            timeLineCollectionView.reloadData()
        }
        
        /// 日付を昨日に更新
        @IBAction func goYesterday(sender: AnyObject) {
            currentDate = previousDate
            setupDate()
            timeLineCollectionView.reloadData()
        }
        
        /// セル長押し時の処理
        func cellLongPressed(sender : UILongPressGestureRecognizer){
            // 押された位置でcellのpathを取得
            let point = sender.locationInView(timeLineCollectionView)
            let indexPath = timeLineCollectionView.indexPathForItemAtPoint(point)
            
            if sender.state == UIGestureRecognizerState.Began{
                // セルが長押しされたときの処理
                print("\(indexPath!.row + 1)が長押しされました")
                
                guard let guardIndexPath = indexPath else { return }
                // 完了か未完了かを把握して変更する処理
                let taskNum = selectTaskNum(guardIndexPath)
                let dataFlg = selectDate(taskNum, indexPath: guardIndexPath)
                let realm = realmMigrations()
                if dataFlg {
                    guard let guardCellData = cellData else { return }
                    if guardCellData.complete_flag {
                        try! realm.write {
                            guardCellData.complete_flag = false
                        }
                        timeLineCollectionView.reloadData()
                    } else {
                        try! realm.write {
                            guardCellData.complete_flag = true
                        }
                        timeLineCollectionView.reloadData()
                    }
                }
            }
        }
    }
    
    // MARK: - UICollectionViewDelegate
    
    extension ViewController: UICollectionViewDelegate {
        
        // セルクリック時の処理
        func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
            print("選択しました: \(indexPath.row)")
            selectedCellIndexPath = indexPath
            let taskNum = selectTaskNum(indexPath)
            let dateFlag = selectDate(taskNum, indexPath: indexPath)
            
            // セルの中にデータが存在するかどうかで判定
            if dateFlag {
                // ポップアップを出す
                self.presentPopover(timeLineCollectionView, indexPath: indexPath)
            } else {
                // 編集画面へ飛ばす
                let storyboard: UIStoryboard = UIStoryboard(name: "Edit", bundle: NSBundle.mainBundle())
                let naviView = storyboard.instantiateInitialViewController() as! UINavigationController
                let editView: EditViewController = naviView.visibleViewController as! EditViewController
                editView.taskNum = taskNum
                // 日時を送る処理を書く
                editView.currentDate = currentDate
                let selectTime:Int = setTime(indexPath)
                editView.selectTime = selectTime
                
                presentViewController(naviView, animated: true, completion: nil)
            }
        }
    }
    
    // MARK: - UICollectionViewDateSource
    
    extension ViewController: UICollectionViewDataSource {
        
        /// データの個数を返す
        func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            // 行数
            let row = 24
            // 列数
            let column = 3
            
            return row * column
        }
        
        /// データを返す
        func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
            // コレクションビューから識別子「TestCell」のセルを取得
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("collectionCell", forIndexPath: indexPath)
            // セルの背景色を白に設定
            cell.backgroundColor = .whiteColor()
            
            // セルの羅線の太さを設定
            cell.layer.borderWidth = 0.5
            
            // データの入っているセルの色を変更
            dateCheck(cell, indexPath: indexPath)
            
            return cell
        }
    }
    
    // MARK: - UITableViewDataSource
    
    extension ViewController: UITableViewDataSource {
        
        /// セルの総数を返す
        func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return hourTime().count
        }
        
        /// セルに値を設定
        func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
            // 再利用するセルを取得
            let cell = tableView.dequeueReusableCellWithIdentifier("tableCell", forIndexPath: indexPath)
            
            // セルの羅線の太さを設定
            cell.layer.borderWidth = 0.5
            
            // セルに値を設定
            cell.textLabel?.text = "\(hourTime()[indexPath.row])"
            
            return cell
        }
    }
    
    // MARK: - UITableViewDelegate
    
    extension ViewController: UITableViewDelegate {
        
        /// 左端までセルの線を延ばす
        func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
            dayTimeTableView.separatorInset = UIEdgeInsetsZero
        }
    }
    
    // MARK: - UIScrollViewDelegate
    
    extension ViewController: UIScrollViewDelegate {
        
        /// スクロール時の処理
        func scrollViewDidScroll(scrollView: UIScrollView) {
            if scrollView == dayTimeTableView {
                timeLineCollectionView.contentOffset = dayTimeTableView.contentOffset
            } else if scrollView == timeLineCollectionView {
                dayTimeTableView.contentOffset = timeLineCollectionView.contentOffset
            }
        }
    }
    
    // MARK: - UIPopoverPresentationControllerDelegate
    
    extension ViewController: UIPopoverPresentationControllerDelegate {
        
        /// popoverをiPhoneに対応させる
        func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
            return .None
        }
        
        /// ポップオーバーが閉じられた際にindexpathを削除
        func popoverPresentationControllerDidDismissPopover(popoverPresentationController: UIPopoverPresentationController) {
            selectedCellIndexPath = nil
        }
}
    