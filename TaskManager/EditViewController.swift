//
//  EditViewController.swift
//  TaskManager
//
//  Created by 青木孝乃輔 on 2016/08/22.
//  Copyright © 2016年 青木孝乃輔. All rights reserved.
//

import UIKit

class EditViewController: UITableViewController, UIPopoverPresentationControllerDelegate, ColorTablePopDelegate {
    
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
    

    //　DatePickerの表示状態（初期状態は非表示（false））
    private var pickerShowFlag = [false, false, false]
    
    // 画面全体の高さ、幅
    let rect = UIScreen.mainScreen().bounds
    
    // Picker表示時のセルの高さ
    var pickerCellHeight: CGFloat?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 各ピッカーにタグを設定
        startPicker.tag = 0
        finishPicker.tag = 1
        alertPicker.tag = 2
        
        //　DatePicker表示時のセルの高さを設定
        pickerCellHeight = rect.height / 4

        // タイトル入力フォームの設定
        titleTextField.layer.borderColor = UIColor.clearColor().CGColor
        
        // ピッカーの初期値をLabelに挿入
        datePickerChanged(startTimeLabel, picker: startPicker)
        datePickerChanged(finishTimeLabel, picker: finishPicker)
        datePickerChanged(alertLabel, picker: alertPicker)
        
        // ピッカーを隠す
        startPicker.hidden = true
        finishPicker.hidden = true
        alertPicker.hidden = true
        
        // テキストビューの設定
        detailText.scrollEnabled = false
        editTable.rowHeight = UITableViewAutomaticDimension
        
        
    }
    
    func textViewDidChange(textView: UITextView) {
        editTable.beginUpdates()
        editTable.endUpdates()
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        // セルの高さを返す
        var height: CGFloat = editTable.rowHeight
        
        if indexPath.row == 2 {
            // フラグに応じて選択されたピッカーの行の高さを変更
            if pickerShowFlag[0] {
                height = pickerCellHeight!
            } else {
                height = CGFloat(0)
            }
        } else if indexPath.row == 4 {
            if pickerShowFlag[1] {
                height = pickerCellHeight!
            } else {
                height = CGFloat(0)
            }
        } else if indexPath.row == 6 {
            if pickerShowFlag[2] {
                height = pickerCellHeight!
            } else {
                height = CGFloat(0)
            }
        }
        return height
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // 日付の行が選択された際にピッカーの表示切り替えの関数を呼び出す
        if indexPath.row == 1 {
            dspDatePicker(startPicker)
        } else if indexPath.row == 3 {
            dspDatePicker(finishPicker)
        } else if indexPath.row == 5 {
            dspDatePicker(alertPicker)
        }
    }
    
    func dspDatePicker(picker: UIDatePicker) {
        // フラグに応じてピッカーの表示、非表示の関数を呼び出す
        if pickerShowFlag[picker.tag] {
            hideDatePickerCell(picker)
        } else {
            showDatePickerCell(picker)
        }
    }
    
    func showDatePickerCell(picker: UIDatePicker) {
        // フラグの更新
        pickerShowFlag[picker.tag] = true
        
        // セルのアニメーション準備
        editTable.beginUpdates()
        editTable.endUpdates()
        
        // Pickerを表示
        picker.hidden = false
    }
    
    func hideDatePickerCell(picker: UIDatePicker) {
        // フラグの更新
        pickerShowFlag[picker.tag] = false
        
        // セルのアニメーション準備
        editTable.beginUpdates()
        editTable.endUpdates()
        
        // Pickerを非表示
        picker.hidden = true
    }
    
    func datePickerChanged (label: UILabel, picker: UIDatePicker) {
        label.text = NSDateFormatter.localizedStringFromDate(picker.date, dateStyle: NSDateFormatterStyle.ShortStyle, timeStyle: NSDateFormatterStyle.ShortStyle)
    }
    
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
        let controller = ColorTablePop()
        self.presentPopver(controller, sourceView: sender)
    }
    
    //
    func presentPopver(viewController: UIViewController!, sourceView: UIView!) {
        viewController.modalPresentationStyle = UIModalPresentationStyle.Popover
        // popの大きさ
        viewController.preferredContentSize = CGSizeMake(rect.width / 2, rect.height / 5)
        
        let popoverController = viewController.popoverPresentationController
        popoverController?.delegate = self
        // 出す向き(
        popoverController?.permittedArrowDirections = UIPopoverArrowDirection.Left
        // どこから出た感じにするか
        popoverController?.sourceView = sourceView
        popoverController?.sourceRect = sourceView.bounds
        
        self.presentViewController(viewController, animated: true, completion: nil)
    }
    
    // iPhoneでpopoverを表示するための設定
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.None
    }
    
    // 重要度のボタンの色とテキストを変更する
    func colorButtonChanged(newColor: UIColor, newText: String) {
        print("delegate")
        colorSelectButton.backgroundColor = newColor
        colorSelectButton.setTitle(newText, forState: .Normal)
    }
}