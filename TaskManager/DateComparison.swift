//
//  DateComparison.swift
//  TaskManager
//
//  Created by 青木孝乃輔 on 2016/10/07.
//  Copyright © 2016年 青木孝乃輔. All rights reserved.
//

import UIKit

class DateComparison {
    
    /// 年月日時のフォーマッター
    private let dateFormatter: NSDateFormatter = {
        let dateFormatter = NSDateFormatter()
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US")
        dateFormatter.dateFormat = "yyyy/MM/dd HH"
        return dateFormatter
    }()
    
    /// 登録しようとした時間に既にタスクが入っているかどうかを確認し、既にタスクが存在していた場合はfalseを返す
    func dateComparison(startDate: NSDate, finishDate: NSDate, taskNum: Int) -> Bool {
        
        let realm = db().realmMigrations()
        
        let tasks = realm.objects(TaskDate).filter("task_no == \(taskNum)")
        
        for task in tasks {
            // タスクが既に存在しているかどうかを判定
            // 指定しようとしているタスクの時間の間に既に他のタスクの開始時間がある場合
            if dateFormatter.stringFromDate(startDate).compare(dateFormatter.stringFromDate(task.start_time)) == NSComparisonResult.OrderedAscending &&
                dateFormatter.stringFromDate(finishDate).compare(dateFormatter.stringFromDate(task.start_time)) == NSComparisonResult.OrderedDescending {
                return false
            // 指定しようとしているタスクの時間の間に既に他のタスクの終了時間がある場合
            } else if dateFormatter.stringFromDate(startDate).compare(dateFormatter.stringFromDate(task.finish_time)) == NSComparisonResult.OrderedDescending &&
                dateFormatter.stringFromDate(finishDate).compare(dateFormatter.stringFromDate(task.finish_time)) == NSComparisonResult.OrderedAscending {
                return false
            // 既に存在しているタスクの時間の間に開始時間を設定しようとしている場合
            } else if dateFormatter.stringFromDate(task.start_time).compare(dateFormatter.stringFromDate(startDate)) == NSComparisonResult.OrderedAscending &&
                dateFormatter.stringFromDate(task.finish_time).compare(dateFormatter.stringFromDate(startDate)) == NSComparisonResult.OrderedDescending {
                return false
            // 既に存在しているタスクの時間の間に終了時間を設定しようとしている場合
            } else if dateFormatter.stringFromDate(task.start_time).compare(dateFormatter.stringFromDate(finishDate)) == NSComparisonResult.OrderedAscending &&
                dateFormatter.stringFromDate(task.finish_time).compare(dateFormatter.stringFromDate(finishDate)) == NSComparisonResult.OrderedDescending {
                return false
            // 開始時間が被った場合
            } else if dateFormatter.stringFromDate(startDate).compare(dateFormatter.stringFromDate(task.start_time)) == NSComparisonResult.OrderedSame {
                return false
            // 設定しようとしている開始時間と他タスクの終了時間が被った場合
            } else if dateFormatter.stringFromDate(finishDate).compare(dateFormatter.stringFromDate(task.start_time)) == NSComparisonResult.OrderedSame {
                return false
            // 設定しようとしている終了時間と他タスクの開始時間が被った場合
            } else if dateFormatter.stringFromDate(startDate).compare(dateFormatter.stringFromDate(task.finish_time)) == NSComparisonResult.OrderedSame {
                return false
            // 終了時間が被った場合
            } else if dateFormatter.stringFromDate(finishDate).compare(dateFormatter.stringFromDate(task.finish_time)) == NSComparisonResult.OrderedSame {
                return false
            }
        }
        return true
    }
}
