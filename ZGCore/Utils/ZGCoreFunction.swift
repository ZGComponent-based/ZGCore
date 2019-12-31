//
//  ZGCoreFunction.swift
//
//  Created by zhaogang on 2017/3/9.
//

import Foundation
import UIKit
//import SwiftWebP
import SystemConfiguration.CaptiveNetwork
import AdSupport
import CoreTelephony

public enum ZGNetworkStatus:String {
    case unknown = "unknown"
    case notReachable = "notReachable"
    case wwan2G = "2G"
    case wwan3G = "3g"
    case wwan4G = "4g"
    case wwan = "wwan"
    case wifi = "wifi"
}

public final class ZGDeviceInfo : NSObject, NSCopying {
    
    public var systemName:String?
    public var phoneModel:String?
    public var resolution:String?
    public var product:String?
    public var deviceId:String?
    public var partner:String?
    public var telNum:String?
    public var systemVersion:String?
    public var appVersion:String?
    public var buildVersion:String?
    public var networkStatus:ZGNetworkStatus?
    public var platform:String?
    
    public var carrierCode:String? //carrier.mobileCountryCode, carrier.mobileNetworkCode
    public var carrierName:String?
    public var mobileCountryCode:String?
    public var mobileNetworkCode:String?
    
    public override init() {
        super.init()
        let device = UIDevice.current
        let screen = UIScreen.main
        let info = CTTelephonyNetworkInfo()
        let carrier = info.subscriberCellularProvider
        
        systemName = device.systemName
        phoneModel = ZGCoreMachine()
        systemVersion = device.systemVersion
        if let size = screen.currentMode?.size {
            let w1 = Int(size.width)
            let h1 = Int(size.height)
            resolution = "\(w1)*\(h1)"
        }
        carrierName = carrier?.carrierName ?? ""
        if let mobileCountryCode = carrier?.mobileCountryCode, let mobileNetworkCode = carrier?.mobileNetworkCode {
            carrierCode = "\(mobileCountryCode)\(mobileNetworkCode)"
        }
        mobileCountryCode = carrier?.mobileCountryCode
        mobileNetworkCode = carrier?.mobileNetworkCode
    }
    
    public func copy(with zone: NSZone? = nil) -> Any {
        let vo = ZGDeviceInfo()
        
        vo.product = self.product
        vo.networkStatus = self.networkStatus
        vo.telNum = self.telNum
        vo.buildVersion = self.buildVersion
        vo.appVersion = self.appVersion
        vo.platform = self.platform
        vo.systemVersion = self.systemVersion
        vo.systemName = self.systemName
        vo.deviceId = self.deviceId
        vo.carrierName = self.carrierName
        vo.phoneModel = self.phoneModel
        vo.carrierCode = self.carrierCode
        vo.partner = self.partner
        vo.resolution = self.resolution
        
        return vo
    }

}

/// 获取机型，如iPhone4,1  iPad3,1
public func ZGCoreMachine() -> String {
    let size : UnsafeMutablePointer<Int> = UnsafeMutablePointer<Int>.allocate(capacity: 1)
    size.initialize(to: 0)
    
    sysctlbyname("hw.machine", nil, size, nil, 0)
    var machine = [CChar](repeating: 0, count: size.pointee)
    sysctlbyname("hw.machine", &machine, size, nil, 0)
    size.deinitialize(count: size.pointee)
    
    
    return String(cString: machine)
}

