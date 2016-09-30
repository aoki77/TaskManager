//
//  CalendarViewController.swift
//  TaskManager
//
//  Created by 青木孝乃輔 on 2016/09/26.
//  Copyright © 2016年 青木孝乃輔. All rights reserved.
//

import UIKit
import CalculateCalendarLogic

final class CalendarViewController: UIViewController {
    
    // MARK: - アウトレット
    
    @IBOutlet weak var calendarCollectionView: UICollectionView!
    @IBOutlet weak var CalendarNavItem: UINavigationItem!
    
    // MARK: - 定数プロパティ
    
    /// 一週間
    private let week = 7
    
    /// 日付のカラムの行数
    private let columnNum = 6
    
    /// 曜日
    private let dayOfWeek = ["日", "月", "火", "水", "木", "金", "土"]
    
    /// 年月のフォーマッター
    private let dateFormatterYearMonth: NSDateFormatter = {
        let dateFormatter = NSDateFormatter()
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US")
        dateFormatter.dateFormat = "yyyy/MM"
        return dateFormatter
    }()
    
    /// 年のフォーマッター
    private let dateFormatterYear: NSDateFormatter = {
        let dateFormatter = NSDateFormatter()
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US")
        dateFormatter.dateFormat = "yyyy"
        return dateFormatter
    }()
    
    /// 月のフォーマッター
    private let dateFormatterMonth: NSDateFormatter = {
        let dateFormatter = NSDateFormatter()
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US")
        dateFormatter.dateFormat = "MM"
        return dateFormatter
    }()
    
    /// 日のフォーマッター
    private let dateFormatterDay: NSDateFormatter = {
        let dateFormatter = NSDateFormatter()
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US")
        dateFormatter.dateFormat = "d"
        return dateFormatter
    }()
    
    // MARK: - 変数プロパティ
    
    /// 現在の月
    var currentMonth = NSDate()
    
    /// 表示されている月の日付の配列
    private var currentMonthDate = [NSDate]()
    
    // MARK: - ライフサイクル関数
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupContents()
        updateCurrentMonth()
    }
    
    // MARK: - プライベート関数
    
    private func setupContents() {
        calendarCollectionView.delegate = self
        calendarCollectionView.dataSource = self
    }
    
    private func updateCurrentMonth() {
        CalendarNavItem.title = dateFormatterYearMonth.stringFromDate(currentMonth)
    }
    
    /// 月の初日を取得
    private func firstDate() -> NSDate {
        
        // 選択されている日付の月の初日を取得
        let components = NSCalendar.currentCalendar().components([.Year, .Month, .Day], fromDate: currentMonth)
        components.day = 1
        
        // 取得した初日の日付をNSDateに変換
        let firstDateMonth = NSCalendar.currentCalendar().dateFromComponents(components)!
        
        return firstDateMonth
    }
    
    /// 表記する日にちの取得
    private func dateForCellAtIndexPath(num: Int) {
        
        // 月の初日が一週間を日曜を開始するとした際の経過した日数を取得する
        let firstDay = NSCalendar.currentCalendar().ordinalityOfUnit(.Day, inUnit: .WeekOfMonth, forDate: firstDate())
        
        for i in 0 ..< num {
            // 月の初日と表示される日付の差を計算する
            let dateComponents = NSDateComponents()
            dateComponents.day = i - (firstDay - 1)
            // 月の初日より前の日付を取得
            let date = NSCalendar.currentCalendar().dateByAddingComponents(dateComponents, toDate: firstDate(), options: NSCalendarOptions(rawValue: 0))!
            currentMonthDate.append(date)
        }
    }
    
    /// カレンダーの日付の表記変更
    private func conversionDateFormat(indexPath: NSIndexPath) -> String {
        dateForCellAtIndexPath(columnNum * week)
        return dateFormatterDay.stringFromDate(currentMonthDate[indexPath.row])
    }
    
    /// 翌月を返す
    private func nextMonth() -> NSDate {
        let addValue: Int = 1
        let calendar = NSCalendar.currentCalendar()
        let dateComponents = NSDateComponents()
        dateComponents.month = addValue
        return calendar.dateByAddingComponents(dateComponents, toDate: currentMonth, options: NSCalendarOptions(rawValue: 0))!
    }
    
    /// 昨月を返す
    private func lastMonth() -> NSDate {
        let addValue = -1
        let calendar = NSCalendar.currentCalendar()
        let dateComponents = NSDateComponents()
        dateComponents.month = addValue
        return calendar.dateByAddingComponents(dateComponents, toDate: currentMonth, options: NSCalendarOptions(rawValue: 0))!
    }
    
    /// セルの背景色を変更する
    private func cellColorChange(cell: CalendarCell, indexPath: NSIndexPath) {
        if dateFormatterYearMonth.stringFromDate(currentMonthDate[indexPath.row]).compare(dateFormatterYearMonth.stringFromDate(currentMonth)) != NSComparisonResult.OrderedSame {
            cell.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
        } else if indexPath.row % 7 == 0 {
            cell.backgroundColor = UIColor(red: 1.0, green: 0.8, blue: 1.0, alpha: 1.0)
        } else if (indexPath.row + 1) % 7 == 0 {
            cell.backgroundColor = UIColor(red: 0.8, green: 1.0, blue: 1.0, alpha: 1.0)
        } else {
            cell.backgroundColor = .whiteColor()
        }
    }
    
    /// カレンダーのテキストの色を変更する
    private func textColorChange(cell: CalendarCell, indexPath: NSIndexPath) {
        if indexPath.row % 7 == 0 {
            cell.calenderLabel.textColor = .redColor()
        } else if (indexPath.row + 1) % 7 == 0 {
            cell.calenderLabel.textColor = .blueColor()
        } else {
            cell.calenderLabel.textColor = .blackColor()
        }
        
        // 該当日が祝日かどうかを判定してboolを返す
        let holidayFlg = CalculateCalendarLogic().judgeJapaneseHoliday(Int(dateFormatterYear.stringFromDate(currentMonthDate[indexPath.row]))!, month: Int(dateFormatterMonth.stringFromDate(currentMonthDate[indexPath.row]))!, day: Int(dateFormatterDay.stringFromDate(currentMonthDate[indexPath.row]))!)
        
        if holidayFlg {
            cell.calenderLabel.textColor = .redColor()
        }
    }

    // MARK: - アクション

    @IBAction func clickNextMonth(sender: UIBarButtonItem) {
        currentMonthDate.removeAll()
        currentMonth = nextMonth()
        updateCurrentMonth()
        calendarCollectionView.reloadData()
    }
    
    @IBAction func clickLastMonth(sender: UIBarButtonItem) {
        currentMonthDate.removeAll()
        currentMonth = lastMonth()
        updateCurrentMonth()
        calendarCollectionView.reloadData()
    }
}

