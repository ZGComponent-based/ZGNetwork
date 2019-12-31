//
//  ZGNetwork.swift
//
//  Created by zhaogang on 2017/3/15.
//

import UIKit
import Alamofire
import ZGCore

public enum HTTPMethod: String {
    case options = "OPTIONS"
    case get     = "GET"
    case head    = "HEAD"
    case post    = "POST"
    case put     = "PUT"
    case patch   = "PATCH"
    case delete  = "DELETE"
    case trace   = "TRACE"
    case connect = "CONNECT"
}

func alamofireMethod(_ method:HTTPMethod) -> Alamofire.HTTPMethod {
    var retMethod:Alamofire.HTTPMethod
    
    switch method {
    case .get:
        retMethod = Alamofire.HTTPMethod.get
    case .post:
        retMethod = Alamofire.HTTPMethod.post
    case .put:
        retMethod = Alamofire.HTTPMethod.put
    case .delete:
        retMethod = Alamofire.HTTPMethod.delete
    default:
        retMethod = Alamofire.HTTPMethod.get
    }
    
    return retMethod
}

public protocol URLConvertible {
    func asURL() -> URL?
}

extension String: URLConvertible {
    public func asURL() -> URL? {
        var urlString = self
        
        if self.hasPrefix("//") {
            //后续通过开关
            urlString = "http:"+self
        }
        return URL.init(string: urlString)
    }
}

extension URL: URLConvertible {
    public func asURL() -> URL? { return self }
}

public struct ZGNetwork {
    static let sessionManager: SessionManager = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.httpAdditionalHeaders = SessionManager.defaultHTTPHeaders
        
        return SessionManager(configuration: configuration)
    }()
    
    @discardableResult
    static func alamofireRequest(
        _ url: URLConvertible,
        method: HTTPMethod = .get,
        parameters: [String: Any]? = nil,
        encoding: ParameterEncoding = URLEncoding.default,
        headers: HTTPHeaders? = nil)
        -> DataRequest?
    {
        guard let reqUrl = url.asURL() else {
            return nil
        }
        let aMethod:Alamofire.HTTPMethod = alamofireMethod(method)
         return ZGNetwork.sessionManager.request(
            reqUrl,
            method: aMethod,
            parameters: parameters,
            encoding: encoding,
            headers: headers
        )
    }
    
    // MARK: - Data Request
    
    /// Creates a `DataRequest` using the default `SessionManager` to retrieve the contents of the specified `url`,
    /// `method`, `parameters`, `encoding` and `headers`.
    ///
    /// - parameter url:        The URL.
    /// - parameter method:     The HTTP method. `.get` by default.
    /// - parameter parameters: The parameters. `nil` by default.
    /// - parameter headers:    The HTTP headers. `nil` by default.
    ///
    /// - returns: The created `DataRequest`.
    @discardableResult
    public static func request(
        _ url: URLConvertible,
        method: HTTPMethod = .get,
        parameters: [String: Any]? = nil,
        headers: [String: String]? = nil)
        -> ZGNetworkRequest?
    {
        if let dataRequest = ZGNetwork.alamofireRequest(url,
                                                        method: method,
                                                        parameters: parameters,
                                                        headers: headers)?.validate() {
            return ZGNetworkRequest(dataRequest)
        } else {
            return nil
        }
    }
    
    @discardableResult
    public static func postJson(
        _ url: URLConvertible,
        parameters: [String: Any]? = nil,
        headers: [String: String]? = nil) -> ZGNetworkRequest? {
        if let dataRequest = ZGNetwork.alamofireRequest(url,
                                                        method: .post,
                                                        parameters: parameters,
                                                        encoding: JSONEncoding.default,
                                                        headers: headers)?.validate() {
            return ZGNetworkRequest(dataRequest)
        } else {
            return nil
        }
    }
    
    @discardableResult
    public static func download(
        _ url: URLConvertible,
        method: HTTPMethod = .get,
        parameters: [String: Any]? = nil,
        headers: [String: String]? = nil,
        to destination: URL? = nil)
        -> ZGNetworkDownloadRequest?
    {
        guard let reqUrl = url.asURL() else {
            return nil
        }
        var destination2:DownloadRequest.DownloadFileDestination? = nil
        if let url1 = destination {
            destination2 = { _, _ in (url1, [.createIntermediateDirectories]) }
        }
        
        let aMethod:Alamofire.HTTPMethod = alamofireMethod(method)
        let dataRequest = Alamofire.download(reqUrl,
                                             method: aMethod,
                                             parameters: parameters,
                                             encoding: URLEncoding.default,
                                             headers: headers,
                                             to: destination2).validate()
        
        
        return ZGNetworkDownloadRequest(dataRequest)
    }
    
    @discardableResult
    public static func upload(
        _ data: Data,
        method: HTTPMethod = .post,
        parameters: [String: Any]? = nil,
        headers: [String: String]? = nil,
        to destination: URLConvertible)
        -> ZGNetworkUploadRequest
    {
        let reqUrl = destination.asURL()!
        let aMethod:Alamofire.HTTPMethod = alamofireMethod(method)
        let uploadRequest = Alamofire.upload(data, to: reqUrl, method: aMethod, headers: headers)
        
        return ZGNetworkUploadRequest(uploadRequest)
    }
    
    /// mimeType: "application/octet-stream"
    /// mimeType: "image/jpg"
    /// fileName: imagefile
    public static func uploadFile(
        _ data: Data,
        headers: [String: String]? = nil,
        parameters: [String: String]? = nil,
        fileName: String = "imagefile",
        mimeType: String = "image/jpg",
        to destination: URLConvertible,
        completion: @escaping ((ZGNetworkResponse) -> Void),
        failure: @escaping ((String) -> Void)
        ) -> Void {
        let reqUrl = destination.asURL()!

        Alamofire.upload(multipartFormData:{ multipartFormData in
            if let param = parameters {
                for (key, value) in param {
                    if let d1 = value.data(using: .utf8) {
                        multipartFormData.append(d1, withName: key)
                    }
                }
            }
            multipartFormData.append(data, withName: fileName, fileName: fileName, mimeType: mimeType)
        },
           to:reqUrl,
           method:.post,
           headers:headers,
           encodingCompletion: { encodingResult in
            switch encodingResult {
            case .success(let upload, _, _):
                upload.responseJSON { resp in
                    let tbbzResponse : ZGNetworkResponse = ZGNetworkResponse()
                    tbbzResponse.isSuccess = resp.result.isSuccess
                    tbbzResponse.responseJson = resp.result.value
                    tbbzResponse.response = resp.response
                    tbbzResponse.responseHeaders = resp.response?.allHeaderFields
                    tbbzResponse.responseHttpStatus = resp.response?.statusCode ?? 0
                    completion(tbbzResponse)
                }

            case .failure(let encodingError):
                failure("文件编码失败")
            }
        })
    }
}
