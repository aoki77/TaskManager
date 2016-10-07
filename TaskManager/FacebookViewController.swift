//
//  FacebookViewController.swift
//  TaskManager
//
//  Created by 青木孝乃輔 on 2016/10/03.
//  Copyright © 2016年 青木孝乃輔. All rights reserved.
//

import UIKit
import WebKit
import Alamofire
import SwiftyJSON

final class FacebookViewController: UIViewController, UIWebViewDelegate {
    
    // MARK: - 定数プロパティ
    
    private let webView = WKWebView()
    
    private let clientId = "1179847798720467"
    
    private let redirectUri = "https://www.facebook.com/connect/login_success.html"
    
    private let clientSecret = "59af9b0fe53ecdd4799128f1dd35bd65"
    
    //MARK: - ライフサイクル関数
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupContents()
        requestWebView()
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
    
    private func requestWebView() {
        
        let url2: NSURL = NSURL(string: "https://www.facebook.com/dialog/oauth?client_id=\(clientId)&scope=user_events&redirect_uri=\(redirectUri)&scope=manage_pages,user_events")!
        
        // リクエストを作成
        let request: NSURLRequest = NSURLRequest(URL: url2)
        
        // リクエストを実行
        webView.loadRequest(request)
        
        webView.addObserver(self, forKeyPath: "loading", options: .New, context: nil)
        
    }
    
    /// プロパティ変更時
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if keyPath == "loading"{
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
                    
                    let url = "https://graph.facebook.com/me/events?access_token=\(token)&name=wawon&start_time=\(NSData())&finish_time=\(NSData())&description=kakikukeko"
                    
                    let encodedUrl = url.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!

                    Alamofire.request(.POST, encodedUrl)
                    
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
