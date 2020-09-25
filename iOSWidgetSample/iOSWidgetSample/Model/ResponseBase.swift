//
//  ResponseBase.swift
//  iOSWidgetSample
//
//  Created by KANG HAN on 2020/9/25.
//

import UIKit
import SwiftyJSON

class ResponseBase: NSObject {
    var errMsg: String?
    var errNo: String?
    
    init(_ jsonData: JSON)
    {
        errMsg = jsonData["msg"].stringValue
        errNo = jsonData["code"].stringValue
    }
}
