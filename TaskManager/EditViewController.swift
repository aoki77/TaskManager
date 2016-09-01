//
//  EditViewController.swift
//  TaskManager
//
//  Created by 青木孝乃輔 on 2016/08/22.
//  Copyright © 2016年 青木孝乃輔. All rights reserved.
//

import UIKit
import RealmSwift

class EditViewController: UITableViewController, UIPopoverPresentationControllerDelegate, UITextViewDelegate, ColorTablePopDelegate, columnPopDelegate {
    
    @IBOutlet var editTable: UITableView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var finishTimeLabel: UILabel!
    @IBOutlet weak var alertLabel: UILabel!
    @IBOutlet weak var startPicker: UIDatePicker!
    @IBOutlet weak var finishPicker: UIDatePicker!
    @IBOutlet weak var alertPicker: UIDatePicker!
    @IBOutlet weak var colorSelectButton: UIButton!
    @IBOutlet weak var detailText: UITextView!
    @IBOutlet weak var detailRow: UITableViewCell!
    @IBOutlet weak var detailPlaceHolderLabel: UILabel!
    @IBOutlet weak var alertCheckCell: UITableViewCell!
    @IBOutlet weak var alertTitleLabel: UILabel!
    
    // MARK: - 変数プロパティ
    
    ///　DatePickerの表示状態（初期状態は非表示（false））
    private var pickerShowFlag = [false, false, false]
    
    /// アラートの表示状態(初期状態は非表示（false））
    private var alertShowFlag = false
    
    /// 色と重要度を把握するための数値（初期値は2（黄色、重要度：低））
    private var colorNum = 2
    
    /// 列の番号
    private var columnNumber: Int?
    
    // MARK: - ライフサイクル関数
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /// 各ピッカーにタグを設定
        startPicker.tag = 0
        finishPicker.tag = 1
        alertPicker.tag = 2
        
        /// タイトル入力フォームの設定
        titleTextField.layer.borderColor = UIColor.clearColor().CGColor
        
        /// ピッカーの初期値をLabelに挿入
        datePickerChanged(startTimeLabel, picker: startPicker)
        datePickerChanged(finishTimeLabel, picker: finishPicker)
        datePickerChanged(alertLabel, picker: alertPicker)
        
        /// アラートを隠す
        alertTitleLabel.hidden = true
        alertLabel.hidden = true
        
        /// ピッカーを隠す
        startPicker.hidden = true
        finishPicker.hidden = true
        alertPicker.hidden = true
        
        /// ボタンの初期設定
        colorSelectButton.setTitleColor(UIColor.yellowColor(), forState: . Normal)
        colorSelectButton.setTitle("低", forState: .Normal)
        
        /// テキストビューの設定
        /// テキストビューのスクロールを禁止
        detailText.scrollEnabled = false
        /// テーブルの高さを可変にする
        editTable.estimatedRowHeight = 1000
        editTable.rowHeight = UITableViewAutomaticDimension
        
        detailPlaceHolderLabel.textColor = UIColor.lightGrayColor()
        
