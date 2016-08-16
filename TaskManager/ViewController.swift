//
//  ViewController.swift
//  TaskManager
//
//  Created by 青木孝乃輔 on 2016/08/12.
//  Copyright © 2016年 青木孝乃輔. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UIGestureRecognizerDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var Date: UILabel!
    @IBOutlet weak var TimeLine: UICollectionView!
    @IBOutlet weak var tommorow: UIButton!
    @IBOutlet weak var yesterday: UIButton!
    @IBOutlet weak var dayTime: UITableView!

    
    @IBOutlet weak var dateView: UIView!
    
    
    //日付
    let now = NSDate()
    let tommorowDate = NSDate(timeIntervalSinceNow: 24*60*60)
    let yesterdayDate = NSDate(timeIntervalSinceNow: -24*60*60)
    let formatter = NSDateFormatter()
    var hourTime: NSMutableArray = []
    
    // ステータスバーの高さを取得
    let statusHeight = UIApplication.sharedApplication().statusBarFrame.height
    // 画面全体の幅、高さを取得
    let rect = UIScreen.mainScreen().bounds
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // ナビゲーションバーの高さを取得
        let navigationBarHeight = self.navigationController?.navigationBar.frame.size.height
        
        //日付のviewの配置と高さを設定
        let dateViewYPoint = rect.height - (statusHeight + navigationBarHeight!)
        let dateViewHeight:CGFloat = 120
        dateView = UIView(frame: CGRect(x: 0, y: dateViewYPoint, width: rect.width, height: dateViewHeight))
        
        // 日付の設定
        // ロケールの設定
        formatter.locale = NSLocale(localeIdentifier: "en_US")
        // 日付フォーマットの設定
        formatter.dateFormat = "yyyy/MM/dd"
        Date.text = formatter.stringFromDate(now)
        tommorow.setTitle(formatter.stringFromDate(tommorowDate), forState: UIControlState.Normal)
        yesterday.setTitle(formatter.stringFromDate(yesterdayDate), forState: UIControlState.Normal)
        //中央寄せ
        Date.textAlignment = NSTextAlignment.Center
        
        // viewにロングタップの使用宣言を追加
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(ViewController.cellLongPressed(_:)))
        longPressGestureRecognizer.delegate = self
        
        //collectionにrecognizerを設定
        TimeLine.addGestureRecognizer(longPressGestureRecognizer)
        
        TimeLine.delegate = self
        TimeLine.dataSource = self
        
        //UITableView
        //tableの大きさ、位置を設定
        let tableYPoint = dateViewHeight + statusHeight + navigationBarHeight!
        let tableHeight = rect.height - tableYPoint
        let tableWidth = rect.width / 4
        dayTime = UITableView(frame: CGRect(x: 0, y: tableYPoint, width: tableWidth, height: tableHeight))

        for num in 0 ..< 23 {
            hourTime.addObject("\(num)時")
        }
        
        // Cell名の登録をおこなう.
        dayTime.registerClass(UITableViewCell.self, forCellReuseIdentifier: "MyCell")
        
        // DataSourceの設定をする.
        dayTime.dataSource = self
        // Delegateを設定する.
        dayTime.delegate = self


    }
    
    
    /*
     Cellが選択された際に呼び出されるデリゲートメソッド.
     */
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("Num: \(indexPath.row)")
        print("Value: \(hourTime[indexPath.row])")
    }
    
    /*
     Cellの総数を返すデータソースメソッド.
     (実装必須)
     */
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return hourTime.count
    }
    
    /*
     Cellに値を設定するデータソースメソッド.
     (実装必須)
     */
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // 再利用するCellを取得する.
        let cell = tableView.dequeueReusableCellWithIdentifier("MyCell", forIndexPath: indexPath)
        
        // Cellに値を設定する.
        cell.textLabel!.text = "\(hourTime[indexPath.row])"
        
        return cell
    }
    
    
    //* Gesture処理の制御 */
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
    
    //Cellがクリックされた時によばれます
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        print("選択しました: \(indexPath.row)")
        
    }
    
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 3
    }
    
    //データの個数を返すメソッド
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 72
    }
    
    
    
    
    
    //データを返すメソッド
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        //コレクションビューから識別子「TestCell」のセルを取得する。
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! CustomCell
        
        //セルの背景色を赤に設定する。
        cell.backgroundColor = UIColor.whiteColor()
        
        //セルのラベルに番号を設定する。
        cell.time.text = String(indexPath.row + 1)
        
        cell.layer.borderWidth=0.5
        //cell.layer.borderColor = CGColor
        
        
        return cell
        
    }
    
    //セル長押し時
    func cellLongPressed(sender : UILongPressGestureRecognizer){
        //押された位置でcellのpathを取得
        let point = sender.locationInView(TimeLine)
        let indexPath = TimeLine.indexPathForItemAtPoint(point)
        
        if sender.state == UIGestureRecognizerState.Began{
            //セルが長押しされたときの処理
            //完了か未完了かを把握して変更する処理をここに記載
            print("\(indexPath!.row + 1)が長押しされました")
            
        }
        else{
            
        }
        

        
        
//        var scrollBeginingPoint: CGPoint!
//        
//        func scrollViewWillBeginDragging(scrollView: UIScrollView) {
//            scrollBeginingPoint = scrollView.contentOffset;
//        }
//        
//        // スクロール時の処理
//        func scrollViewDidScroll(scrollView: UIScrollView) {
//            var currentPoint = scrollView.contentOffset;
//            TimeLine.reloadData()
//            if(scrollBeginingPoint.y < currentPoint.y){
//                print("下へスクロール")
//            }else{
//                print("上へスクロール")
//            }
//        }
        
    }
    
}