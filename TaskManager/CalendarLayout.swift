//
//  calendarLayout.swift
//  TaskManager
//
//  Created by 青木孝乃輔 on 2016/09/26.
//  Copyright © 2016年 青木孝乃輔. All rights reserved.
//
import UIKit

class CalendarLayout: UICollectionViewLayout {
    
    // MARK: - 定数プロパティ
    
    private let columnNum = 3

    private let week = 7
    
    // MARK: - 変数プロパティ
    
    /// レイアウト配列
    private var layoutData = [UICollectionViewLayoutAttributes]()
    private var layoutData2 = [UICollectionViewLayoutAttributes]()
    
    // MARK: - ライフサイクル関数
    
    /// レイアウトを準備するメソッド
    override func prepareLayout() {
        layoutDataSetup()
        print("kita")
    }
    
    /// レイアウトを返す
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return layoutData
    }
    
    /// コレクションビューのサイズを返す
    override func collectionViewContentSize() -> CGSize {
        
        guard let guardCollectionView = collectionView else { return CGSize(width: 0, height: 0) }
        
        //
        let allWidth = UIScreen.mainScreen().bounds.size.width
        let statusBarHeight: CGFloat = UIApplication.sharedApplication().statusBarFrame.height
        //let navBarHeight = CalendarViewController.navigationController?.navigationBar.frame.size.height
        
        let navBarHeight = guardCollectionView.frame.size.height
        
        // 全体の高さ
        let allHeight = guardCollectionView.bounds.size.height
        
        return CGSize(width:allWidth, height:allHeight)
    }
    
    
    // MARK: -プライベート関数
    
    private func layoutDataSetup() {
        print("kitenai")
        guard let guardCollectionView = collectionView else { return }
        // レイアウトデータの中身を削除
        layoutData.removeAll()
        
        // 当月が何週あるかを取得
        let weekRange = NSCalendar.currentCalendar().rangeOfUnit(.WeekOfMonth, inUnit: .Month, forDate: firstDate())
        
        // 1列の幅
        let columnWidth = guardCollectionView.bounds.size.width / CGFloat(week)
        //セルの高さ
        let columnHeight = guardCollectionView.bounds.size.height / (CGFloat(weekRange.length) + 1.0)
        
        // コレクションの座標
        var point = CGPoint(x: 0,y: 0)
        
        // 曜日のセクションの座標を決定
        for count in 0 ..< guardCollectionView.numberOfItemsInSection(0) {
            let indexPath = NSIndexPath(forItem:count, inSection:0)
            
            // レイアウトの配列に位置とサイズを登録する。
            let frame = CGRect(x: point.x, y: point.y, width:columnWidth, height: columnHeight)
            let attributes = UICollectionViewLayoutAttributes(forCellWithIndexPath: indexPath)
            attributes.frame = frame
            layoutData.append(attributes)
            
            // x座標を更新
            point.x += columnWidth
        }
        
        var point2 = CGPoint(x: 0,y: columnHeight)
        // 日付のセクションの座標を決定
        for count in 0 ..< guardCollectionView.numberOfItemsInSection(1) {
            let indexPath = NSIndexPath(forItem:count, inSection:1)
            
           
            
            print(indexPath.row)
            // レイアウトの配列に位置とサイズを登録する。
            let frame = CGRect(x: point2.x, y: point2.y, width:columnWidth, height: columnHeight)
            let attributes = UICollectionViewLayoutAttributes(forCellWithIndexPath: indexPath)
            attributes.frame = frame
            layoutData.append(attributes)
            
            // x座標を更新
            point2.x += columnWidth
            
            if (count + 1) % week == 0 {
                print("kiteruyo")
                point2.x = 0
                point2.y += columnHeight
            }
        }
    }
    
    /// 月の初日を取得
    private func firstDate() -> NSDate {
        
        // 選択されている日付の月の初日を取得
        let components = NSCalendar.currentCalendar().components([.Year, .Month, .Day], fromDate: NSDate())
        components.day = 1
        
        // 取得した初日の日付をNSDateに変換
        let firstDateMonth = NSCalendar.currentCalendar().dateFromComponents(components)!
        
        return firstDateMonth
    }

}
