///
//  AppDelegate.swift
//  TaskManager
//
//  Created by 青木孝乃輔 on 2016/08/12.
//  Copyright © 2016年 青木孝乃輔. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    let initViewController: UIViewController = BaseSplitViewController()


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        // UISplitViewControllerを生成
        self.window!.rootViewController = UISplitViewController()
        let SplitViewController = self.window!.rootViewController as! UISplitViewController
        
        // 左右に配置するViewControllerを生成
        let master = ViewController()
        let detail = EditViewController()
        
        // デリゲート先を設定する
        SplitViewController.delegate = master
        
        // 入れ子にしたいViewControllerを追加
        // 最初に追加したものが左、次が右に配置される
        SplitViewController.addChildViewController(master)
        SplitViewController.addChildViewController(detail)
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

