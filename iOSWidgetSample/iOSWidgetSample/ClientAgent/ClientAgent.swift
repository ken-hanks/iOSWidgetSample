//
//  ClientAgent.swift
//  iOSWidgetSample
//
//  Created by KANG HAN on 2020/9/25.
//

import Foundation
import Alamofire
import SwiftyJSON

class ClientAgent: NSObject {
    typealias ResponseJson = (_ json: JSON) -> ()
    typealias ResponseFail = (_ failResponse: ResponseBase) -> ()
    
    //MARK: - 设置支持自签证书，信任所有服务器
    class func setAuth()
    {
        let manager = SessionManager.default
                manager.delegate.sessionDidReceiveChallenge = {
            session,challenge in
            return    (URLSession.AuthChallengeDisposition.useCredential,URLCredential(trust:challenge.protectionSpace.serverTrust!))
        }
    }
    
    //MARK: 发Post请求
    class func post(url: String,
             parameters: Dictionary<String, String>?,
                headers: Dictionary<String, String>?,
        jsonResponse: @escaping ResponseJson)
    {
        Alamofire.request(url, method: .post, parameters: parameters, encoding: URLEncoding.default, headers: headers).responseJSON { (response) in
            switch response.result {
            case .success(let json):
                jsonResponse(JSON(json))
            case .failure(let error):
                let failJson : JSON = ["code": "-1", "msg": error.localizedDescription]
                jsonResponse(failJson)
                //print("error:\(error)")
            }
        }
    }
    
    //MARK: 获取随机古诗
    class func requestPoem(success: @escaping (_ newsSummary: NewsSummary)->(), failure: @escaping ResponseFail)
    {
        ClientAgent.post(url: ApiUrl.requestPoem, parameters: nil, headers: nil, jsonResponse: { (resJson) in
            
            if resJson["code"].intValue == 200
            {
                let newsSummary = NewsSummary(jsonData: resJson["data"])
                success(newsSummary)
            }
            else
            {
                let responseBase = ResponseBase(resJson)
                failure(responseBase)
            }
        })
    }
    
    //MARK: 获取新闻列表
    class func requestNewsList(success: @escaping (_ newsList: [NewsSummary])->(), failure: @escaping ResponseFail)
    {

        ClientAgent.post(url: ApiUrl.requestNews, parameters: nil, headers: nil, jsonResponse: { (resJson) in
            
            if resJson["code"].intValue == 200
            {
                var newsList: [NewsSummary] = []
                for (_, subJSON) : (String, JSON) in resJson["data"] {
                    let newsSummary = NewsSummary(jsonData: subJSON)
                    
                    if newsSummary.detailUrl.count > 0 {
                        //只将有网页链接的新闻加入列表
                        newsList.append(newsSummary)
                    }
                }
//                let newsSummary = NewsSummary(jsonData: resJson["data"])
                success(newsList)
            }
            else
            {
                let responseBase = ResponseBase(resJson)
                failure(responseBase)
            }
        })
    }
}
