//
//  EditViewController.swift
//  TaskManager
//
//  Created by 青木孝乃輔 on 2016/08/22.
//  Copyright © 2016年 青木孝乃輔. All rights reserved.
//

import UIKit
import RealmSwift

final class EditViewController: UITableViewController {
    
    /// MARK: - アウトレット
    
    @IBOutlet weak private var editTable: UITableView!
    @IBOutlet weak private var titleTextField: UITextField!
    @IBOutlet weak private var startTimeLabel: UILabel!
    @IBOutlet weak private var finishTimeLabel: UILabel!
    @IBOutlet weak private var alertLabel: UILabel!
    @IBOutlet weak private var startPicker: UIPickerView!
    @IBOutlet weak private var finishPicker: UIPickerView!
    @IBOutlet weak private var alertPicker: UIPickerView!
    @IBOutlet weak private var colorSelectButton: UIButton!
    @IBOutlet weak private var detailText: UITextView!
    @IBOutlet weak private var detailRow: UITableViewCell!
    @IBOutlet weak private var detailPlaceHolderLabel: UILabel!
    @IBOutlet weak private var alertCheckCell: UITableViewCell!
    @IBOutlet weak private var alertTitleLabel: UILabel!
    @IBOutlet weak var deleteButton: UIBarButtonItem!
    
    // MARK: - 定数プロパティ
    private let years = (2015...2030).map { $0 }
    private let months = (1...12).map { $0 }
    private let days =  (1...31).map { $0 }
    private let hours = (0...23).map { $0 }
    private let mins = (0...59).map { $0 }
    
    /// 色を格納した配列
    private let colors = [UIColor.redColor(), UIColor.orangeColor(), UIColor.yellowColor()]
    
    /// テキストを格納した配列
    private let texts = ["高", "中", "低"]
    
    // MARK: - 変数プロパティ
    
    ///　DatePickerの表示状態（初期状態は非表示（false））
    private var pickerShowFlag = [false, false, false]
    
    /// アラートの表示状態(初期状態は非表示（false））
    private var alertShowFlag = false
    
    /// 色と重要度を把握するための数値（初期値は2（黄色、重要度：低））
    private var colorNum = 2
    
    /// 列の番号
    var taskNum: Int?
    /// 当日の日付
    var currentDate: NSDate?
    /// 選択された時間
    var selectTime: Int?
    /// 選択されたデータ
    var cellData: TaskDate?
    /// アラートの通知フラグ
    var alertFlag = false
    
