//
//  ViewController.swift
//  TaskManager
//
//  Created by 青木孝乃輔 on 2016/08/12.
//  Copyright © 2016年 青木孝乃輔. All rights reserved.
//

import UIKit

final class ViewController: UIViewController, UITableViewDelegate , UIGestureRecognizerDelegate {
    
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
    
    /// 日付用のフォーマッター
    private let dateFormatter: NSDateFormatter = {
        let dateFormatter = NSDateFormatter()
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US")
        dateFormatter.dateFormat = "yyyy/MM/dd"
        return dateFormatter
    }()
    
    /// 時間
    private let hourTime: NSMutableArray = {
        let time: NSMutableArray = []
        for num in 0 ... 23 {
            time.addObject("\(num)時")
        }
        return time
    }()
    
    // MARK: - 変数プロパティ
    
    /// 当日の日付
    private var currentDate = NSDate()
    
    /// 翌日の日付
    private var nextDate: NSDate = NSDate() {
        didSet {
            tommorowButton.setTitle(dateFormatter.stringFromDate(nextDate), forState: .Normal)
        }
    }
    
    /// 昨日の日付
    private var previousDate: NSDate = NSDate() {
        didSet {
            yesterdayButton.setTitle(dateFormatter.stringFromDate(previousDate), forState: .Normal)
        }
    }
    
    /// 選択されたセルのインデックスパス
    private var selectedCellIndexPath: NSIndexPath?
    
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
        updateDate()
        setupTable()
        setupCollection()
        
    }
    
    /// オートレイアウト確定後にviewを設定
    override func viewDidLayoutSubviews() {
        setupView()
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
                let sourceView = guardSelf.timeLineCollectionView.cellForItemAtIndexPath(indexPath)
                guard let guardSourceView = sourceView else { return }
                guardSelf.presentPopover(guardSourceView)
            }
        }
    }
    
    // MARK: - プライベート関数
    
    /// 初期値を設定
    private func setupView() {
        switch UIApplication.sharedApplication().statusBarOrientation {
        case .Portrait, .PortraitUpsideDown, .Unknown:
            dayTimeTableView.rowHeight = timeLineCollectionView.bounds.size.height / 12
            dayTimeWidthLayoutConstraint.constant = self.view.frame.size.width / 4

        case .LandscapeLeft, .LandscapeRight:
            dayTimeTableView.rowHeight = timeLineCollectionView.bounds.size.height / 10
            dayTimeWidthLayoutConstraint.constant = self.view.frame.size.width / 4
        }
    }
    
    /// 日付を更新
    private func updateDate() {
        nextDate = calendar.dateByAddingUnit(.Day, value: 1, toDate: currentDate, options: NSCalendarOptions())!
        previousDate = calendar.dateByAddingUnit(.Day, value: -1, toDate: currentDate, options: NSCalendarOptions())!
        
        // 日付ラベルの設定
        dateLabel.text = dateFormatter.stringFromDate(currentDate)
    }
    
    /// テーブルの設定
    private func setupTable() {
        dayTimeTableView.separatorInset = UIEdgeInsetsZero
        
        // セル名の登録をおこなう.
        dayTimeTableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "tableCell")
        
        // スクロールバー非表示
        dayTimeTableView.showsVerticalScrollIndicator = false
        
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
    
    /// popover処理
    private func presentPopover(sourceView: UICollectionViewCell) {
        let storyboard: UIStoryboard = UIStoryboard(name: "TaskPop", bundle: NSBundle.mainBundle())
        let viewController = storyboard.instantiateViewControllerWithIdentifier("TaskPop") as! TaskPopoverViewController
        viewController.modalPresentationStyle = .Popover
        viewController.preferredContentSize = popoverSize
        if let popoverViewController = presentedViewController {
            // popoverを閉じる
            popoverViewController.dismissViewControllerAnimated(false, completion: nil)
        }
        
        if let popoverController = viewController.popoverPresentationController {
            popoverController.delegate = self
            // 出す向き
            popoverController.permittedArrowDirections = popoverDirection
            
            // どこから出た感じにするか
            popoverController.sourceView = sourceView
            popoverController.sourceRect = sourceView.bounds
        }
        presentViewController(viewController, animated: true, completion: nil)
    }
    
    // MARK: - アクション
    
    /// 日付を翌日に更新
    @IBAction func goTommorow(sender: AnyObject) {
        currentDate = nextDate
        updateDate()
    }
    
    /// 日付を昨日に更新
    @IBAction func goYesterday(sender: AnyObject) {
        currentDate = previousDate
        updateDate()
    }
    
    /// セル長押し時の処理
    func cellLongPressed(sender : UILongPressGestureRecognizer){
        // 押された位置でcellのpathを取得
        let point = sender.locationInView(timeLineCollectionView)
        let indexPath = timeLineCollectionView.indexPathForItemAtPoint(point)
        
        if sender.state == UIGestureRecognizerState.Began{
            // セルが長押しされたときの処理
            // 完了か未完了かを把握して変更する処理をここに記載
            print("\(indexPath!.row + 1)が長押しされました")
        }
    }
}

// MARK: - UICollectionViewDelegate

extension ViewController: UICollectionViewDelegate {
    
    // セルクリック時の処理
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        print("選択しました: \(indexPath.row)")
        selectedCellIndexPath = indexPath
        let sourceView = collectionView.cellForItemAtIndexPath(indexPath)
        guard let guardSourceView = sourceView else { return }
        presentPopover(guardSourceView)
    }
}

// MARK: - UICollectionViewDateSource

extension ViewController: UICollectionViewDataSource {
    
    /// データの個数を返す
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // 行数
        let row = hourTime.count
        // 列数
        let column = 3
        
        return row * column
    }
    /// データを返す
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        // コレクションビューから識別子「collectionCell」のセルを取得
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("collectionCell", forIndexPath: indexPath)
        // セルの背景色を赤に設定
        cell.backgroundColor = .whiteColor()
        
        // セルの羅線の太さを設定
        cell.layer.borderWidth = 0.5
        
        return cell
    }
}

// MARK: - UITableViewDataSource

extension ViewController: UITableViewDataSource {
    
    /// セルの総数を返す
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return hourTime.count
    }
    
    /// セルに値を設定
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // 再利用するセルを取得
        let cell = tableView.dequeueReusableCellWithIdentifier("tableCell", forIndexPath: indexPath)
        
        // セルの羅線の太さを設定
        cell.layer.borderWidth = 0.5

        // セルに値を設定
        cell.textLabel?.text = "\(hourTime[indexPath.row])"
        
        return cell
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
