//
//  ZGCoreStringMd5.swift
//
//  Created by zhaogang on 2017/3/8.
//

import Foundation

public extension String {
    
    public func length() -> Int {
        return (self as NSString).length
    }
    
    func trim() -> String {
        return self.trimmingCharacters(in: .whitespaces)
    }
    
    func hexValue() -> Int {
        var hexInt:UInt32 = 0
        Scanner(string: self).scanHexInt32(&hexInt)
        return Int(hexInt)
    }
 
    //采用CryptoSwift
//    func md5() -> String {
//        let str = self.cString(using: String.Encoding.utf8)
//        let strLen = CUnsignedInt(self.lengthOfBytes(using: String.Encoding.utf8))
//        let digestLen = Int(CC_MD5_DIGEST_LENGTH)
//        let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digestLen)
//        CC_MD5(str!, strLen, result)
//        let hash = NSMutableString()
//        for i in 0 ..< digestLen {
//            hash.appendFormat("%02x", result[i])
//        }
//        result.deinitialize()
//
//        return String(format: hash as String)
//    }
    
    func encodeURI() -> String {
        let escapedString:String? = self.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        if (escapedString != nil) {
            return escapedString!
        }
        return self;
    }
    
    
    func encodeURIComponent() -> String {
        
        var customAllowedSet =  NSCharacterSet.init(charactersIn: ":/?#[]@!$ &'()*+,;=\"<>%{}|\\^~`").inverted
        var escapedString = self.addingPercentEncoding(withAllowedCharacters: customAllowedSet)

//        let escapedString:String? = self.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
        if (escapedString != nil) {
            return escapedString!
        }
        return self;
    }
    
    func decodeURI() -> String {
        let retString = self.removingPercentEncoding
        if (retString != nil) {
            return retString!
        }
        return self;
    }
    
    func base64EncodedString() -> String {
        let plainData = self.data(using: String.Encoding.utf8)
        let base64String = plainData?.base64EncodedString(options: Data.Base64EncodingOptions.init(rawValue: 0))
        if (base64String != nil) {
            return base64String!
        }
        return self;
    }
    
    func appendQueryParameters(query:[String:Any]) -> String {
        guard let queryString = query.queryEncoded() else {
            return self
        }
        var s1 = self
        if self.contains("?") {
            s1 += "&"
        } else {
            s1 += "?"
        }
        s1 += queryString
        return s1
    }
    
    
    /// 将URL query转成字典
    ///
    /// - parameter decode: 是否解码，默认true解码
    ///
    func queryDict(decode:Bool=true) -> [String:String] {
        var qDict = [String:String]()
        let textComponents = self.components(separatedBy: "&")
        for item in textComponents {
            let c1 = item.components(separatedBy: "=")
            if c1.count<2 {
                continue
            }
            let key = c1[0]
            var value = c1[1]
            if decode {
                value = value.decodeURI()
            }
            qDict[key] = value
        }
        
        return qDict
    }
    
    func jsonValue() -> Any?{
        guard let data = self.data(using: String.Encoding.utf8) else{
            return nil
        }
        
        if let json = try? JSONSerialization.jsonObject(with: data, options: [.mutableContainers, .mutableLeaves]){
            return json
        }
        return nil
    }
}







