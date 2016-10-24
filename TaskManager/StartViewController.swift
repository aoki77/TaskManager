//
//  StartViewController.swift
//  TaskManager
//
//  Created by 青木孝乃輔 on 2016/10/14.
//  Copyright © 2016年 青木孝乃輔. All rights reserved.
//

import UIKit

class StartViewController: UIViewController {

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        loginCheck()
    }
    
    private func loginCheck() {
        let realm = db().realmMigrations()
        let tokens = realm.objects(AccessToken)
        for token in tokens {
            if token.access_flg == true {
                presentViewController(FacebookViewController(), animated: false, completion: nil)
            }
        }
        let calendarStoryboard: UIStoryboard = UIStoryboard(name: "Calendar", bundle: nil)
        let calendarNaviView = calendarStoryboard.instantiateInitialViewController() as! UINavigationController
        presentViewController(calendarNaviView, animated: false, completion: nil)
    }
    
}