// Decodes the image's data and draws it off-screen fully in memory; it's thread-safe and hence can be called on a background thread.
// On success, the returned object is a new `UIImage` instance with the same content as the one passed in.
// On failure, the returned object is the unchanged passed in one; the data will not be predrawn in memory though and an error will be logged.
// First inspired by & good Karma to: https://gist.github.com/steipete/1144242
// 以下，将上面oc的写法改为swift
public func predrawnImageFromImage(_ imageToPredraw:UIImage) -> UIImage {
    // Always use a device RGB color space for simplicity and predictability what will be going on.
    let colorSpaceDeviceRGBRef = CGColorSpaceCreateDeviceRGB()
    
    // Even when the image doesn't have transparency, we have to add the extra channel because Quartz doesn't support other pixel formats than 32 bpp/8 bpc for RGB:
    // kCGImageAlphaNoneSkipFirst, kCGImageAlphaNoneSkipLast, kCGImageAlphaPremultipliedFirst, kCGImageAlphaPremultipliedLast
    // (source: docs "Quartz 2D Programming Guide > Graphics Contexts > Table 2-1 Pixel formats supported for bitmap graphics contexts")
//    size_t numberOfComponents = CGColorSpaceGetNumberOfComponents(colorSpaceDeviceRGBRef) + 1; // 4: RGB + A
    let numberOfComponents = colorSpaceDeviceRGBRef.numberOfComponents + 1
    guard let cgImage = imageToPredraw.cgImage else {
        return imageToPredraw
    }
    
    // "In iOS 4.0 and later, and OS X v10.6 and later, you can pass NULL if you want Quartz to allocate memory for the bitmap." (source: docs)
//    void *data = NULL;
    let width:Int = cgImage.width
    let height:Int = cgImage.height
 
    let bitsPerComponent:Int = Int(CHAR_BIT)
    
    let bitsPerPixel:Int = (bitsPerComponent * numberOfComponents)
    let bytesPerPixel:Int = (bitsPerPixel / Int(BYTE_SIZE))
    let bytesPerRow:Int = (bytesPerPixel * width)
    
    var bitmapInfo:CGImageByteOrderInfo = .orderDefault
//    CGBitmapInfo bitmapInfo = kCGBitmapByteOrderDefault;
    var alphaInfo:CGImageAlphaInfo = cgImage.alphaInfo
 
    // If the alpha info doesn't match to one of the supported formats (see above), pick a reasonable supported one.
    // "For bitmaps created in iOS 3.2 and later, the drawing environment uses the premultiplied ARGB format to store the bitmap data." (source: docs)
    if alphaInfo == .none || alphaInfo == .alphaOnly {
        alphaInfo = .noneSkipFirst
    } else if alphaInfo == .first {
        alphaInfo = .premultipliedFirst
    } else if alphaInfo == .last {
        alphaInfo = .premultipliedLast
    }
    // "The constants for specifying the alpha channel information are declared with the `CGImageAlphaInfo` type but can be passed to this parameter safely." (source: docs)
    let bitmapInfo32 = bitmapInfo.rawValue | alphaInfo.rawValue
    
    // Create our own graphics context to draw to; `UIGraphicsGetCurrentContext`/`UIGraphicsBeginImageContextWithOptions` doesn't create a new context but returns the current one which isn't thread-safe (e.g. main thread could use it at the same time).
    // Note: It's not worth caching the bitmap context for multiple frames ("unique key" would be `width`, `height` and `hasAlpha`), it's ~50% slower. Time spent in libRIP's `CGSBlendBGRA8888toARGB8888` suddenly shoots up -- not sure why.
    let bitmapContextRef1 = CGContext(data: nil,
                                      width: width,
                                      height: height,
                                      bitsPerComponent: bitsPerComponent,
                                      bytesPerRow: bytesPerRow,
                                      space: colorSpaceDeviceRGBRef,
                                      bitmapInfo: bitmapInfo32)

    // Early return on failure!
    guard let bitmapContextRef = bitmapContextRef1 else {
        return imageToPredraw
    }

    // Draw image in bitmap context and create image by preserving receiver's properties.
    let size = CGSize.init(width: width, height: height)
    bitmapContextRef.draw(cgImage, in: CGRect.init(origin: .zero, size: size))
    guard let predrawnImageRef = bitmapContextRef.makeImage() else {
        return imageToPredraw
    }
    
    return UIImage(cgImage: predrawnImageRef, scale: imageToPredraw.scale, orientation: imageToPredraw.imageOrientation)
}

public func ZGImageForData(_ data:Data) -> UIImage? {
    let len:Int = data.count
    if len > 12 {
//        var start = data.index(data.startIndex, offsetBy: 0)
//        var end = data.index(data.startIndex, offsetBy: 4)
        let headerRange:Range<Data.Index> = 0..<4
        let footerRange:Range<Data.Index> = 8..<12
        
        let headerData:Data = data.subdata(in:headerRange)
        let footerData:Data = data.subdata(in:footerRange)
        
        let headerText = String.init(data: headerData, encoding: .utf8)
        let footerText = String.init(data: footerData, encoding: .utf8)
        
        if headerText == "RIFF" && footerText == "WEBP" {
            return UIImage.init(data: data)
        } else {
            return UIImage.init(data: data)
        }
    } else {
        return UIImage.init(data: data)
    }
}
 
