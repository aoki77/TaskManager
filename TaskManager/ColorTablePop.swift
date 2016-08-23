//
//  ColorTablePop.swift
//  TaskManager
//
//  Created by 青木孝乃輔 on 2016/08/23.
//  Copyright © 2016年 青木孝乃輔. All rights reserved.
//

import UIKit

// デリゲートを宣言
protocol ColorTablePopDelegate: class {
    func colorButtonChanged(newColor: UIColor, newText: String)
}


class ColorTablePop: UITableViewController {
    
    var delegate: ColorTablePopDelegate! = nil
    
    // 画面全体の縦、幅
    var mainRect = UIScreen.mainScreen().bounds
    
    // 色を格納した配列
    let colors = [UIColor.redColor(), UIColor.orangeColor(), UIColor.yellowColor()]
    
    // テキストを格納した配列
    let texts = ["高", "中", "低"]
    
    override func viewDidLoad() {
        // 縦向きか横向きか判定してサイズを変更
        if mainRect.height > mainRect.width {
            self.view.layer.frame = CGRectMake(0, 0, mainRect.width / 2, mainRect.height / 5)
        } else if mainRect.width > mainRect.height {
            self.view.layer.frame = CGRectMake(0, 0, mainRect.height / 2, mainRect.width / 5)
        }
        
        // セル名の登録
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "MyCell")
        
        // セルの高さを設定
        let rect = self.tableView.bounds
        self.tableView.rowHeight = (rect.height / 3)
        
        // テーブルを固定
        self.tableView.scrollEnabled = false
        
    }
    
    // テーブルの行数を指定
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    // セルの選択時に呼び出される
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("Num: \(indexPath.row)")
        delegate?.colorButtonChanged(colors[indexPath.row], newText: texts[indexPath.row])
        print("testtesttest")
    }
    
    // セルに値を設定
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // 再利用するCellを取得する.
        let cell = tableView.dequeueReusableCellWithIdentifier("MyCell", forIndexPath: indexPath)
        return cell
    }
    
    // セルに色を設定する
    func colorForIndex(index: Int) -> UIColor {
        return colors[index]
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        // 左端までセルの線を延ばす
        if(self.tableView.respondsToSelector(Selector("setSeparatorInset:"))){
            self.tableView.separatorInset = UIEdgeInsetsZero
        }
        
        if(self.tableView.respondsToSelector(Selector("setLayoutMargins:"))){
            self.tableView.layoutMargins = UIEdgeInsetsZero
        }
        
        if(cell.respondsToSelector(Selector("setLayoutMargins:"))){
            cell.layoutMargins = UIEdgeInsetsZero
        }
        
        // 色を設定する関数の呼び出し
        cell.backgroundColor = colorForIndex(indexPath.row)
        
    }

}