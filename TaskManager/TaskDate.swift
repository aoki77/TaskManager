//
//  TaskDate.swift
//  TaskManager
//
//  Created by 青木孝乃輔 on 2016/08/24.
//  Copyright © 2016年 青木孝乃輔. All rights reserved.
//

import RealmSwift

class TaskDate: Object {
    dynamic var id = 0
    dynamic var title = ""
    dynamic var start_time = NSDate()
    dynamic var finish_time = NSDate()
    dynamic var alert_time = NSDate()
    dynamic var color = 0
    dynamic var detail = ""
    dynamic var task_no = 0
    dynamic var complete_flag = false
    dynamic var facebook_id = 0
    dynamic var facebook_flag = false

    override static func primaryKey() -> String? {
        return "id"
    }
}