    // MARK: - ライフサイクル関数
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupContents()
    }
    
    /// 画面回転時の処理
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        
    }
    
    // MARK: - プライベート関数
    
    /// 各コンテンツの初期設定
    private func setupContents() {
        
        // 各ピッカーにタグを設定
        startPicker.tag = 0
        finishPicker.tag = 1
        alertPicker.tag = 2
        
        // タイトル入力フォームの設定
        titleTextField.layer.borderColor = UIColor.clearColor().CGColor
        
        for notification: UILocalNotification in UIApplication.sharedApplication().scheduledLocalNotifications! {
            if let userInfo = notification.userInfo {
                let alertId = userInfo["alertId"] as! Int
                guard let guardCellData = cellData else { return }
                if alertId == guardCellData.id {
                    // アラートが設定されていればアラートを表示
                    alertCellCheck()
                } else {
                    // 設定されていなければアラートを非表示
                    alertTitleLabel.hidden = true
                    alertLabel.hidden = true
                }
            }
        }

        // ピッカーを隠す
        startPicker.hidden = true
        finishPicker.hidden = true
        alertPicker.hidden = true
        
        // ボタンの初期設定
        colorSelectButton.setTitleColor(.yellowColor(), forState: . Normal)
        colorSelectButton.setTitle("低", forState: .Normal)
        
        // テキストビューの設定
        
        // テキストビューのスクロールを禁止
        detailText.scrollEnabled = false
        
        // テーブルの高さを可変にする
        editTable.estimatedRowHeight = detailRow.bounds.size.height
        editTable.rowHeight = UITableViewAutomaticDimension
        
        detailPlaceHolderLabel.textColor = UIColor.lightGrayColor()
        
        detailText.delegate = self
        
        // ピッカーの設定
        startPicker.dataSource = self
        finishPicker.dataSource = self
        alertPicker.dataSource = self
        startPicker.delegate = self
        finishPicker.delegate = self
        alertPicker.delegate = self
        
        // タスクが登録されていない場合はsetupPickerを呼び出す
        if cellData == nil {
            // ピッカーに初期値をセット
            guard let guardCurrentDate = currentDate else { return }
            setupPicker(startPicker, date: guardCurrentDate)
            setupPicker(finishPicker, date: guardCurrentDate)
            setupPicker(alertPicker, date: guardCurrentDate)
        } else {
            // タスクが既に登録されている場合は受け取ったデータを初期値としてセットする
            setupValue()
        }
        
        // ピッカーの初期値をLabelに挿入
        setLabel(startPicker, label: startTimeLabel)
        setLabel(finishPicker, label: finishTimeLabel)
        setLabel(alertPicker, label: alertLabel)
    }
    
    /// 既にタスクデータが存在している場合、データから値を取り出し初期値として入力、表示させる
    private func setupValue() {
        guard let guardCellData = cellData else { return }
        titleTextField.text = guardCellData.title
        detailText.text = guardCellData.detail
        detailPlaceHolderLabel.hidden = true
        colorNum = guardCellData.color
        colorSelectButton.setTitleColor(colors[guardCellData.color], forState: . Normal)
        colorSelectButton.setTitle(texts[guardCellData.color], forState: .Normal)
        setupPicker(startPicker, date: guardCellData.start_time)
        setupPicker(finishPicker, date: guardCellData.finish_time)
        setupPicker(alertPicker, date: guardCellData.alert_time)
        currentDate = guardCellData.start_time
    }
    
    /// ピッカーに入力された値をNSDate型に変換する
    private func dateFormat(pickerView: UIPickerView) -> NSDate {
        let year = years[pickerView.selectedRowInComponent(0)]
        let month = months[pickerView.selectedRowInComponent(1)]
        let day = days[pickerView.selectedRowInComponent(2)]
        let hour = hours[pickerView.selectedRowInComponent(3)]
        let date: String
        let dateFormatter = NSDateFormatter()
        // アラートピッカーのみ「分」まで表示
        if pickerView == alertPicker {
            let min = mins[pickerView.selectedRowInComponent(4)]
            date = "\(year)-\(month)-\(day) \(hour):\(min)"
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        } else {
            date = "\(year)-\(month)-\(day) \(hour)"
            dateFormatter.dateFormat = "yyyy-MM-dd HH"
        }
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US")
        dateFormatter.timeZone = NSTimeZone.localTimeZone()
        
        return dateFormatter.dateFromString(date)!
        
    }
    
    /// ピッカーに初期値(選択されたセルの日時)をセットする
    private func setupPicker(picker: UIPickerView, date: NSDate){
        let year = NSDateFormatter()
        year.dateFormat = "yyyy"
        let month = NSDateFormatter()
        month.dateFormat = "MM"
        let day = NSDateFormatter()
        day.dateFormat = "dd"
        let hour = NSDateFormatter()
        hour.dateFormat = "HH"
        
        let currentYear = Int(year.stringFromDate(date))
        let currentMonth = Int(month.stringFromDate(date))
        let currentDay = Int(day.stringFromDate(date))
        
        guard let guardCurrentYear = currentYear else { return }
        guard let guardCurrentMonth = currentMonth else { return }
        guard let guardCurrentDay = currentDay else { return }
        
        picker.selectRow(years.indexOf(guardCurrentYear)!, inComponent: 0, animated: true)
        picker.selectRow(months.indexOf(guardCurrentMonth)!, inComponent: 1, animated: true)
        picker.selectRow(days.indexOf(guardCurrentDay)!, inComponent: 2, animated: true)
        
        if cellData == nil {
            guard let guardSelectTime = selectTime else { return }
            picker.selectRow(guardSelectTime, inComponent: 3, animated: true)
        } else {
            let currentHour = Int(hour.stringFromDate(date))
            guard let guardCurrentHour = currentHour else { return }
            picker.selectRow(hours.indexOf(guardCurrentHour)!, inComponent: 3, animated: true)
            
            if picker == alertPicker {
                let min = NSDateFormatter()
                min.dateFormat = "mm"
                let currentMin = Int(min.stringFromDate(date))
                guard let guardCurrentMin = currentMin else { return }
                picker.selectRow(mins.indexOf(guardCurrentMin)!, inComponent: 4, animated: true)
            }
        }
    }
    
    /// フラグに応じてピッカーの表示、非表示の関数を呼び出す
    private func dspDatePicker(picker: UIPickerView) {
        if pickerShowFlag[picker.tag] {
            hideDatePickerCell(picker)
        } else {
            showDatePickerCell(picker)
        }
    }
    
    /// ピッカーを表示
    private func showDatePickerCell(picker: UIPickerView) {
        // フラグの更新
        pickerShowFlag[picker.tag] = true
        
        // セルのアニメーション準備
        editTable.beginUpdates()
        editTable.endUpdates()
        
        // Pickerを表示
        picker.hidden = false
    }
    
    /// ピッカーを非表示
    private func hideDatePickerCell(picker: UIPickerView) {
        // フラグの更新
        pickerShowFlag[picker.tag] = false
        
        // セルのアニメーション準備
        editTable.beginUpdates()
        editTable.endUpdates()
        
        // Pickerを非表示
        picker.hidden = true
    }
    
    /// ポップオーバーの処理
    private func presentPopver(viewController: UIViewController!, sourceView: UIView!) {
        viewController.modalPresentationStyle = UIModalPresentationStyle.Popover
        // popの大きさ
        switch UIApplication.sharedApplication().statusBarOrientation {
        case .Portrait, .PortraitUpsideDown, .Unknown:
            viewController.preferredContentSize = CGSizeMake(UIScreen.mainScreen().bounds.width / 2, UIScreen.mainScreen().bounds.height / 5)
        case .LandscapeLeft, .LandscapeRight:
            viewController.preferredContentSize = CGSizeMake(UIScreen.mainScreen().bounds.width / 5, UIScreen.mainScreen().bounds.height / 4)
        }
        
        let popoverController = viewController.popoverPresentationController
        popoverController?.delegate = self
        // 出す向き(
        popoverController?.permittedArrowDirections = UIPopoverArrowDirection.Left
        // どこから出た感じにするか
        popoverController?.sourceView = sourceView
        popoverController?.sourceRect = sourceView.bounds
        
        self.presentViewController(viewController, animated: true, completion: nil)
    }
    
    private func setLabel(pickerView: UIPickerView, label: UILabel) {
        let year = years[pickerView.selectedRowInComponent(0)]
        let month = months[pickerView.selectedRowInComponent(1)]
        let day = days[pickerView.selectedRowInComponent(2)]
        let hour = hours[pickerView.selectedRowInComponent(3)]
        
        if alertPicker == pickerView {
            let min = mins[pickerView.selectedRowInComponent(4)]
            label.text = "\(year)年 \(month)月 \(day)日 \(hour)時\(min)分"
        } else {
            label.text = "\(year)年 \(month)月 \(day)日 \(hour)時"
        }
    }
    
    /// 入力したタスクの時間が他と被っているかを確認
    private func checkDate() -> Bool {
        let realm = db().realmMigrations()
        guard let guardTaskNum = taskNum else { return false }
        let tasks = realm.objects(TaskDate).filter("task_no == \(guardTaskNum)")
        var flg = true
        for task in tasks {
            // 開始日時が被っていいたらfalse
            if dateFormat(startPicker).compare(task.finish_time) == NSComparisonResult.OrderedAscending &&
                dateFormat(startPicker).compare(task.start_time) == NSComparisonResult.OrderedDescending ||
                dateFormat(startPicker).compare(task.finish_time) == NSComparisonResult.OrderedSame {
                flg = false
            }
            // 終了日時が被っていたらfalse
            if dateFormat(finishPicker).compare(task.start_time) == NSComparisonResult.OrderedDescending &&
                dateFormat(finishPicker).compare(task.finish_time) == NSComparisonResult.OrderedAscending ||
                dateFormat(finishPicker).compare(task.start_time) == NSComparisonResult.OrderedSame {
                flg = false
            }
        }
        
        // 被っている場合はアラートを出す
        if flg == false {
            // 終了時間が開始時間よりも前の場合にアラートを出す
            let alert: UIAlertController = UIAlertController(title: "既にタスクが存在します", message: "", preferredStyle:  UIAlertControllerStyle.Alert)
            let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler:{
                // ボタンが押された時の処理
                (action: UIAlertAction!) -> Void in
            })
            // アラートの追加
            alert.addAction(defaultAction)
            presentViewController(alert, animated: true, completion: nil)
        }
        return flg
    }
    
    /// ローカル通知の内容を作成
    private func alertSet(task: TaskDate) {
        for notification: UILocalNotification in UIApplication.sharedApplication().scheduledLocalNotifications! {
            if let userInfo = notification.userInfo {
                let alertId = userInfo["alertId"] as! Int
                if alertId == task.id {
                    UIApplication.sharedApplication().cancelLocalNotification(notification)
                }
            }
        }
        
        let newNotification: UILocalNotification = UILocalNotification()
        newNotification.alertTitle = task.title
        newNotification.alertBody = task.detail
        newNotification.soundName = UILocalNotificationDefaultSoundName
        newNotification.timeZone = NSTimeZone.localTimeZone()
        newNotification.fireDate = task.alert_time
        // アラートにユニークな値を設定
        newNotification.userInfo = ["alertId": task.id]
        UIApplication.sharedApplication().scheduleLocalNotification(newNotification)
    }
    
    /// アラートの表示状況に応じて表示非表示を変更
    private func alertCellCheck() {
        if alertCheckCell.accessoryType == UITableViewCellAccessoryType.None {
            alertCheckCell.accessoryType = UITableViewCellAccessoryType.Checkmark
            alertShowFlag = true
            // セルのアニメーション準備
            editTable.beginUpdates()
            editTable.endUpdates()
            alertTitleLabel.hidden = false
            alertLabel.hidden = false
            
            alertFlag = true
        } else if alertCheckCell.accessoryType == UITableViewCellAccessoryType.Checkmark {
            alertCheckCell.accessoryType = UITableViewCellAccessoryType.None
            alertShowFlag = false
            // セルのアニメーション準備
            editTable.beginUpdates()
            editTable.endUpdates()
            alertTitleLabel.hidden = true
            alertLabel.hidden = true
            
            alertFlag = false
        }
    }
    
    /// viewを二つ渡すとspitViewにする
    private func presentSplitView(leftView: UIViewController, rightView: UIViewController) {
        // splitViewControllerを生成
        let splitView = UISplitViewController()
        
        // splitviewControllerのmasterとdetialのサイズを1:1にする
        splitView.minimumPrimaryColumnWidth = UIScreen.mainScreen().bounds.size.width / 2
        splitView.maximumPrimaryColumnWidth = UIScreen.mainScreen().bounds.size.width / 2
        
        // spritViewControllerに各viewを追加
        splitView.viewControllers = [leftView, rightView]
        
        presentViewController(splitView, animated: false, completion: nil)
    }

    // MARK: - UITableViewDelegate

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        //　DatePicker表示時のセルの高さを設定
        let pickerCellHeight: CGFloat = UIScreen.mainScreen().bounds.height / 4
        
        // セルの高さを返す
        var height: CGFloat = editTable.rowHeight
        
        // フラグに応じて選択されたアラートの行の高さを変更
        if indexPath.row == 6 {
            if alertShowFlag == false {
                height = CGFloat(0)
            }
        }
        
        // フラグに応じて選択されたピッカーの行の高さを変更
        if indexPath.row == 2 {
            if pickerShowFlag[0] {
                height = pickerCellHeight
            } else {
                height = CGFloat(0)
            }
        } else if indexPath.row == 4 {
            if pickerShowFlag[1] {
                height = pickerCellHeight
            } else {
                height = CGFloat(0)
            }
        } else if indexPath.row == 7 {
            if pickerShowFlag[2] {
                height = pickerCellHeight
            } else {
                height = CGFloat(0)
            }
        }
        return height
    }
    
    /// セルがタッチされた時の処理
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        // アラートの表示状況に応じて表示非表示を変更
        if indexPath.row == 5 {
            alertCellCheck()
        }
        
        // 日付の行が選択された際にピッカーの表示切り替えの関数を呼び出す
        if indexPath.row == 1 {
            dspDatePicker(startPicker)
        } else if indexPath.row == 3 {
            dspDatePicker(finishPicker)
        } else if indexPath.row == 6 {
            dspDatePicker(alertPicker)
        }
    }
    
    // MARK: - アクション
    
    /// 重要度ボタンが押された際の処理
    @IBAction func clickColorSelectButton(sender: UIButton) {
        let controller = ColorTableViewController()
        presentPopver(controller, sourceView: sender)
        controller.delegate = self
    }
    
    /// 完了ボタンを押された際の処理
    @IBAction func clickCompletButton(sender: UIBarButtonItem) {
        
        // タイトルまたは詳細が未入力の際にアラートを出す
        guard let guardTitle = titleTextField.text else { return }
        guard let guardDetail = detailText.text else { return }
        if guardTitle.characters.count == 0 || guardDetail.characters.count == 0 {
            let alert: UIAlertController = UIAlertController(title: "未入力項目があります", message: "", preferredStyle:  UIAlertControllerStyle.Alert)
            let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler:{
                // ボタンが押された時の処理
                (action: UIAlertAction!) -> Void in
            })
            // アラートの追加
            alert.addAction(defaultAction)
            presentViewController(alert, animated: true, completion: nil)
            
        } else if dateFormat(startPicker).compare(dateFormat(finishPicker)) == NSComparisonResult.OrderedDescending {
            // 終了時間が開始時間よりも前の場合にアラートを出す
            let alert: UIAlertController = UIAlertController(title: "入力時刻が正しくありません", message: "", preferredStyle:  UIAlertControllerStyle.Alert)
            let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler:{
                // ボタンが押された時の処理
                (action: UIAlertAction!) -> Void in
            })
            // アラートの追加
            alert.addAction(defaultAction)
            presentViewController(alert, animated: true, completion: nil)
            
        } else {
            let realm = db().realmMigrations()
            if let data = cellData {
                // 更新
                try! realm.write {
                    data.title = titleTextField.text!
                    data.start_time = dateFormat(startPicker)
                    data.finish_time = dateFormat(finishPicker)
                    data.alert_time = dateFormat(alertPicker)
                    data.color = colorNum
                    data.detail = detailText.text
                    data.complete_flag = false
                }
                if alertFlag{
                    alertSet(data)
                }
            } else {
                //　その時間にデータが既にあるかどうかを確認
                if checkDate() {
                    
                    // 新規登録
                    let task = TaskDate()
                    var maxId: Int { return try! Realm().objects(TaskDate).sorted("id").last?.id ?? 0 }
                    guard let guardTaskNum = taskNum else { return }
                    try! realm.write {
                        task.id = maxId + 1
                        task.title = titleTextField.text!
                        task.start_time = dateFormat(startPicker)
                        task.finish_time = dateFormat(finishPicker)
                        task.alert_time = dateFormat(alertPicker)
                        task.color = colorNum
                        task.detail = detailText.text
                        task.task_no = guardTaskNum
                        task.complete_flag = false
                        realm.add(task, update: true)
                    }
                    print("登録されました\(task)")
                    if alertFlag {
                        alertSet(task)
                    }
                }
            }
        }
        
        // タイムスケジュール画面を生成
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let mainNaviView = mainStoryboard.instantiateInitialViewController() as! UINavigationController
        let mainView = mainNaviView.visibleViewController as! ViewController
        guard let guardCurrentDate = currentDate else { return }
        mainView.currentDate = guardCurrentDate
        
        let calendarStoryboard: UIStoryboard = UIStoryboard(name: "Calendar", bundle: nil)
        let CalendarNaviView = calendarStoryboard.instantiateInitialViewController() as! UINavigationController
        
        presentSplitView(CalendarNaviView, rightView: mainNaviView)

    }
    
    
    /// タイムスケジュール画面に戻る
    @IBAction func returnTimeLine(sender: UIBarButtonItem) {
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let mainNaviView = mainStoryboard.instantiateInitialViewController() as! UINavigationController
        let mainView = mainNaviView.visibleViewController as! ViewController
        guard let guardCurrentDate = currentDate else { return }
        mainView.currentDate = guardCurrentDate
        
        let calendarStoryboard: UIStoryboard = UIStoryboard(name: "Calendar", bundle: nil)
        let CalendarNaviView = calendarStoryboard.instantiateInitialViewController() as! UINavigationController
        
        presentSplitView(CalendarNaviView, rightView: mainNaviView)

    }
    
    /// 削除ボタンを押した時の処理
    @IBAction func clickDeleteButton(sender: UIBarButtonItem) {
        if let deleteDate = cellData {
            // アラート通知を削除する
            for notification: UILocalNotification in UIApplication.sharedApplication().scheduledLocalNotifications! {
                if let userInfo = notification.userInfo {
                    let alertId = userInfo["alertId"] as! Int
                    if alertId == deleteDate.id {
                        UIApplication.sharedApplication().cancelLocalNotification(notification)
                    }
                }
            }
            
            // データを削除する
            let realm = db().realmMigrations()
            try! realm.write {
                realm.delete(deleteDate)
            }
            
            /// タイムスケジュール画面に戻る
            let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let mainNaviView = mainStoryboard.instantiateInitialViewController() as! UINavigationController
            let mainView = mainNaviView.visibleViewController as! ViewController
            guard let guardCurrentDate = currentDate else { return }
            mainView.currentDate = guardCurrentDate
            
            let calendarStoryboard: UIStoryboard = UIStoryboard(name: "Calendar", bundle: nil)
            let CalendarNaviView = calendarStoryboard.instantiateInitialViewController() as! UINavigationController
            
            presentSplitView(CalendarNaviView, rightView: mainNaviView)
            
        } else {
            /// 削除するデータがない時にアラートを出す
            let alert: UIAlertController = UIAlertController(title: "削除するデータがありません", message: "", preferredStyle:  UIAlertControllerStyle.Alert)
            let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler:{
                /// ボタンが押された時の処理
                (action: UIAlertAction!) -> Void in
            })
            /// アラートの追加
            alert.addAction(defaultAction)
            
            presentViewController(alert, animated: true, completion: nil)
        }
    }
}

