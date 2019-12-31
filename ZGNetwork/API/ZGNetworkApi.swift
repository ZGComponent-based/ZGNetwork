//
//  ZGNetworkApi.swift
//
//  Created by zhaogang on 2017/3/15.
//

import UIKit

open class ZGNetworkApiVo : NSObject {
    //解析vo的原始json字典，统计用
    public var voDict:[String:Any]?
}

open class ZGNetworkApi: NSObject {
    public typealias CompletionHandler = (ZGNetworkResponse) -> Void
    public typealias FailureHandler = (ZGNetworkError) -> Void
    
    open var dataRequest:ZGNetworkRequest?
    
    open func cancelRequest() {
        self.dataRequest?.cancel()
    }
    
    open func requestString(
        _ url: URLConvertible,
        tag:Int = 0,
        method: HTTPMethod = .get,
        parameters: [String: Any]? = nil,
        headers: [String: String]? = nil,
        completionHandler: @escaping CompletionHandler,
        failureHandler: @escaping FailureHandler)
        -> Void {
        
        let netRequest:ZGNetworkRequest? = ZGNetwork.request(url, method: method, parameters: parameters, headers: headers)
        self.dataRequest = netRequest
        netRequest?.responseString { [weak self] (resp) in
            if resp.isSuccess {
                completionHandler(resp)
            } else {
                let netError:ZGNetworkError = ZGNetworkError()
                netError.response = resp
                netError.tag = tag
                failureHandler(netError)
            }
            
            self?.dataRequest = nil
        }
        
    }
    
    open func errorMessage(forHttpStatus statusCode:Int) -> String? {
        var errorMessage:String? = nil
        
        if statusCode < 1 {
            errorMessage = "网络不稳定，请稍后再试(\(statusCode))"
        } else if statusCode >= 500 {
            errorMessage = "系统繁忙，请稍后再试(\(statusCode))"
        } else if statusCode == 404 {
            errorMessage = "访问的接口不存在(\(statusCode))"
        } else if statusCode == 401 {
            errorMessage = "请重新登录(\(statusCode))"
        } else if statusCode == 410 {
            errorMessage = "该功能已下线，请升级最新版本"
        } else {
            errorMessage = "系统繁忙，请稍后再试(\(statusCode))"
        }
        
        return errorMessage
    }
    
    open func postJSON(
        _ url: URLConvertible,
        tag:Int = 0,
        method: HTTPMethod = .get,
        parameters: [String: Any]? = nil,
        headers: [String: String]? = nil,
        completionHandler: @escaping CompletionHandler,
        failureHandler: @escaping FailureHandler)
        -> Void {
        let netRequest:ZGNetworkRequest? = ZGNetwork.postJson(url, parameters: parameters, headers: headers)
        self.dataRequest = netRequest
        
        netRequest?.responseJSON { [weak self] (resp) in
            if resp.isSuccess {
                completionHandler(resp)
            } else {
                let netError:ZGNetworkError = ZGNetworkError()
                netError.response = resp
                netError.tag = tag
                if let errorDict = resp.errorDict as? [String:Any] {
                    netError.errorMessage = errorDict["message"] as? String
                } else {
                    if let status = resp.response?.statusCode {
                        netError.errorMessage = self?.errorMessage(forHttpStatus: status)
                    }
                }
                failureHandler(netError)
            }
            
            self?.dataRequest = nil
        }
        
    }
   
    /// 子类必须调用该方法发送请求
    open func request(
        _ url: URLConvertible,
        tag:Int = 0,
        method: HTTPMethod = .get,
        parameters: [String: Any]? = nil,
        headers: [String: String]? = nil,
        completionHandler: @escaping CompletionHandler,
        failureHandler: @escaping FailureHandler)
        -> Void {
        
        let netRequest:ZGNetworkRequest? = ZGNetwork.request(url, method: method, parameters: parameters, headers: headers)
        self.dataRequest = netRequest
        netRequest?.responseJSON { [weak self] (resp) in
            if resp.isSuccess {
                completionHandler(resp)
            } else {
                let netError:ZGNetworkError = ZGNetworkError()
                netError.response = resp
                netError.tag = tag
                if let errorDict = resp.errorDict as? [String:Any] {
                    netError.errorMessage = errorDict["message"] as? String
                } else {
                    if let status = resp.response?.statusCode {
                        netError.errorMessage = self?.errorMessage(forHttpStatus: status)
                    }
                }
                
                failureHandler(netError)
            }
            
            self?.dataRequest = nil
        }

    }
}