/// 加载图片
/// - parameter path:  如: bundle://ZGUI/1.jpg
public func ZGImage(_ path:String) -> UIImage? {
    return ZGURLCache.sharedInstance.imageForUrl(path, fromDisk: true)
}

public func ZGMinimumLineHeight() -> CGFloat {
    return 0.5
}

public func ZGDeviceId() -> String {
    let u = NSUUID.init()
    var returnId:String = u.uuidString
    
    let idfa = ZGMDeviceId().idfa
    if let idfa1 = idfa {
        returnId = idfa1
    }
 
    return returnId.replacingOccurrences(of: "-", with: "")
}

public func ZGLog(_ items: Any...) {
    print(items)
}

/// 获取设备指纹
///
/// - returns: tuple (vendorId, adid, bssid, ssid)

public func ZGMDeviceId() -> (idfv:String?, idfa:String?, bssid:String, ssid:String) {
    var asIdentifier:String? = nil
    var identifierForVendor :String? = nil
    
    let uuid = UIDevice.current.identifierForVendor
    if let uuidText = uuid {
        identifierForVendor = uuidText.uuidString
    }
    
    if ASIdentifierManager.shared().isAdvertisingTrackingEnabled {
        asIdentifier = ASIdentifierManager.shared().advertisingIdentifier.uuidString
    }
    
    let interfaces:NSArray? = CNCopySupportedInterfaces()
    
    var ssid: String?
    var bssid: String?
    
    if let interfaces2 = interfaces {
        for sub in interfaces2 {
            if let dict = CFBridgingRetain(CNCopyCurrentNetworkInfo(sub as! CFString)) {
                ssid = dict["SSID"] as? String
                bssid = dict["BSSID"] as? String
            }
        }
    }
    var ssidText = "", bssidText = ""
    if let ssid1 = ssid {
        ssidText = ssid1
    }
    if let mac1 = bssid {
        bssidText = mac1
    }
    return (identifierForVendor, asIdentifier, bssidText, ssid:ssidText)
}

func ZGDeviceScreenHasLength (bounds:CGRect, width:CGFloat) -> Bool {
    
    let gHeight:CGFloat = bounds.height
    let gWidth:CGFloat = bounds.width
    
    let maxParam:CGFloat = max(gWidth, gHeight)

    return fabs( maxParam - width) < CGFloat.ulpOfOne
}

public func ZGIsIPhone6() -> Bool{
    if UIScreen.main.scale > 2.9 {
        return false
    }
    return ZGDeviceScreenHasLength(bounds: UIScreen.main.bounds, width: 667)
}

public func ZGIsIPhone5() -> Bool{
    return ZGDeviceScreenHasLength(bounds: UIScreen.main.bounds, width: 568)
}

public func ZGIsIPhone4OrLess() -> Bool{
    return ZGIsIPhone() && UIScreen.main.bounds.size.height<568
}

public func ZGIsIPhone() -> Bool{
    return UIDevice.current.userInterfaceIdiom == .phone
}

/// 是否为3倍分辨率的 6p, 7p等
public func ZGIsIPhonePlus() -> Bool {
    let bounds = UIScreen.main.bounds
    var isOk = ZGDeviceScreenHasLength(bounds:bounds, width: 736)
    if (!isOk) {
        isOk = ZGDeviceScreenHasLength(bounds:bounds, width: 667)
        if (UIScreen.main.scale < 3) {
            //是iphone6
            isOk = false
        }
    }
    return isOk
}

public func ZGIsIPhonePlusStandard() -> Bool {
    let bounds = UIScreen.main.bounds
    return ZGDeviceScreenHasLength(bounds:bounds, width: 736)
}

public func SuitOnePixelHeight () -> CGFloat {
    var h: CGFloat = 1
    let screenWidth = UIScreen.main.bounds.size.width
    if screenWidth > 320 {
        if ZGIsIPhonePlus() {
            h = 1.0/3.0
        }else{
            h = 0.5
        }
    }else{
        h = 1
    }
    return h
}

