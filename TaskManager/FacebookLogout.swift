//
//  FacebookLogout.swift
//  TaskManager
//
//  Created by 青木孝乃輔 on 2016/10/13.
//  Copyright © 2016年 青木孝乃輔. All rights reserved.
//

import UIKit
import RealmSwift

class FacebookLogout {
    
    // ログイン状態だった場合、アクセストークンとログインステータスを更新してログアウト状態にする
    func facebookLogout() {
        let realm = db().realmMigrations()
        
        let tokens = realm.objects(AccessToken)
        
        for token in tokens {
            if token.access_flg == true {
                try! realm.write {
                    token.access_token = ""
                    token.access_flg = false
                }
            }
        }
    }
}
