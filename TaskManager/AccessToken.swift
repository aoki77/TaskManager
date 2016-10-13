//
//  AccessTokenDb.swift
//  TaskManager
//
//  Created by 青木孝乃輔 on 2016/10/13.
//  Copyright © 2016年 青木孝乃輔. All rights reserved.
//

import RealmSwift

class AccessToken: Object {
    dynamic var id = 0
    dynamic var access_token = ""
    dynamic var access_flg = false
    
    override static func primaryKey() -> String? {
        return "id"
    }
}
