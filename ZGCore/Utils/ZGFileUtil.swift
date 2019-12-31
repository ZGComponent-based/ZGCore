//
//  ZGFileUtil.swift
//
//  Created by zhaogang on 2017/3/10.
//

import Foundation

public enum ZGFileEnum: String {
    case bundlePrefix="bundle://"
}

public struct ZGFileUtil {
    
    public static func isGif(_ imageData:Data) -> Bool {
        let len = imageData.count
        if len > 6 {
            let startIndex = imageData.startIndex
            let upperIndex = imageData.index(startIndex, offsetBy: 6)
            let range = Range.init(uncheckedBounds: (lower: startIndex, upper: upperIndex))
            let headerData = imageData.subdata(in: range)
            let headerString:String? = String.init(data: headerData, encoding: .utf8)
            if var hString = headerString {
                hString = hString.lowercased()
                return hString.hasPrefix("gif")
            }
            
            return false
            
        } else {
            return false
        }
    }
    
    public static func cachePathWithName(_ name:String) -> String {
        let paths:[String] = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)
        let cachesPath:String = paths[0]
        let cachePath:String = cachesPath.appendingFormat("/%@", name)
        
        let successful = ZGFileUtil.createPathIfNecessary(cachePath)
        if (successful) {
            return cachePath
        }
        
        return cachesPath
    }
    
    public static func createPathIfNecessary(_ path:String) -> Bool {
        let fm:FileManager = FileManager.default
        if !fm.fileExists(atPath: path) {
            do {
                try fm.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
                return true
            } catch {
                return false
            }
        }
        return true
    }
    
    public static func isBundleURL(_ path:String) -> Bool {
        return path.hasPrefix(ZGFileEnum.bundlePrefix.rawValue)
    }
    
    /// 判断文件是否存在
    /// - parameter bundleFile:  如: bundle://ZGUI/1.jpg
    ///
    public static func exitsForBundleFile(_ bundleFile:String) -> Bool {
        guard let path = self.pathForBundleUrl(bundleFile) else {
            return false
        }
        let fm:FileManager = FileManager.default
        return fm.fileExists(atPath: path)
    }
    
    public static func pathForBundleUrl(_ bundleUrl:String) -> String? {
        
        if isBundleURL(bundleUrl) {
            let count = String.init(ZGFileEnum.bundlePrefix.rawValue).count
            let modelString = bundleUrl.substring(from: bundleUrl.index(bundleUrl.startIndex, offsetBy: count))
            
            let subArr = modelString.components(separatedBy: "/")
            let name:String? = subArr.last
            var bundle:Bundle? = nil
            
            if subArr.count == 2 {
                //来自framework的图片
                let modelName:String = subArr[0]
                let identifier = "org.cocoapods." + modelName
                bundle = Bundle.init(identifier: identifier)
            } else {
                bundle = Bundle.main
            }
            
            let resourcePath = bundle?.resourcePath
            if var rPath = resourcePath, let imageName = name {
                rPath = rPath + "/\(imageName)"
                return rPath
            }
            return resourcePath
        }
        return bundleUrl
    }
    
    /// 获取bundle资源文件
    /// - parameter path:  如: bundle://ZGUI/1.jpg
    /// bundle://111.jpg 代表加载当前模块的图片
    public static func loadBundlFile(_ path:String) -> Data? {
        let path1 = self.pathForBundleUrl(path)
        if let filePath = path1 {
            let fm:FileManager = FileManager.default
            return fm.contents(atPath: filePath)
        }
        
        return nil
    }
}
