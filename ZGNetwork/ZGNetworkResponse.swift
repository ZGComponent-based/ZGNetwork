//
//  ZGNetworkResponse.swift
//
//  Created by zhaogang on 2017/3/15.
//

import UIKit

public class ZGNetworkResponse {
    public var isSuccess: Bool = false
    public var isTimeOut: Bool = false
    
    public var responseJson: Any?
    public var responseString:String?
    public var responseData:Data?
    
    public var responseHeaders: [AnyHashable : Any]?
    public var responseHttpStatus: Int = 0
    public var response: HTTPURLResponse?
    
    public var error:Error?
    
    public var errorDict:[String:Any]?
}

public class ZGNetworkDownloadResponse {
    /// The URL request sent to the server.
    public var request: URLRequest?
    
    /// The server's response to the URL request.
    public var response: HTTPURLResponse?
    
    /// The temporary destination URL of the data returned from the server.
    public var temporaryURL: URL?
    
    /// The final destination URL of the data returned from the server if it was moved.
    public var destinationURL: URL?
    
    /// The resume data generated if the request was cancelled.
    public var resumeData: Data?
    
    public var isSuccess: Bool = false
    
    public var responseData:Data?
    
    public var isTimeOut: Bool = false
    
    public var error:Error?
}
