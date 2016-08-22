//
//  EditViewController.swift
//  TaskManager
//
//  Created by 青木孝乃輔 on 2016/08/22.
//  Copyright © 2016年 青木孝乃輔. All rights reserved.
//

import UIKit

class EditViewController: UITableViewController {
    

    @IBOutlet var editTable: UITableView!
    @IBOutlet weak var titleBarCell: UITableViewCell!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!


    //　DatePickerの表示状態
    private var pickerShowFlag = true
    
    //　DatePicker表示時のセルの高さ
    private let pickerCellHeight: CGFloat = 210
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // tableの設定
        editTable.scrollEnabled = false
        
        // 最上部のセルの設定
        titleBarCell.selectionStyle = UITableViewCellSelectionStyle.None
        titleBarCell.backgroundColor = UIColor.grayColor()

        // タイトル入力フォームの設定
        titleTextField.layer.borderColor = UIColor.clearColor().CGColor
        
        datePickerChanged()
        
        // ピッカーを隠す
        datePicker.hidden = true
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        // セルの高さを返す
        var height: CGFloat = editTable.rowHeight
        
        if (indexPath.row == 2){
            //　DatePicker行の場合は、DatePickerの表示状態に応じて高さを返す
            // 表示の場合は、表示で指定している高さを、非表示の場合は０を返す
            height =  pickerShowFlag ? pickerCellHeight : CGFloat(0)
        }
        return height
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // セルを選択した場合に、日付入力テキストエリアがある行の場合は、DatePickerの表示切り替えを行う
        if (indexPath.row == 2) {
            dspDatePicker()
        }
    }
    
    func dspDatePicker() {
        // フラグを見て、切り替える
        if (pickerShowFlag){
            hideDatePickerCell()
        } else {
            showDatePickerCell()
        }
    }
    
    func showDatePickerCell() {
        // フラグの更新
        pickerShowFlag = true
        
        //　datePickerを表示する。
        editTable.beginUpdates()
        editTable.endUpdates()
        
        datePicker.hidden = false
        editTable.alpha = 0
        UIView.animateWithDuration(0.25, animations: { () -> Void in
            self.datePicker.alpha = 1.0
            }, completion: {(Bool) -> Void in
                
        })
    }
    
    func hideDatePickerCell() {
        // フラグの更新
        pickerShowFlag = false
        
        //　datePickerを非表示する。
        editTable.beginUpdates()
        editTable.endUpdates()
        
        UIView.animateWithDuration(0.25, animations: {() -> Void in self.datePicker.alpha = 0 },
                                   completion: {(Bool) -> Void in self.datePicker.hidden = true
        })
    }
    
    func datePickerChanged () {
        startTimeLabel.text = NSDateFormatter.localizedStringFromDate(datePicker.date, dateStyle: NSDateFormatterStyle.ShortStyle, timeStyle: NSDateFormatterStyle.ShortStyle)
    }
    


    
//    @IBAction func dateSelectPicker(sender: AnyObject) {
//        datePickerChanged()
//    }

    
//    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
//        
//        
//        return height
//    }
    
 


    



}
