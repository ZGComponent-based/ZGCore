//
//  ZGVendorManager.swift
//  Pods
//
//  Created by zhaogang on 2017/9/4.
//
//

import UIKit

public protocol ZGWeChatProtocol {
    func isInstallWeChat() -> Bool
    func shareWith(title: String, description: String, thumbImage: UIImage, webpageUrl: String, isSession: Bool)
}

public protocol ZGSinaProtocol {
    func isInstallSina() -> Bool
    func shareWith(shareText: String, title: String, description: String, thumbImage: Data, webpageUrl: String)
}

public protocol ZGTencentOpenAPIProtocol {
    func isInstallQQ() -> Bool
    func shareWith(title: String, description: String, thumbImage: String, webpageUrl: String, isSession: Bool)
}

//微信支付协议
public protocol ZGWeChatPayProtocol {
    func isInstallWeChat() -> Bool//判断是否安装了微信
    func payWithRequest(partnerId: String, prepayId: String, nonceStr: String, timeStamp: UInt32, package: String, sign: String)
}

//阿里支付协议
public protocol ZGAliPayProtocol {
    func isInstallAliPay() -> Bool//判断是否安装了支付宝
    func payOrder(orderStr: String, schemeStr: String, callback: @escaping (Dictionary<AnyHashable, Any>?)->Void)
    func handleOpenURL(url: URL!) ->Void
}
final public class ZGVendorManager: NSObject {
    
    public var weChat: ZGWeChatProtocol?
    public var sina: ZGSinaProtocol?
    public var tencentOpenApi: ZGTencentOpenAPIProtocol?
    
    public var weChatPay: ZGWeChatPayProtocol?
    public var aliPay: ZGAliPayProtocol?
    
    public static var shared: ZGVendorManager {
        struct Static {
            static let instance: ZGVendorManager = ZGVendorManager()
        }
        return Static.instance
    }
}


