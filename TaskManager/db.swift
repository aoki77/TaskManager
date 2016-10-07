//
//  db.swift
//  TaskManager
//
//  Created by 青木孝乃輔 on 2016/10/06.
//  Copyright © 2016年 青木孝乃輔. All rights reserved.
//

import UIKit
import RealmSwift
import Alamofire
import SwiftyJSON

class db {
    
    /// ISO 8601の日付文字列をNSDateに変換するフォーマッター
    private let isoDateFormatter: NSDateFormatter = {
        let dateFormatter = NSDateFormatter()
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        return dateFormatter
    }()
    
    /// facebookと同期した際にfacebook側のデータがあるかどうかを確認
    func selectData(json: JSON) {
        let realm = realmMigrations()
        
        for i in 0 ... json.count {
            var updateFlg = true
            
            let startTime = isoDateFormatter.dateFromString(json["events"]["data"][i]["start_time"].stringValue)
            var endTime = isoDateFormatter.dateFromString(json["events"]["data"][i]["end_time"].stringValue)
            
            // 終了時刻が設定されていない場合は開始時間を入れる
            if endTime == nil {
                endTime = startTime
            }
            
            guard let guardStartTime = startTime else { return }
            guard let guardEndtTime = endTime else { return }
            
            // 既にタスクが存在していた場合は更新する
            let tasks = realm.objects(TaskDate).filter("facebook_id == \(json["events"]["data"][i]["id"].stringValue)")
            
            // 一致するものが存在していた場合はデータを更新する
            for task in tasks {
                try! realm.write {
                    task.title = json["events"]["data"][i]["name"].stringValue
                    task.start_time = guardStartTime
                    task.finish_time = guardEndtTime
                    task.detail = json["events"]["data"][i]["description"].stringValue
                }
                updateFlg = false
            }
            
            if updateFlg {
                // 新規登録
                let task = TaskDate()
                var maxId: Int { return try! Realm().objects(TaskDate).sorted("id").last?.id ?? 0 }
                try! realm.write {
                    task.id = maxId + 1
                    task.title = json["events"]["data"][i]["name"].stringValue
                    task.start_time = guardStartTime
                    task.finish_time = guardEndtTime
                    task.alert_time = guardStartTime
                    //task.alert_time =
                    task.color = 2
                    task.detail = json["events"]["data"][i]["description"].stringValue
                    task.task_no = 1
                    //task.complete_flag = false
                    task.facebook_id = Int(json["events"]["data"][i]["id"].stringValue)!
                    task.facebook_flag = true
                    realm.add(task, update: true)
                }
                print("登録完了 \(task)")
            }
        }
    }
    
    /// マイグレーション
    func realmMigrations() -> Realm {
        // Realmのインスタンスを取得
        let config = Realm.Configuration(
            schemaVersion: 7,
            migrationBlock: { migration, oldSchemaVersion in
                if (oldSchemaVersion < 1) {}
        })
        Realm.Configuration.defaultConfiguration = config
        let realm = try! Realm()
        return realm
    }
}
