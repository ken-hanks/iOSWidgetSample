//
//  NewsSummary.swift
//  iOSWidgetSample
//
//  Created by KANG HAN on 2020/9/25.
//

import Foundation
import SwiftUI
import SwiftyJSON

struct NewsSummary: Hashable, Identifiable {
    var id: Int = 1
    var title: String = "Test News"
    var picUrl: String = ""
    var detailUrl: String = ""
    var image: UIImage? = UIImage(named: "news_logo_placeholder")
    
    init(id: Int, title: String) {
        self.id = id
        self.title = title
        self.detailUrl = "http://www.baidu.com"
    }
    
    init(jsonData: JSON) {
        id = 1
        title = jsonData["title"].stringValue
        picUrl = jsonData["imgsrc"].stringValue
        detailUrl = jsonData["m_url"].stringValue
    }
}
