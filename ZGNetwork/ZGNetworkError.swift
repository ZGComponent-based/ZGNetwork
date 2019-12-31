//
//  ZGNetworkError.swift
//
//  Created by zhaogang on 2017/3/15.
//

import UIKit

public class ZGNetworkError: NSObject {
    public var tag:Int = 0
    public var userData:Any?
    public var response:ZGNetworkResponse?
    public var errorMessage:String?
}