// MARK: - UITextViewDelegate

extension EditViewController: UITextViewDelegate {
    
    /// textviewがフォーカスされたら、Labelを非表示
    func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        detailPlaceHolderLabel.hidden = true
        return true
    }
    
    /// textviewからフォーカスが外れて、TextViewが空だったらLabelを再び表示
    func textViewDidEndEditing(textView: UITextView) {
        if(detailText.text.isEmpty){
            detailPlaceHolderLabel.hidden = false
        }
    }
    
    /// UITextViewのテキストが編集するたびに呼び出される
    func textViewDidChange(textView: UITextView) {
        /// セルを更新
        editTable.beginUpdates()
        editTable.endUpdates()
    }
}

// MARK: - UIPopoverPresentationControllerDelegate

extension EditViewController: UIPopoverPresentationControllerDelegate {
    
    /// iPhoneでpopoverを表示するための設定
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.None
    }
}

// MARK: - ColorTablePopDelegate

extension EditViewController: ColorTablePopDelegate {
    
    /// 重要度のボタンの色とテキストを変更する
    func colorButtonChanged(newColor: UIColor, newText: String, newNum: Int) {
        colorSelectButton.setTitleColor(newColor, forState: . Normal)
        colorSelectButton.setTitle(newText, forState: .Normal)
        colorNum = newNum
        
        // タッチ後にモーダルを閉じる
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}

// MARK: - UIPickerViewDataSource

extension EditViewController: UIPickerViewDataSource {
    