        detailText.delegate = self
    }
    
    // MARK: - プライベート関数
    
    private func dspDatePicker(picker: UIDatePicker) {
        /// フラグに応じてピッカーの表示、非表示の関数を呼び出す
        if pickerShowFlag[picker.tag] {
            hideDatePickerCell(picker)
        } else {
            showDatePickerCell(picker)
        }
    }
    
    private func showDatePickerCell(picker: UIDatePicker) {
        /// フラグの更新
        pickerShowFlag[picker.tag] = true
        
        /// セルのアニメーション準備
        editTable.beginUpdates()
        editTable.endUpdates()
        
        /// Pickerを表示
        picker.hidden = false
    }
    
    private func hideDatePickerCell(picker: UIDatePicker) {
        /// フラグの更新
        pickerShowFlag[picker.tag] = false
        
        /// セルのアニメーション準備
        editTable.beginUpdates()
        editTable.endUpdates()
        
        /// Pickerを非表示
        picker.hidden = true
    }
    
    private func datePickerChanged (label: UILabel, picker: UIDatePicker) {
        label.text = NSDateFormatter.localizedStringFromDate(picker.date, dateStyle: NSDateFormatterStyle.ShortStyle, timeStyle: NSDateFormatterStyle.ShortStyle)
    }
    
    private func presentPopver(viewController: UIViewController!, sourceView: UIView!) {
        viewController.modalPresentationStyle = UIModalPresentationStyle.Popover
        // popの大きさ
        viewController.preferredContentSize = CGSizeMake(UIScreen.mainScreen().bounds.width / 2, UIScreen.mainScreen().bounds.height / 5)
        
        let popoverController = viewController.popoverPresentationController
        popoverController?.delegate = self
        // 出す向き(
        popoverController?.permittedArrowDirections = UIPopoverArrowDirection.Left
        // どこから出た感じにするか
        popoverController?.sourceView = sourceView
        popoverController?.sourceRect = sourceView.bounds
        
        self.presentViewController(viewController, animated: true, completion: nil)
    }
    
    // MARK: - UITextViewDelegate
    
    /// textviewがフォーカスされたら、Labelを非表示
    func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        detailPlaceHolderLabel.hidden = true
        print("detailtest")
        return true
    }
    
    /// textviewからフォーカスが外れて、TextViewが空だったらLabelを再び表示
    func textViewDidEndEditing(textView: UITextView) {
        if(detailText.text.isEmpty){
            print("detailtest2")
            detailPlaceHolderLabel.hidden = false
        }
    }
    
    /// UITextViewのテキストが編集するたびに呼び出される
    func textViewDidChange(textView: UITextView) {
        /// セルを更新
        editTable.beginUpdates()
        editTable.endUpdates()
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        ///　DatePicker表示時のセルの高さを設定
        let pickerCellHeight: CGFloat = UIScreen.mainScreen().bounds.height / 4
        
        /// アラートのセルの高さ
        let alertCellHeight: CGFloat = UIScreen.mainScreen().bounds.height / 10
        
        // セルの高さを返す
        var height: CGFloat = editTable.rowHeight
        
        // フラグに応じて選択されたアラートの行の高さを変更
        if indexPath.row == 6 {
            if alertShowFlag {
                height = alertCellHeight
            } else {
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
            if alertCheckCell.accessoryType == UITableViewCellAccessoryType.None {
                alertCheckCell.accessoryType = UITableViewCellAccessoryType.Checkmark
                // セルのアニメーション準備
                editTable.beginUpdates()
                editTable.endUpdates()
                alertTitleLabel.hidden = false
                alertLabel.hidden = false
                alertShowFlag = false
            } else if alertCheckCell.accessoryType == UITableViewCellAccessoryType.Checkmark {
                alertCheckCell.accessoryType = UITableViewCellAccessoryType.None
                // セルのアニメーション準備
                editTable.beginUpdates()
                editTable.endUpdates()
                alertTitleLabel.hidden = true
                alertLabel.hidden = true
                alertShowFlag = true
            }
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
    
    // MARK: - UIAdaptivePresentationControllerDelegate
    
    // iPhoneでpopoverを表示するための設定
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.None
    }
    
    // MARK: - ColorTablePopDelegate
    
    // 重要度のボタンの色とテキストを変更する
    func colorButtonChanged(newColor: UIColor, newText: String, newNum: Int) {
        colorSelectButton.setTitleColor(newColor, forState: . Normal)
        colorSelectButton.setTitle(newText, forState: .Normal)
        colorNum = newNum
        
        // タッチ後にモーダルを閉じる
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - ColumnPopDelegate
    
    func cellSelectPop(columnNum: Int) {
        columnNumber = columnNum
    }
    
    // MARK: - アクション
    
    // ピッカーが押された際の処理
    @IBAction func editPicker(sender: UIDatePicker) {
        var setLabel: UILabel?
        if sender == startPicker {
            setLabel = startTimeLabel
        } else if sender == finishPicker {
            setLabel = finishTimeLabel
        } else if sender == alertPicker {
            setLabel = alertLabel
        }
        datePickerChanged(setLabel!, picker: sender)
    }
    
    // ボタンが押された際の処理
    @IBAction func clickColorSelectButton(sender: UIButton) {
        let controller = ColorTableViewController()
        presentPopver(controller, sourceView: sender)
        controller.delegate = self
    }
    
    /// 完了ボタンを押されたらその時の値を入力
    @IBAction func clickCompletButton(sender: UIButton) {
        
        /// タイトルまたは詳細が未入力の際にアラートを出す
        guard let guardTitle = titleTextField.text else { return }
        guard let guardDetail = detailText.text else { return }
        if guardTitle.characters.count == 0 || guardDetail.characters.count == 0 {
            let alert: UIAlertController = UIAlertController(title: "未入力項目があります", message: "", preferredStyle:  UIAlertControllerStyle.Alert)
            let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler:{
                /// ボタンが押された時の処理
                (action: UIAlertAction!) -> Void in
            })
            /// アラートの追加
            alert.addAction(defaultAction)
            
            presentViewController(alert, animated: true, completion: nil)
        } else {
            
            print("test入った")
            
            let realm = try! Realm()
            let task = TaskDate()
            var maxId: Int { return try! Realm().objects(TaskDate).sorted("id").last?.id ?? 0 }
            
            guard let guardColumnNumber = columnNumber else {
                print("行数来てない")
                return
            }
            try! realm.write {
                task.id = maxId + 1
                task.title = titleTextField.text!
                task.start_time = startPicker.date
                task.finish_time = finishPicker.date
                task.alert_time = alertPicker.date
                task.color = colorNum
                task.detail = detailText.text
                task.column = guardColumnNumber
                realm.add(task, update: true)
            }
            print(realm.objects(TaskDate))
            
            /// タイムスケジュール画面に戻る
            let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let next: UIViewController = storyboard.instantiateInitialViewController()! as UIViewController
            presentViewController(next, animated: true, completion: nil)
        }
    }
    
    @IBAction func returnTimeLine(sender: UIBarButtonItem) {
        /// タイムスケジュール画面に戻る
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let next: UIViewController = storyboard.instantiateInitialViewController()! as UIViewController
        presentViewController(next, animated: true, completion: nil)
    }
}
