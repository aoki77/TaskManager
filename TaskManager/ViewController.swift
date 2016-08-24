//
//  ViewController.swift
//  TaskManager
//
//  Created by 青木孝乃輔 on 2016/08/12.
//  Copyright © 2016年 青木孝乃輔. All rights reserved.
//

import UIKit
import RealmSwift

// デリゲートを宣言
protocol columnDelegate: class {
    func cellSelect(columnType: String, rowType: Int)
}


class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UICollectionViewDataSource, UICollectionViewDelegate, UIGestureRecognizerDelegate, UIScrollViewDelegate, UIPopoverPresentationControllerDelegate {
    
    @IBOutlet weak var Date: UILabel!
    @IBOutlet weak var TimeLine: UICollectionView!
    @IBOutlet weak var tommorow: UIButton!
    @IBOutlet weak var yesterday: UIButton!
    @IBOutlet weak var dayTime: UITableView!
    
    @IBOutlet weak var dayTimeWidth: NSLayoutConstraint!
    
    var delegate: columnDelegate! = nil
    
    //日付
    let cal = NSCalendar(identifier: NSCalendarIdentifierGregorian)!
    var now = NSDate()
    var tommorowDate: NSDate?
    var yesterdayDate: NSDate?
    let formatter = NSDateFormatter()
    var hourTime: NSMutableArray = ["0時", "1時", "2時", "3時", "4時", "5時", "6時", "7時", "8時", "9時", "10時", "11時", "12時", "13時", "14時", "15時", "16時", "17時", "18時", "19時", "20時", "21時", "22時", "23時"]
    // 画面全体の幅、高さ
    var rect: CGRect?
    
    // 色を格納した配列
    let colors = [UIColor.redColor(), UIColor.orangeColor(), UIColor.yellowColor()]
    
    // Realmのインスタンスを取得
    let realm = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        tommorowDate = cal.dateByAddingUnit(.Day, value: 1, toDate: now, options: NSCalendarOptions())!
        yesterdayDate = cal.dateByAddingUnit(.Day, value: -1, toDate: now, options: NSCalendarOptions())!
        
        
        // 画面全体の幅、高さを取得
        rect = UIScreen.mainScreen().bounds
        
        // 日付の設定
        // ロケールの設定
        formatter.locale = NSLocale(localeIdentifier: "en_US")
        // 日付フォーマットの設定
        formatter.dateFormat = "yyyy/MM/dd"
        Date.text = formatter.stringFromDate(now)
        tommorow.setTitle(formatter.stringFromDate(tommorowDate!), forState: UIControlState.Normal)
        yesterday.setTitle(formatter.stringFromDate(yesterdayDate!), forState: UIControlState.Normal)
        //中央寄せ
        Date.textAlignment = NSTextAlignment.Center
        Date.textColor = UIColor.blackColor()
        
