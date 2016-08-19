//
//  TimeLineLayout.swift
//  TaskManager
//
//  Created by 青木孝乃輔 on 2016/08/15.
//  Copyright © 2016年 青木孝乃輔. All rights reserved.
//

import UIKit

class TimeLineLayout: UICollectionViewLayout {
    // 列数
    let numberColumns = 3
    // セルの高さ
    // レイアウト配列
    private var layoutData = [UICollectionViewLayoutAttributes]()
    //ステータスバーの高さ
    let statusHeight = UIApplication.sharedApplication().statusBarFrame.height
    
    //スクリーンの幅、高さを取得
    //let high = TimeLineLayout.width
    var rect :CGRect?
    var height: CGFloat?
    
    // レイアウトを準備するメソッド
    override func prepareLayout() {
        
        // 画面全体の幅、高さを取得
        rect = UIScreen.mainScreen().bounds
        
        // 1列の高さ
        if rect!.height > rect!.width {
            height = rect!.height / 16
        } else if rect!.width > rect!.height {
            height = rect!.height / 10
        }
        
        // 1列の幅
        let columnWidth = rect!.width / 4
        

        // コレクションの座標
        var y:CGFloat = 0
        var x:CGFloat = 0
        
        // 要素数分ループをする
        for count in 0 ..< collectionView!.numberOfItemsInSection(0) {
            let indexPath = NSIndexPath(forItem:count, inSection:0)
            
            // レイアウトの配列に位置とサイズを登録する。
            let frame = CGRect(x:x, y:y, width:columnWidth, height: height!)
            let attributes = UICollectionViewLayoutAttributes(forCellWithIndexPath: indexPath)
            attributes.frame = frame
            layoutData.append(attributes)
            
            // y座標を更新
            y = y + height!
            
            //24行（24時間分）作成するため、24回に一回行を切り替える
            if count == 23 || count == 47 {
                x = x + columnWidth
                y = 0
            }
        }
    }
    
    // レイアウトを返す
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return layoutData
    }
    
    // 全体サイズを返す
    override func collectionViewContentSize() -> CGSize {
        // 全体の幅
        let allWidth = CGRectGetWidth(collectionView!.bounds) - collectionView!.contentInset.left - collectionView!.contentInset.right
        
        // 全体の高さ
        let allHeight = 24 * height!
        return CGSize(width:allWidth, height:allHeight)
    }
    
}