    /// ピッカーのカラム数
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        if pickerView == alertPicker {
            // アラートピッカーのカラム数は5
            return 5
        } else {
            // その他のピッカーのカラム数は4
            return 4
        }
    }
    
    /// ピッカーの各カラムの行数
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0:
            return years.count
        case 1:
            return months.count
        case 2:
            return days.count
        case 3:
            return hours.count
        case 4:
            return mins.count
        default:
            return 0
        }
    }
}

// MARK: - UIPickerViewDelegate

extension EditViewController: UIPickerViewDelegate {
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch component {
        case 0:
            return "\(years[row])年"
        case 1:
            return "\(months[row])月"
        case 2:
            return "\(days[row])日"
        case 3:
            return "\(hours[row])時"
        case 4:
            return "\(mins[row])分"
        default:
            return nil
        }
    }
    
    /// ピッカーのカラムの幅
    func pickerView(pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        let pickerWidth = pickerView.bounds.size.width
        let widthSplit: CGFloat
        if pickerView == alertPicker {
            widthSplit = 6
        } else {
            widthSplit = 5
        }
        switch component {
        case 0:
            return 1.5 * (pickerWidth / widthSplit)
        case 1:
            return pickerWidth / widthSplit
        case 2:
            return pickerWidth / widthSplit
        case 3:
            return pickerWidth / widthSplit
        case 4:
            return pickerWidth / widthSplit
        default:
            return 0
        }
    }
    
    /// ピッカーが変更された際の処理
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch pickerView {
        case startPicker:
            setLabel(pickerView, label: startTimeLabel)
        case finishPicker:
            setLabel(pickerView, label: finishTimeLabel)
        case alertPicker:
            setLabel(pickerView, label: alertLabel)
        default:
            break
        }
    }
    
}
