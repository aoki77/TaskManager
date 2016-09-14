//
//  ColorTablePop.swift
//  TaskManager
//
//  Created by 青木孝乃輔 on 2016/08/23.
//  Copyright © 2016年 青木孝乃輔. All rights reserved.
//

import UIKit

// デリゲートを宣言
protocol ColorTablePopDelegate {
    func colorButtonChanged(newColor: UIColor, newText: String, newNum: Int)
}

final class ColorTableViewController: UITableViewController {
    
    var delegate: ColorTablePopDelegate?
    
    /// 色を格納した配列
    private let colors:[UIColor] = [.redColor(), .orangeColor(), .yellowColor()]
    
    /// テキストを格納した配列
    private let texts = ["高", "中", "低"]
    
    /// カラム数
    private let columnNum = 3
    
    // MARK: - ライフサイクル関数
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupContents()
    }
    
    // MARK: - プライベート関数
    
    private func setupContents() {
        // 縦向きか横向きか判定してサイズを変更
        switch UIApplication.sharedApplication().statusBarOrientation {
        case .Portrait, .PortraitUpsideDown, .Unknown:
            tableView.bounds.size = CGSize(width: UIScreen.mainScreen().bounds.width / 2,
                                                height: UIScreen.mainScreen().bounds.height / 5)
        case .LandscapeLeft, .LandscapeRight:
            tableView.bounds.size = CGSize(width: UIScreen.mainScreen().bounds.width / 5,
                                                height: UIScreen.mainScreen().bounds.height / 2)
        }
        
        // セルの高さを設定
        let rect = self.tableView.bounds
        tableView.rowHeight = (rect.height / CGFloat(columnNum))
        
        // セル名の登録
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "MyCell")
        
        // テーブルを固定
        tableView.scrollEnabled = false
    }
    
    // MARK: - UITableViewDetaSource
    
    /// テーブルの行数を指定
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return columnNum
    }
    
    /// セルに値を設定
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // 再利用するCellを取得する.
        let cell = tableView.dequeueReusableCellWithIdentifier("MyCell", forIndexPath: indexPath)
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    /// セルの選択時に呼び出される
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("Num: \(indexPath.row)")
        delegate?.colorButtonChanged(colors[indexPath.row], newText: texts[indexPath.row], newNum: indexPath.row)
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        // 左端までセルの線を延ばす
        self.tableView.layoutMargins = UIEdgeInsetsZero

        // 色を設定する関数の呼び出し
        cell.backgroundColor = colors[indexPath.row]
    }
}
