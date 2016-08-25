//
//  ViewController.swift
//  TaskManager
//
//  Created by 青木孝乃輔 on 2016/08/12.
//  Copyright © 2016年 青木孝乃輔. All rights reserved.
//

import UIKit

final class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UICollectionViewDataSource, UICollectionViewDelegate, UIGestureRecognizerDelegate, UIScrollViewDelegate, UIPopoverPresentationControllerDelegate {
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var timeLineCollectionView: UICollectionView!
    @IBOutlet weak var tommorowButton: UIButton!
    @IBOutlet weak var yesterdayButton: UIButton!
    @IBOutlet weak var dayTimeTableView: UITableView!
    @IBOutlet weak var dayTimeWidthLayoutConstraint: NSLayoutConstraint!
    
    //日付
    private let cal = NSCalendar(identifier: NSCalendarIdentifierGregorian)!
    private var now = NSDate()
    private var tommorowDate: NSDate?
    private var yesterdayDate: NSDate?
    private let formatter = NSDateFormatter()
    private let hourTime: NSMutableArray = []
    // 画面全体の幅、高さ
    var size: CGSize?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        size = self.view.frame.size
        setupView()
        setupTime()
        setupDate()
        setupTable()
        setupCollection()
        longTop()
    }
    
    // 初期値
    func setupView() {
        let orientation: UIInterfaceOrientation = UIApplication.sharedApplication().statusBarOrientation
        guard let guardSize = size else { return }
        switch (orientation) {
        case UIInterfaceOrientation.Portrait:
            dayTimeTableView.rowHeight = guardSize.height / 16
            dayTimeWidthLayoutConstraint.constant = guardSize.width / 4
        case UIInterfaceOrientation.LandscapeLeft, UIInterfaceOrientation.LandscapeRight:
            dayTimeTableView.rowHeight = guardSize.height / 10
            dayTimeWidthLayoutConstraint.constant = guardSize.width / 4
        default:
            break
        }
    }
    
    // 時間を入れる
    private func setupTime() {
        for num in 0 ... 23 {
            hourTime.addObject(String(num) + "時")
        }
    }
    
    // 画面回転時の処理
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        let orientation: UIInterfaceOrientation = UIApplication.sharedApplication().statusBarOrientation
        switch (orientation) {
        case UIInterfaceOrientation.Portrait:
            dayTimeTableView.rowHeight = size.height / 10
            dayTimeWidthLayoutConstraint.constant = size.width / 4
        case UIInterfaceOrientation.LandscapeLeft, UIInterfaceOrientation.LandscapeRight:
            dayTimeTableView.rowHeight = size.height / 16
            dayTimeWidthLayoutConstraint.constant = size.width / 4
        default:
            break
        }
        timeLineCollectionView.reloadData()
    }
    
    // テーブルの設定
    func setupTable() {
        dayTimeTableView.allowsSelection = false
        dayTimeTableView.separatorInset = UIEdgeInsetsZero
        
        // セル名の登録をおこなう.
        dayTimeTableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "tableCell")
        
        // スクロールバー非表示
        dayTimeTableView.showsVerticalScrollIndicator = false
        
        // 羅線の色を設定
        dayTimeTableView.separatorColor = UIColor.blackColor()
        
        // DataSourceの設定をする.
        dayTimeTableView.dataSource = self
        // Delegateを設定する.
        dayTimeTableView.delegate = self
        
    }
    // コレクションの設定
    private func setupCollection() {
        timeLineCollectionView.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: "collectionCell")
        timeLineCollectionView.backgroundColor = UIColor.whiteColor()
        timeLineCollectionView.delegate = self
        timeLineCollectionView.dataSource = self
    }
    
    // ロングタップの設定
    private func longTop() {
        // viewにロングタップの使用宣言を追加
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(ViewController.cellLongPressed(_:)))
        longPressGestureRecognizer.delegate = self
        
        //collectionにrecognizerを設定
        timeLineCollectionView.addGestureRecognizer(longPressGestureRecognizer)
    }
    
    // 日付の設定
    private func setupDate() {
        // ロケールの設定
        formatter.locale = NSLocale(localeIdentifier: "en_US")
        // 日付フォーマットの設定
        formatter.dateFormat = "yyyy/MM/dd"

        
        // 翌日の日付を設定
        tommorowDate = cal.dateByAddingUnit(.Day, value: 1, toDate: now, options: NSCalendarOptions())!
        // 昨日の日付を設定
        yesterdayDate = cal.dateByAddingUnit(.Day, value: -1, toDate: now, options: NSCalendarOptions())!
        
        guard let guardTommorowDate = tommorowDate else { return }
        guard let guardYesterdayDate = yesterdayDate else { return }
        
        dateLabel.text = formatter.stringFromDate(now)
        tommorowButton.setTitle(formatter.stringFromDate(guardTommorowDate), forState: UIControlState.Normal)
        yesterdayButton.setTitle(formatter.stringFromDate(guardYesterdayDate), forState: UIControlState.Normal)
        
        // 日付ラベルの設定
        dateLabel.textAlignment = NSTextAlignment.Center
        dateLabel.textColor = UIColor.blackColor()
    }
    
    // Gesture処理の制御
    private func doGesture(gesture:UIGestureRecognizer) {
        if let longPressGesture = gesture as? UILongPressGestureRecognizer{
            longPress(longPressGesture)
        }
    }
    
    // LongPressGestureの処理
    private func longPress(gesture:UILongPressGestureRecognizer){
        
        if gesture.state != .Began{
            return
        }
        
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.view.backgroundColor = UIColor.blueColor()
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // セルクリック時の処理
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        print("選択しました: \(indexPath.row)")
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("collectionCell", forIndexPath: indexPath)
        let controller = TaskPop()
        self.presentPopover(controller, sourceView: cell)
        
    }

    // データの個数を返す
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 72
    }
    
    // データを返す
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        //コレクションビューから識別子「TestCell」のセルを取得する。
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("collectionCell", forIndexPath: indexPath)
        //セルの背景色を赤に設定する。
        cell.backgroundColor = UIColor.whiteColor()
        
        // セルの羅線の太さを設定
        cell.layer.borderWidth=0.5
        
        return cell
        
    }
    
    //セル長押し時の処理
   func cellLongPressed(sender : UILongPressGestureRecognizer){
        //押された位置でcellのpathを取得
        let point = sender.locationInView(timeLineCollectionView)
        let indexPath = timeLineCollectionView.indexPathForItemAtPoint(point)
        
        if sender.state == UIGestureRecognizerState.Began{
            //セルが長押しされたときの処理
            //完了か未完了かを把握して変更する処理をここに記載
            print("\(indexPath!.row + 1)が長押しされました")
        }
    }
    
    
    // セルが選択された際に呼び出す
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("Num: \(indexPath.row)")
    }
    
    // セルの総数を返す
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return hourTime.count
    }
    
    // セルに値を設定
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // 再利用するセルを取得
        let cell = tableView.dequeueReusableCellWithIdentifier("tableCell", forIndexPath: indexPath)
        
        // セルの羅線の太さを設定
        cell.layer.borderWidth = 0.5
        
        // セルに値を設定
        cell.textLabel!.text = "\(hourTime[indexPath.row])"
        
        return cell
    }
    
     // 左端までセルの線を延ばす
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if(dayTimeTableView.respondsToSelector(Selector("setSeparatorInset:"))){
            dayTimeTableView.separatorInset = UIEdgeInsetsZero
        }
        
        if(dayTimeTableView.respondsToSelector(Selector("setLayoutMargins:"))){
            dayTimeTableView.layoutMargins = UIEdgeInsetsZero
        }
        
        if(cell.respondsToSelector(Selector("setLayoutMargins:"))){
            cell.layoutMargins = UIEdgeInsetsZero
        }
    }

    // スクロール時の処理
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView == dayTimeTableView {
            timeLineCollectionView.contentOffset = dayTimeTableView.contentOffset
        } else if scrollView == timeLineCollectionView {
            dayTimeTableView.contentOffset = timeLineCollectionView.contentOffset
        }

    }
    
    // popover処理
    func presentPopover(viewController: UIViewController!, sourceView: UIView!) {
        viewController.modalPresentationStyle = UIModalPresentationStyle.Popover
        guard let guardSize = size else { return }
        // pooverサイズ
        if guardSize.height > guardSize.width {
            viewController.preferredContentSize = CGSizeMake(guardSize.width, guardSize.height / 3)
        } else if guardSize.width > guardSize.height {
            viewController.preferredContentSize = CGSizeMake(guardSize.height, guardSize.width / 3)
        }
        
        
        let popoverController = viewController.popoverPresentationController
        popoverController?.delegate = self
        // 出す向き
        popoverController?.permittedArrowDirections = UIPopoverArrowDirection.Any
        
        // どこから出た感じにするか
        popoverController?.sourceView = sourceView
        popoverController?.sourceRect = sourceView.bounds
        
        self.presentViewController(viewController, animated: true, completion: nil)
    }
    
    // popoverをiPhoneに対応させる
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return .None
    }
    
    // 日付を翌日に更新
    @IBAction func goTommorow(sender: AnyObject) {
        guard let guardTommorowDate = tommorowDate else { return }
        now = guardTommorowDate
        setupDate()
    }
    
    // 日付を昨日に更新
    @IBAction func goYesterday(sender: AnyObject) {
        guard let guardYesterdayDate = yesterdayDate else { return }
        now = guardYesterdayDate
        setupDate()
    }
}
