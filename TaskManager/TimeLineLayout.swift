//
//  TimeLineLayout.swift
//  TaskManager
//
//  Created by 青木孝乃輔 on 2016/08/15.
//  Copyright © 2016年 青木孝乃輔. All rights reserved.
//

import UIKit

final class TimeLineLayout: UICollectionViewLayout {
    
    // MARK: - 定数プロパティ
    
    private let rowMaxCount = 24
    
    private let columnNum = 3
    
    // MARK: - 変数プロパティ
    
    /// レイアウト配列
    private var layoutData = [UICollectionViewLayoutAttributes]()
    
    /// 1列の高さ
    private var cellHeight = { (collection: UICollectionView) -> CGFloat in
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            return collection.bounds.size.height / 16
        } else {
            return collection.bounds.size.height / 10
        }
    }
    
    // MARK: - ライフサイクル関数
    
    /// レイアウトを準備するメソッド
    override func prepareLayout() {
        layoutDataSetup()
    }
    
    /// レイアウトを返す
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return layoutData
    }
    
    /// コレクションビューのサイズを返す
    override func collectionViewContentSize() -> CGSize {
        
        guard let guardCollectionView = collectionView else { return CGSize(width: 0, height: 0) }

        // 4つあるカラムのうちコレクションビューで使用するカラムは3つ
        let allWidth = guardCollectionView.bounds.size.width

        // 全体の高さ
        let allHeight = CGFloat(rowMaxCount) * cellHeight(guardCollectionView)
        
        return CGSize(width:allWidth, height:allHeight)
    }
    
    // MARK: -プライベート関数
    
    private func layoutDataSetup() {

        guard let guardCollectionView = collectionView else { return }
        // レイアウトデータの中身を削除
        layoutData.removeAll()
        // 1列の幅
        let columnWidth = guardCollectionView.bounds.size.width  / CGFloat(columnNum)
        // コレクションの座標
        var point = CGPoint(x: 0,y: 0)
        
        // 要素数分ループをする
        for count in 0 ..< guardCollectionView.numberOfItemsInSection(0) {
            let indexPath = NSIndexPath(forItem:count, inSection:0)
            
            // レイアウトの配列に位置とサイズを登録する。
            let frame = CGRect(x: point.x, y: point.y, width:columnWidth, height: cellHeight(guardCollectionView))
            let attributes = UICollectionViewLayoutAttributes(forCellWithIndexPath: indexPath)
            attributes.frame = frame
            layoutData.append(attributes)
            
            // y座標を更新
            point.y += cellHeight(guardCollectionView)
            
            // 24行（24時間分）作成するため、24回に一回行を切り替える
            if (count + 1) % rowMaxCount == 0 {
                point.x += columnWidth
                point.y = 0
            }
        }
    }
}
