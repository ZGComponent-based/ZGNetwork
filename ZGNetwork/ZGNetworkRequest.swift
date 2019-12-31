//
//  ZGNetworkRequest.swift
//
//  Created by zhaogang on 2017/3/15.
//

import UIKit
import Alamofire

public final class ZGNetworkRequest {
    
    fileprivate let dataRequest:DataRequest
    
    init(_ dataRequest:DataRequest) {
        self.dataRequest = dataRequest
    }
    
    public func request() -> URLRequest? {
        return dataRequest.request
    }
    
    public func cancel() {
        self.dataRequest.cancel()
    }
    
    @discardableResult
    public func responseJSON(
        queue: DispatchQueue? = nil,
        options: JSONSerialization.ReadingOptions = .allowFragments,
        completionHandler: @escaping (ZGNetworkResponse) -> Void)
        -> Self
    {
        
        dataRequest.response(queue: queue, responseSerializer:  DataRequest.jsonResponseSerializer(options: options)) { (resp) in
            let tbbzResponse : ZGNetworkResponse = ZGNetworkResponse()
            tbbzResponse.isSuccess = resp.result.isSuccess
            tbbzResponse.responseJson = resp.result.value
            tbbzResponse.responseHeaders = resp.response?.allHeaderFields
            tbbzResponse.response = resp.response
            tbbzResponse.responseHttpStatus = resp.response?.statusCode ?? 0
            if !resp.result.isSuccess {
                if let data = resp.data {
                    if let jsonArr = try? JSONSerialization.jsonObject(with: data, options: []) as? [String:Any] {
                        tbbzResponse.errorDict = jsonArr 
                    }
                }
            }

            tbbzResponse.error = resp.result.error
            completionHandler(tbbzResponse)
        }
        
        return self;
    }
    
    @discardableResult
    public func responseString(
        queue: DispatchQueue? = nil,
        completionHandler: @escaping (ZGNetworkResponse) -> Void)
        -> Self
    {
        dataRequest.responseString(queue: queue, encoding: .utf8) { (resp) in
            let tbbzResponse : ZGNetworkResponse = ZGNetworkResponse()
            tbbzResponse.isSuccess = resp.result.isSuccess
            tbbzResponse.response = resp.response
            tbbzResponse.responseString = resp.result.value
            tbbzResponse.responseHeaders = resp.response?.allHeaderFields
            tbbzResponse.responseHttpStatus = resp.response?.statusCode ?? 0
            tbbzResponse.error = resp.result.error
            completionHandler(tbbzResponse)
        }
        

        return self;
    }
    
    @discardableResult
    public func responseData(
        queue: DispatchQueue? = nil,
        completionHandler: @escaping (ZGNetworkResponse) -> Void)
        -> Self
    {
        dataRequest.responseData(queue: queue) { (resp) in
            let tbbzResponse : ZGNetworkResponse = ZGNetworkResponse()
            tbbzResponse.isSuccess = resp.result.isSuccess
            tbbzResponse.responseData = resp.result.value
            tbbzResponse.response = resp.response
            tbbzResponse.responseHeaders = resp.response?.allHeaderFields
            tbbzResponse.responseHttpStatus = resp.response?.statusCode ?? 0
            tbbzResponse.error = resp.result.error
            completionHandler(tbbzResponse)
        }
        
        return self;
    }
    
}


public class ZGNetworkDownloadRequest {
    public typealias ProgressHandler = (Progress) -> Void
    
    fileprivate let dataRequest:DownloadRequest
    
    init(_ dataRequest:DownloadRequest) {
        self.dataRequest = dataRequest
    }
    
    public func request() -> URLRequest? {
        return dataRequest.request
    }
    
    /// The resume data of the underlying download task if available after a failure.
    public func resumeData() -> Data? { return dataRequest.resumeData }
    
    /// The progress of downloading the response data from the server for the request.
    public func progress() -> Progress { return dataRequest.progress }
    
    // MARK: State
    
    /// Cancels the request.
    public func cancel() {
        dataRequest.cancel()
    } 
    
    // MARK: Progress
    
