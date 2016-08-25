//
//  TimeLineLayout.swift
//  TaskManager
//
//  Created by 青木孝乃輔 on 2016/08/15.
//  Copyright © 2016年 青木孝乃輔. All rights reserved.
//

import UIKit

internal final class TimeLineLayout: UICollectionViewLayout {
    
    // MARK: - プロパティ
    
    /// カラム数
    private var columnCount: Int = 0
    
    /// 行数
    private var rowCount: Int = 0
    
    /// 表示行数
    private var visibleRowCount: Int = 0
    
    /// レイアウト配列
    private var layoutList: [UICollectionViewLayoutAttributes] = [UICollectionViewLayoutAttributes]()
    
    // MARK: - ライフサイクル関数
    
    // レイアウトを準備するメソッド
    override func prepareLayout() {
        super.prepareLayout()
        
        guard let collectionView = collectionView else {
            return
        }
        
        layoutList.removeAll()
        
        let cellSize: CGSize = CGSize(width: collectionView.bounds.width / CGFloat(columnCount),
                                      height: collectionView.bounds.height / CGFloat(visibleRowCount))
        
        // コレクションの座標
        var cellPoint: CGPoint = CGPoint.zero
        
        // 要素数分ループをする
        for sectionIndex in 0..<collectionView.numberOfSections() {
            for itemIndex in 0..<collectionView.numberOfItemsInSection(sectionIndex) {
                let indexPath: NSIndexPath = NSIndexPath(forItem: itemIndex, inSection: sectionIndex)
                let attributes = UICollectionViewLayoutAttributes(forCellWithIndexPath: indexPath)
                
                // レイアウトの配列に位置とサイズを登録する。
                let frame = CGRect(x:cellPoint.x,
                                   y:cellPoint.y,
                                   width:cellSize.width,
                                   height: cellSize.height)
                attributes.frame = frame
                layoutList.append(attributes)
                
                // 24行（24時間分）作成するため、24回に一回行を切り替える
                if (itemIndex + 1) % rowCount == 0 {
                    cellPoint = CGPoint(x: cellPoint.x + cellSize.width,
                                        y: 0.0)
                } else {
                    // y座標を更新
                    cellPoint.y = frame.maxY
                }
            }
        }
    }
    
    // レイアウトを返す
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return layoutList
    }
    
    // コンテンツのサイズを返す
    override func collectionViewContentSize() -> CGSize {
        guard let layoutAttribute = layoutList.last else {
            return CGSize.zero
        }
        
        return CGSize(width: layoutAttribute.frame.maxX,
                      height: layoutAttribute.frame.maxY)
    }
    
    // MARK: - パブリック関数
    
    func updateCount(taskCount: Int, timeCount: Int, visibleTimeCount: Int) {
        columnCount = taskCount
        rowCount = timeCount
        visibleRowCount = visibleTimeCount
        
        invalidateLayout()
    }
}
