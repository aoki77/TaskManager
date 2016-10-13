//
//  FacebookViewController.swift
//  TaskManager
//
//  Created by 青木孝乃輔 on 2016/10/03.
//  Copyright © 2016年 青木孝乃輔. All rights reserved.
//

import UIKit
import WebKit
import RealmSwift
import Alamofire
import SwiftyJSON

final class FacebookViewController: UIViewController, UIWebViewDelegate {
    
    // MARK: - 定数プロパティ
    
    private let webView = WKWebView()
    
    private let clientId = "1179847798720467"
    
    private let redirectUri = "https://www.facebook.com/connect/login_success.html"
    
    private let clientSecret = "59af9b0fe53ecdd4799128f1dd35bd65"
    
    // MARK: - ライフサイクル関数
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupContents()
        branchAccess()
    }
    
    // MARK: - プライベート関数
    
    private func setupContents() {
        
        // WebViewのサイズを設定
        webView.frame = self.view.bounds
        
        // viewのバウンドを禁止
        webView.scrollView.bounces = false
        
        // ViewにwebViewを追加
        self.view.addSubview(webView)
        
    }
    
    private func branchAccess() {
        let realm = db().realmMigrations()
        let tokens = realm.objects(AccessToken)
        var flg = true
        for token in tokens {
            if token.access_flg == true {
                setFacebookDate(token.access_token)
                flg = false
            } else {
                requestWebView()
                flg = false
            }
        }
        if flg {
            requestWebView()
        }
    }
    
    private func setFacebookDate(token: String) {
        Alamofire.request(.GET, "https://graph.facebook.com/me?fields=events&access_token=\(token)").responseJSON { str in
            
            // facebookから受け取ったデータを登録
            db().selectData(JSON(str.result.value!))
            
            // カレンダー画面を生成
            let calendarStoryboard: UIStoryboard = UIStoryboard(name: "Calendar", bundle: NSBundle.mainBundle())
            let calendarNaviView = calendarStoryboard.instantiateInitialViewController() as! UINavigationController
            self.presentViewController(calendarNaviView, animated: true, completion: nil)
        }
    }
    
    private func requestWebView() {
        let url: NSURL = NSURL(string: "https://www.facebook.com/dialog/oauth?client_id=\(clientId)&scope=user_events&redirect_uri=\(redirectUri)&scope=manage_pages,user_events")!
        
        // リクエストを作成
        let request: NSURLRequest = NSURLRequest(URL: url)
        
        // リクエストを実行
        webView.loadRequest(request)
        
        webView.addObserver(self, forKeyPath: "loading", options: .New, context: nil)
        
    }
    
    // アクセストークンをDBに登録または更新する
    private func setAccessToken(token: NSString) {
        let realm = db().realmMigrations()
        let datas = realm.objects(AccessToken)
        var tokenFlg = true
        for data in datas {
            if data.access_flg == false {
                try! realm.write {
                    data.access_flg = true
                    data.access_token = String(token)
                }
                tokenFlg = false
            }
        }
        
        if tokenFlg {
            let tokenData = AccessToken()
            var maxId: Int { return try! Realm().objects(AccessToken).sorted("id").last?.id ?? 0 }
            try! realm.write {
                tokenData.id = maxId + 1
                tokenData.access_flg = true
                tokenData.access_token = String(token)
                realm.add(tokenData,update: true)
            }
        }
        
    }
    
    /// プロパティ変更時
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if keyPath == "loading"{
            if String(webView.URL).containsString("https://www.facebook.com/connect/login_success.html") {
                if webView.loading == false {
                    let str: NSString = webView.URL!.absoluteString
                    let range = str.rangeOfString("code=").location + str.rangeOfString("code=").length
                    
                    let code = str.substringFromIndex(range)
                    let url: NSURL = NSURL(string: "https://graph.facebook.com/oauth/access_token?client_id=\(clientId)&redirect_uri=\(redirectUri)&client_secret=\(clientSecret)&code=\(code)")!
                    
                    Alamofire.request(.GET, url).responseString { string in
                        let nsString: NSString = string.description
                        let firstRange = nsString.rangeOfString("token=").location + nsString.rangeOfString("token=").length
                        var token: NSString = nsString.substringFromIndex(firstRange)
                        let lastRange = token.rangeOfString("&expires=").location
                        token = token.substringToIndex(lastRange)
                        
                        self.setAccessToken(token)
                        
                        Alamofire.request(.GET, "https://graph.facebook.com/me?fields=events&access_token=\(token)").responseJSON { str2 in
                            
                            // facebookから受け取ったデータを登録
                            db().selectData(JSON(str2.result.value!))
                            
                            // カレンダー画面を生成
                            let calendarStoryboard: UIStoryboard = UIStoryboard(name: "Calendar", bundle: NSBundle.mainBundle())
                            let calendarNaviView = calendarStoryboard.instantiateInitialViewController() as! UINavigationController
                            self.presentViewController(calendarNaviView, animated: true, completion: nil)
                        }
                    }
                }
            }
        }
    }
}