    /// Sets a closure to be called periodically during the lifecycle of the `Request` as data is read from the server.
    ///
    /// - parameter queue:   The dispatch queue to execute the closure on.
    /// - parameter closure: The code to be executed periodically as data is read from the server.
    ///
    /// - returns: The request.
    @discardableResult
    open func downloadProgress(queue: DispatchQueue = DispatchQueue.main, closure: @escaping ProgressHandler) -> Self {
        dataRequest.downloadProgress(queue: queue) { (progress) in
            closure(progress)
        }
        return self
    }
    
    @discardableResult
    public func responseData(
        queue: DispatchQueue? = nil,
        completionHandler: @escaping (ZGNetworkDownloadResponse) -> Void)
        -> Self
    {
        dataRequest.responseData(queue: queue) { (resp) in
            let tbbzResponse : ZGNetworkDownloadResponse = ZGNetworkDownloadResponse()
            tbbzResponse.isSuccess = resp.result.isSuccess
            tbbzResponse.request = resp.request
            tbbzResponse.response = resp.response
            tbbzResponse.temporaryURL = resp.temporaryURL
            tbbzResponse.destinationURL = resp.destinationURL
            tbbzResponse.resumeData = resp.resumeData
            tbbzResponse.error = resp.result.error
            completionHandler(tbbzResponse)
        }
        
        return self;
    }
}

public class ZGNetworkUploadRequest {
    public typealias ProgressHandler = (Progress) -> Void
    
    fileprivate let dataRequest:UploadRequest
    
    init(_ dataRequest:UploadRequest) {
        self.dataRequest = dataRequest
    }
    
    public func request() -> URLRequest? {
        return dataRequest.request
    }
    
    /// The progress of downloading the response data from the server for the request.
    public func uploadProgress() -> Progress { return dataRequest.uploadProgress }
    
    // MARK: State
    
    /// Cancels the request.
    public func cancel() {
        dataRequest.cancel()
    }
    
    // MARK: Upload Progress
    
    /// Sets a closure to be called periodically during the lifecycle of the `UploadRequest` as data is sent to
    /// the server.
    ///
    /// After the data is sent to the server, the `progress(queue:closure:)` APIs can be used to monitor the progress
    /// of data being read from the server.
    ///
    /// - parameter queue:   The dispatch queue to execute the closure on.
    /// - parameter closure: The code to be executed periodically as data is sent to the server.
    ///
    /// - returns: The request.
    @discardableResult
    public func uploadProgress(queue: DispatchQueue = DispatchQueue.main, closure: @escaping ProgressHandler) -> Self {
        dataRequest.uploadProgress { (progress) in
            closure(progress)
        } 
        return self
    }
    
    @discardableResult
    public func downloadProgress(queue: DispatchQueue = DispatchQueue.main, closure: @escaping ProgressHandler) -> Self {
        dataRequest.downloadProgress { (progress) in
            closure(progress)
        }
        return self
    }
    
    @discardableResult
    public func response(
        queue: DispatchQueue? = nil,
        completionHandler: @escaping (ZGNetworkResponse) -> Void)
        -> Self
    {
        dataRequest.response(queue: queue) { (resp) in
            let tbbzResponse : ZGNetworkResponse = ZGNetworkResponse()
            tbbzResponse.response = resp.response
            tbbzResponse.responseHeaders = resp.response?.allHeaderFields
            tbbzResponse.responseHttpStatus = resp.response?.statusCode ?? 0
            tbbzResponse.error = resp.error
            completionHandler(tbbzResponse)
        }
        
        return self;
    }
    
    
    @discardableResult
    public func responseJSON(
        queue: DispatchQueue? = nil,
        options: JSONSerialization.ReadingOptions = .allowFragments,
        completionHandler: @escaping (ZGNetworkResponse) -> Void)
        -> Self
    {
        
        dataRequest.response(queue: queue, responseSerializer:  DataRequest.jsonResponseSerializer(options: options)) { (resp) in
            let tbbzResponse : ZGNetworkResponse = ZGNetworkResponse()
            tbbzResponse.isSuccess = resp.result.isSuccess
            tbbzResponse.responseJson = resp.result.value
            tbbzResponse.response = resp.response
            tbbzResponse.responseHeaders = resp.response?.allHeaderFields
            tbbzResponse.responseHttpStatus = resp.response?.statusCode ?? 0
            tbbzResponse.error = resp.result.error
            completionHandler(tbbzResponse)
        }
        
        return self;
    }
}
