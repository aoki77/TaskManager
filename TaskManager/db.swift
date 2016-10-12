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
    
    // MARK: - 定数プロパティ
    
    /// アラート用のテキストを格納した配列
    private let alert = ["高", "中", "低"]
    
    /// ISO 8601の日付文字列をNSDateに変換するフォーマッター
    private let isoDateFormatter: NSDateFormatter = {
        let dateFormatter = NSDateFormatter()
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        return dateFormatter
    }()
    
    // MARK: - スタティック関数
    
    /// facebookと同期した際にfacebook側のデータがあるかどうかを確認
    func selectData(json: JSON) {
        
        // facebook側で削除されたデータがあった場合はアプリ側も削除
        checkDeleteDate(json)
        
        let realm = realmMigrations()
        for i in 0 ..< json["events"]["data"].count {
            
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
                if task.facebook_id == Int(json["events"]["data"][i]["id"].stringValue) {
                    
                    // 重要度をコメントで設定していた場合はその重要度に応じた数字をもらってくる
                    let importance = checkImportance(json["events"]["data"][i]["description"].stringValue)
                    
                    // アラートをコメントで設定していた場合はそのアラートの日付をもらってくる
                    let complete = checkComplete(json["events"]["data"][i]["description"].stringValue)
                    
                    try! realm.write {
                        task.title = json["events"]["data"][i]["name"].stringValue
                        task.start_time = guardStartTime
                        task.finish_time = guardEndtTime
                        task.detail = json["events"]["data"][i]["description"].stringValue
                        task.complete_flag = complete
                        if importance != 3 {
                            task.color = importance
                        }
                    }
                    updateFlg = false
                }
            }
            
            if updateFlg {
                var taskNo = 0
                
                // どのタスクの列が空いているかを確認
                if DateComparison().dateComparison(guardStartTime, finishDate: guardEndtTime, taskNum: 1) {
                    taskNo = 1
                } else if DateComparison().dateComparison(guardStartTime, finishDate: guardEndtTime, taskNum: 2) {
                    taskNo = 2
                } else if DateComparison().dateComparison(guardStartTime, finishDate: guardEndtTime, taskNum: 3) {
                    taskNo = 3
                }
                
                // 3のタスクが全て埋まっていた場合は登録しない
                if taskNo != 0 {
                    var importance = checkImportance(json["events"]["data"][i]["description"].stringValue)
                    if importance == 3 {
                        importance = 2
                    }
                    
                    // アラートが設定されているかどうかをチェックし、設定されていた場合は値ももらってくる
                    let complete = checkComplete(json["events"]["data"][i]["description"].stringValue)
                    
                    // 新規登録
                    let task = TaskDate()
                    var maxId: Int { return try! Realm().objects(TaskDate).sorted("id").last?.id ?? 0 }
                    try! realm.write {
                        task.id = maxId + 1
                        task.title = json["events"]["data"][i]["name"].stringValue
                        task.start_time = guardStartTime
                        task.finish_time = guardEndtTime
                        task.alert_time = guardStartTime
                        task.color = importance
                        task.detail = json["events"]["data"][i]["description"].stringValue
                        task.task_no = taskNo
                        task.complete_flag = complete
                        task.facebook_id = Int(json["events"]["data"][i]["id"].stringValue)!
                        task.facebook_flag = true
                        
                        realm.add(task, update: true)
                    }
                    print("登録完了 \(task)")
                }
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
    
    // MARK : - プライベート関数
    
    // アプリとfacebookのタスクを比べ、facebook側でタスクが削除されていた場合はアプリ側も削除する
    private func checkDeleteDate(json: JSON) {
        
        let realm = realmMigrations()
        let tasks = realm.objects(TaskDate).filter("facebook_flag == true")
        
        for task in tasks {
            var flg = true
            // facebook側と一致するIDがあるかどうかを確認
            for i in 0 ..< json["events"]["data"].count {
                if task.facebook_id == Int(json["events"]["data"][i]["id"].stringValue) {
                    flg = false
                    break
                }
                // 一致するIDがなければfacebook側で削除されたと判断し、アプリ側も削除
                if (i + 1) == json["events"]["data"].count && flg {
                    try! realm.write {
                        realm.delete(task)
                    }
                }
            }
        }
    }
    
    /// コメント欄に書いて有る重要度を調べて値を返す（重要度が書かれていなかった場合は「3」を返す）。
    private func checkImportance(detial: String) -> Int {
        for i in 0 ... 2 {
            if detial.containsString("#重要度:\(alert[i])") {
                return i
            }
        }
        return 3
    }
    
    /// コメント欄から達成済みかどうかを調べて値を返す
    private func checkComplete(complete: String) -> Bool {
        
        var flg = false
        
        //１行ごとに文字列を抜き出す
        complete.enumerateLines { line, stop in
            if line.containsString("#達成") || line.containsString("#完了") || line.containsString("#終了") {
                flg = true
            }
        }
        return flg
    }
}