// MARK: - UICollectionViewDataSource

extension CalendarViewController: UICollectionViewDataSource {
    
    /// セクション数を決める
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        // 曜日と一ヶ月の日付を表示する2つのセクションを用意する
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
            return columnNum * week
        }
    }
    
    /// セルのデータを返す
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        // コレクションビューから識別子「calendarCell」のセルを取得
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("calendarCell", forIndexPath: indexPath) as! CalendarCell
        
        // セクションによってテキストと色を変更する
        if indexPath.section == 0 {
            cell.backgroundColor = UIColor(red: 0.8, green: 1.0, blue: 0.8, alpha: 1.0)
            cell.calenderLabel.text = dayOfWeek[indexPath.row]
            cell.calenderLabel.textColor = .blackColor()
        } else if indexPath.section == 1 {
            cell.calenderLabel.text = conversionDateFormat(indexPath)
            textColorChange(cell, indexPath: indexPath)
            cellColorChange(cell, indexPath: indexPath)
        }
        cell.layer.borderWidth = 0.5
        cell.layer.borderColor = UIColor(white: 0.9, alpha: 1.0).CGColor
        return cell
    }
}

// MARK: - UICollectionViewDelegate

extension CalendarViewController: UICollectionViewDelegate {
    
    // セルクリック時の処理
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        if indexPath.section == 1 {
            
            // タイムスケジュール画面を生成
            let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let mainNaviView = mainStoryboard.instantiateInitialViewController() as! UINavigationController
            let mainView = mainNaviView.visibleViewController as! ViewController
            
            mainView.currentDate = currentMonthDate[indexPath.row]
            
            // カレンダー画面を生成
            let calendarStoryboard: UIStoryboard = UIStoryboard(name: "Calendar", bundle: NSBundle.mainBundle())
            let calendarNaviView = calendarStoryboard.instantiateInitialViewController() as! UINavigationController
            
            // splitViewControllerを生成
            let splitView = UISplitViewController()
            
            // splitviewControllerのmasterとdetialのサイズを1:1にする
            splitView.minimumPrimaryColumnWidth = UIScreen.mainScreen().bounds.size.width / 2
            splitView.maximumPrimaryColumnWidth = UIScreen.mainScreen().bounds.size.width / 2
            
            // spritViewControllerに各viewを追加
            splitView.viewControllers = [calendarNaviView, mainNaviView]
            
            presentViewController(splitView, animated: false, completion: nil)
        }

    }
    
}

