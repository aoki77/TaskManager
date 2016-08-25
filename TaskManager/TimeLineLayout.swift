//
//  TimeLineLayout.swift
//  TaskManager
//
//  Created by 青木孝乃輔 on 2016/08/15.
//  Copyright © 2016年 青木孝乃輔. All rights reserved.
//

import UIKit

final class TimeLineLayout: UICollectionViewLayout {
    // レイアウト配列
    private var layoutData = [UICollectionViewLayoutAttributes]()
    
    //スクリーンの幅、高さを取得
    private var viewSize :CGSize?
    private var cellHeight: CGFloat?
    
    // レイアウトを準備するメソッド
    override func prepareLayout() {
        
        // 画面全体の幅、高さを取得
        viewSize = UIScreen.mainScreen().bounds.size
        
        guard let guardViewSize = viewSize else { return }
        
        
        
        // 1列の高さ
        if guardViewSize.height > guardViewSize.width {
            cellHeight = guardViewSize.height / 16
        } else if guardViewSize.width > guardViewSize.height {
            cellHeight = guardViewSize.height / 10
        }
        
        guard let guardCellHeight = cellHeight else { return }
        
        // 1列の幅
        let columnWidth = guardViewSize.width / 4
        

        // コレクションの座標
        var y:CGFloat = 0
        var x:CGFloat = 0
        
        // 要素数分ループをする
        for count in 0 ..< collectionView!.numberOfItemsInSection(0) {
            let indexPath = NSIndexPath(forItem:count, inSection:0)
            
            // レイアウトの配列に位置とサイズを登録する。
            let frame = CGRect(x:x, y:y, width:columnWidth, height: guardCellHeight)
            let attributes = UICollectionViewLayoutAttributes(forCellWithIndexPath: indexPath)
            attributes.frame = frame
            layoutData.append(attributes)
            
            // y座標を更新
            y = y + guardCellHeight
            
            //24行（24時間分）作成するため、24回に一回行を切り替える
            let rowMaxCount = 24
            if (count + 1) % rowMaxCount == 0 {
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
        
        guard let guardCellHeight = cellHeight else { return CGSize(width:0, height: 0) }
        // 全体の高さ
        let allHeight = 24 * guardCellHeight
        return CGSize(width:allWidth, height:allHeight)
    }
    
}
