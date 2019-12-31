//
//  EFNetworkDemoUITests.swift
//  EFNetworkDemoUITests
//
//  Created by 杨恩锋 on 2017/3/15.
//  Copyright © 2017年 zhe800. All rights reserved.
//

import XCTest

class EFNetworkTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    
    func testDownload() {
        var testDirectoryURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
        testDirectoryURL = testDirectoryURL.appendingPathComponent("com.zhe800.iphone")
        testDirectoryURL = testDirectoryURL.appendingPathComponent("img_temp")
        
        let expectation = self.expectation(description: "Download request should download data to file: ")
        
        func downloadProgress(progress: Progress) {
            print("当前进度：\(progress.fractionCompleted*100)%")
        }
        
        func downloadResponse(response: EFNetworkDownloadResponse) {
            if (response.isSuccess) {
                print("下载成功")
                if let destinationURL = response.destinationURL {
                    XCTAssertTrue(FileManager.default.fileExists(atPath: destinationURL.path))
                    
                    if let data = try? Data(contentsOf: destinationURL) {
                        XCTAssertGreaterThan(data.count, 0)
                    } else {
                        XCTFail("data should exist for contents of destinationURL")
                    }
                }
            } else {
                print("下载失败")
            }
            expectation.fulfill()
        }
        
        let url = URL.init(string: "http://sinastorage.com/storage.data.collection.sina.com.cn/ori/1002243_2583_1-29-2243-2625.jpg")
        
        let downloadRequest = EFNetwork.download(url!, to:testDirectoryURL)
        downloadRequest.downloadProgress(queue: DispatchQueue.main,
                                              closure: downloadProgress) //下载进度
        downloadRequest.responseData(completionHandler: downloadResponse) //下载停止响应
        
        waitForExpectations(timeout: 30, handler: nil)
    }
    
    func testUpload() {
        let urlString = "https://httpbin.org/post"
        let data: Data = {
            var text = ""
            for _ in 1...30 {
                text += "Lorem ipsum dolor sit amet, consectetur adipiscing elit. "
            }
            
            return text.data(using: .utf8, allowLossyConversion: false)!
        }()
        
        let expectation = self.expectation(description: "Bytes upload progress should be reported: \(urlString)")
        
        var uploadProgressValues: [Double] = []
        var downloadProgressValues: [Double] = []
        
        // When
        let url1 = URL.init(string: urlString)
        EFNetwork.upload(data, to: url1!)
            .uploadProgress { progress in
                print (">>>>>>>>>>>>>>>>>>>>. upload progress\(progress)")
                uploadProgressValues.append(progress.fractionCompleted)
            }
            .downloadProgress { progress in
                print ("download progress\(progress)")
                downloadProgressValues.append(progress.fractionCompleted)
            }
            .response { resp in
                let code = resp.response?.statusCode
                print("上传...\(code)")
                expectation.fulfill()
        }
        
        waitForExpectations(timeout: 30, handler: nil)
      
        
        var previousUploadProgress: Double = uploadProgressValues.first ?? 0.0
        
        for progress in uploadProgressValues {
            XCTAssertGreaterThanOrEqual(progress, previousUploadProgress)
            previousUploadProgress = progress
        }
        
        if let lastProgressValue = uploadProgressValues.last {
            XCTAssertEqual(lastProgressValue, 1.0)
        } else {
            XCTFail("last item in uploadProgressValues should not be nil")
        }
        
        var previousDownloadProgress: Double = downloadProgressValues.first ?? 0.0
        
        for progress in downloadProgressValues {
            XCTAssertGreaterThanOrEqual(progress, previousDownloadProgress)
            previousDownloadProgress = progress
        }
        
        if let lastProgressValue = downloadProgressValues.last {
            XCTAssertEqual(lastProgressValue, 1.0)
        } else {
            XCTFail("last item in downloadProgressValues should not be nil")
        }
    }
    
}
