//
//  CalendarViewController.swift
//  TaskManager
//
//  Created by 青木孝乃輔 on 2016/09/26.
//  Copyright © 2016年 青木孝乃輔. All rights reserved.
//

import UIKit

final class CalendarViewController: UIViewController {
    
    // MARK: - アウトレット
    
    @IBOutlet weak var calendatCollectionView: UICollectionView!
    
    // 定数プロパティ
    /// 一週間
    let week: Int = 7
    
    /// 選択された日付
    var selectDay = NSDate()
    
    /// 表示されている月の日付の配列
    var currentMonthDate = [NSDate]()
    
    
    var numberOfItems: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        calendatCollectionView.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: "calendarCell")
        calendatCollectionView.dataSource = self
        //collectionView!.backgroundColor = .whiteColor()

    }
    
    // MARK: - プライベート関数
    
    /// 月ごとのセルの数を返すメソッド
    private func daysAcquisition() -> Int {
        
        // 当月が何週あるかを取得
        let weekRange = NSCalendar.currentCalendar().rangeOfUnit(.WeekOfMonth, inUnit: .Month, forDate: firstDate())
        
        // 当月の週の数 × 一週間
        let allDays = weekRange.length * week
        print(allDays)
        
        return allDays
    }
    
    /// 月の初日を取得
    private func firstDate() -> NSDate {
        
        // 選択されている日付の月の初日を取得
        let components = NSCalendar.currentCalendar().components([.Year, .Month, .Day], fromDate: selectDay)
        components.day = 1
        
        // 取得した初日の日付をNSDateに変換
        let firstDateMonth = NSCalendar.currentCalendar().dateFromComponents(components)!
        
        return firstDateMonth
    }
    
    
}

// MARK: - UICollectionViewDataSource

extension CalendarViewController: UICollectionViewDataSource {
    
    /// セクション数を決める
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        // 曜日と一ヶ月の日付を表示する2つのセクションを用意する
        print("kita")
        return 2
    }

    /// セクションごとのセルの総数を決定する
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // Section毎にCellの総数を変更
        if section == 0 {
            // 最初のセクションでは曜日を表示させるため一週間分のcellを総数とする
            return week
        } else {
            // 月によって表示を変える処理を書く
            return daysAcquisition()
        }
    }
    
    /// セルのデータを返す
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        // コレクションビューから識別子「calendarCell」のセルを取得
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("calendarCell", forIndexPath: indexPath) //as! CalendarCell
        cell.backgroundColor = .whiteColor()
        cell.layer.borderWidth = 0.5
        return cell
    }
}
