//
//  ZGCoreDictionaryExtension.swift
//  Pods
//
//  Created by zhaogang on 2017/5/3.
//
//

import Foundation

public func += <K, V> (left: inout [K:V], right: [K:V]) {
    for (k, v) in right {
        left[k] = v
    }
}

public extension Dictionary {
    func jsonString() -> String?{
        guard let data = try? JSONSerialization.data(withJSONObject: self, options: .prettyPrinted) else{
            return nil
        }
        
        return String(data: data, encoding: String.Encoding.utf8) 
    }
    
    func query() -> String? {
        if self.count < 1 {
            return nil
        }
        var textArr = [String]()
        for (key, value) in self {
            let text = "\(key)=\(value)"
            textArr.append(text)
        }
        return textArr.joined(separator: "&")
    }
    
    func queryEncoded() -> String? {
        if self.count < 1 {
            return nil
        }
        var textArr = [String]()
        for (key, value) in self {
            var str:String = ""
            if value is String {
                str = value as! String
                str = str.decodeURI()
                str = str.encodeURIComponent()
            } else {
                str = "\(value)"
            }
            let text = "\(key)=\(str)"
            textArr.append(text)
        }
        return textArr.joined(separator: "&")
    }
}