        // viewにロングタップの使用宣言を追加
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(ViewController.cellLongPressed(_:)))
        longPressGestureRecognizer.delegate = self
        
        //collectionにrecognizerを設定
        TimeLine.addGestureRecognizer(longPressGestureRecognizer)
        TimeLine.backgroundColor = UIColor.whiteColor()
        TimeLine.delegate = self
        TimeLine.dataSource = self
        
        //UITableView
        //tableの大きさ、位置を設定
        let tableWidth = rect!.width / 4
        dayTimeWidth.constant = tableWidth
        dayTime.allowsSelection = false
        dayTime.separatorInset = UIEdgeInsetsZero
        
        //セルの高さ
        if rect!.height > rect!.width {
            dayTime.rowHeight = rect!.height / 16
        } else if rect!.width > rect!.height {
            dayTime.rowHeight = rect!.height / 10
        }
        
        // セル名の登録をおこなう.
        dayTime.registerClass(UITableViewCell.self, forCellReuseIdentifier: "MyCell")
        
        // スクロールバー非表示
        dayTime.showsVerticalScrollIndicator = false
        
        // 羅線の色を設定
        dayTime.separatorColor = UIColor.blackColor()
        
        // DataSourceの設定をする.
        dayTime.dataSource = self
        // Delegateを設定する.
        dayTime.delegate = self
        
    }
    
    // Gesture処理の制御
    func doGesture(gesture:UIGestureRecognizer){
        if let longPressGesture = gesture as? UILongPressGestureRecognizer{
            longPress(longPressGesture)
        }
    }
    
    // LongPressGestureの処理
    func longPress(gesture:UILongPressGestureRecognizer){
        
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
        if indexPath.row <= 23 {
            print("A")
            print(indexPath.row)
            delegate?.cellSelect("A", rowType: indexPath.row)
        } else if 24 <= indexPath.row && indexPath.row <= 47 {
            print("B")
            print(indexPath.row - 24)
            delegate?.cellSelect("B", rowType: indexPath.row - 24)
        } else if 48 <= indexPath.row && indexPath.row <= 71 {
            print("C")
            print(indexPath.row - 48)
            delegate?.cellSelect("C", rowType: indexPath.row - 48)
        }
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! CustomCell
        let controller = TaskPop()
        self.presentPopover(controller, sourceView: cell)
        
    }
    
    // データの個数を返す
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 72
    }
    
    // データを返す
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        //コレクションビューから識別子「cell」のセルを取得する。
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath)
        
        //セルの背景色を赤に設定する。
        cell.backgroundColor = UIColor.whiteColor()
        
        //セルのラベルに番号を設定する。
        
        // セルの羅線の太さを設定
        cell.layer.borderWidth=0.5
        
        // DB内にデータがある時間のセルを重要度に応じて色を変更する
        let tasks = realm.objects(TaskDate)
        let dateformatter = NSDateFormatter()
        dateformatter.dateFormat = "yyyy/MM/DD"
        
        for task in tasks{
            print("name: \(task.start_time)")
            //日付が同じセルのみを選択
            if dateformatter.stringFromDate(task.start_time).compare(dateformatter.stringFromDate(now)) == NSComparisonResult.OrderedDescending {
                print("日付が新しい")
            } else if dateformatter.stringFromDate(task.start_time).compare(dateformatter.stringFromDate(now)) == NSComparisonResult.OrderedAscending {
                print("日付が古い")
            } else {
                print("日付が同じ")
                let timefomatter = NSDateFormatter()
                timefomatter.dateFormat = "HH"
                if timefomatter.stringFromDate(task.start_time) == String(indexPath.row) {
                    cell.backgroundColor = colors[task.color]
                    
                }
            }
        }
        
        return cell
    }
    
    // セル長押し時の処理
    func cellLongPressed(sender : UILongPressGestureRecognizer){
        // 押された位置でcellのpathを取得
        let point = sender.locationInView(TimeLine)
        let indexPath = TimeLine.indexPathForItemAtPoint(point)
        
        if sender.state == UIGestureRecognizerState.Began{
            // セルが長押しされたときの処理
            // 完了か未完了かを把握して変更する処理をここに記載
            print("\(indexPath!.row + 1)が長押しされました")
        }
    }
    
    
    // セルが選択された際に呼び出す
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("Num: \(indexPath.row)")
        print("Value: \(hourTime[indexPath.row])")
    }
    
    // セルの総数を返す
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return hourTime.count
    }
    
    // セルに値を設定
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // 再利用するセルを取得
        let cell = tableView.dequeueReusableCellWithIdentifier("MyCell", forIndexPath: indexPath)
        
        // セルに値を設定
        cell.textLabel!.text = "\(hourTime[indexPath.row])"
        
        // セルの羅線の太さを設定
        cell.layer.borderWidth = 0.5
        
        return cell
    }
    
    // 左端までセルの線を延ばす
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if(dayTime.respondsToSelector(Selector("setSeparatorInset:"))){
            dayTime.separatorInset = UIEdgeInsetsZero
        }
        
        if(dayTime.respondsToSelector(Selector("setLayoutMargins:"))){
            dayTime.layoutMargins = UIEdgeInsetsZero
        }
        
        if(cell.respondsToSelector(Selector("setLayoutMargins:"))){
            cell.layoutMargins = UIEdgeInsetsZero
        }
    }
    
    // スクロール時の処理
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView == dayTime {
            TimeLine.contentOffset = dayTime.contentOffset
        } else if scrollView == TimeLine {
            dayTime.contentOffset = TimeLine.contentOffset
        }
        
    }
    
    // popover処理
    func presentPopover(viewController: UIViewController!, sourceView: UIView!) {
        
        viewController.modalPresentationStyle = UIModalPresentationStyle.Popover
        // pooverサイズ
        if rect!.height > rect!.width {
            viewController.preferredContentSize = CGSizeMake(rect!.width, rect!.height / 3)
        } else if rect!.width > rect!.height {
            viewController.preferredContentSize = CGSizeMake(rect!.height, rect!.width / 3)
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
        return UIModalPresentationStyle.None
    }
    
    // 日付を翌日に更新
    @IBAction func goTommorow(sender: AnyObject) {
        now = tommorowDate!
        viewDidLoad()
        TimeLine.reloadData()
    }
    
    // 日付を昨日に更新
    @IBAction func goYesterday(sender: AnyObject) {
        now = yesterdayDate!
        viewDidLoad()
        TimeLine.reloadData()
    }
    
    // 画面回転時の処理
    override func willAnimateRotationToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        viewDidLoad()
        TimeLine.reloadData()
    }
    
}
