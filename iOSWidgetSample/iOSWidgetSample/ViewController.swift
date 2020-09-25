//
//  ViewController.swift
//  iOSWidgetSample
//
//  Created by KANG HAN on 2020/9/25.
//

import UIKit
import WebKit

class ViewController: UIViewController {

    @IBOutlet weak var webView: WKWebView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //注册消息处理
        NotificationCenter.default.addObserver(self, selector: #selector(loadNews), name: NSNotification.Name(rawValue: "loadNews"), object: nil)
    }

    //Widget消息处理，打开被点击新闻的详情页
    @objc func loadNews(noti: Notification)
    {
        if let userInfo = noti.userInfo {
            let url : URL = userInfo["url"] as! URL
            webView.load(URLRequest(url: url))
        }
        

    }
}

