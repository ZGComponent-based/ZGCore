//
//  ZGURLCache.swift
//
//  Created by zhaogang on 2017/3/9.
//

import Foundation
import UIKit
import CryptoSwift

enum ZGURLCacheEnum : Int {
    case limitedImageSize = 2250000; //1500*1500
    case expireDays = 3 ; //超过3天则视为过期， 应用启动时执行删除操作
}

final public class ZGURLCache: NSObject {
    let cachePath:String
    var imageCache: Dictionary<String, UIImage>
    
    public static var sharedInstance: ZGURLCache {
        struct Static {
            static let instance: ZGURLCache = ZGURLCache()
        }
        return Static.instance
    }
    
    @objc func didReceiveMemoryWarning()  {
        self.cleanMemoryCache()
    }
    
    fileprivate override init() {
        self.cachePath = ZGFileUtil.cachePathWithName("zg_cache")
        self.imageCache = [:]
        super.init()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didReceiveMemoryWarning),
                                               name: UIApplication.didReceiveMemoryWarningNotification,
                                               object: nil)
    }
    
    public func saveTempImage(imageData:Data, imagName:String) -> String {
        let path = self.cachePath.appendingFormat("/%@", imagName)
        let fm:FileManager = FileManager.default
        fm.createFile(atPath: path, contents: imageData, attributes: nil)
        return path
    }
    
    public func keyForURL(_ urlString:String) -> String {
        var returnKey:String
        
        let urlString1:String = urlString.copy() as! String
        if (ZGFileUtil.isBundleURL(urlString1)) {
            returnKey = urlString1;
        } else if (urlString1.hasPrefix("file")) {
            returnKey = urlString1;
        } else {
            let url:URL? = URL.init(string:urlString1)
            if (url != nil && url!.scheme != nil) {
                let sIndex:Int = String.init(url!.scheme!).count + 1
//                let sIndex:Int = url!.scheme!.characters.count+1
                let fromIndex = urlString1.index(urlString1.startIndex, offsetBy: sIndex)
                returnKey = urlString1.substring(from:fromIndex)
            } else {
                returnKey = urlString1;
            }
        }
        
        return returnKey.md5()+".hm"
    }
    
    public func pathForUrl(_ url:String) -> String {
        let key = self.keyForURL(url) 
        return self.cachePath.appendingFormat("/%@", key)
    }
    
    public func storeData(_ data:Data, forUrl:String) -> Void {
        let path = self.pathForUrl(forUrl)
        let fm:FileManager = FileManager.default
        fm.createFile(atPath: path, contents: data, attributes: nil)
    }
    
    public func dataForURL(forUrl:String) -> Data? {
        //todo @2x, @3x
        if ZGFileUtil.isBundleURL(forUrl) {
            return ZGFileUtil.loadBundlFile(forUrl)
        }
        
        let key = self.keyForURL(forUrl)
        let fm:FileManager = FileManager.default
        let filePath = self.cachePath.appendingFormat("/%@", key)
        return fm.contents(atPath: filePath)
    }
    
    /// 缓存图片
    public func storeImage(image:UIImage?, forUrl:String) -> Void {
        guard let pImage = image else {
            return
        }
        
        let key = self.keyForURL(forUrl)
        
        let pixelCount:CGFloat = pImage.size.width * pImage.size.height;
        let pCount = Int(pixelCount)
        let max = ZGURLCacheEnum.limitedImageSize.rawValue
        if pCount > max  {
            return
        }
        objc_sync_enter(self)
        self.imageCache[key] = pImage
        objc_sync_exit(self)
    }
    
    func fileExists(atPath path:String) -> Bool {
        let path1 = ZGFileUtil.pathForBundleUrl(path)
        if let fPath = path1 {
            let fm:FileManager = FileManager.default
            return fm.fileExists(atPath:fPath)
        }
        return false
    }
    
    func retinaImagePath(urlPath:String) -> String {
        if urlPath.hasPrefix(".") {
            return urlPath
        }
        let arr = urlPath.components(separatedBy: ".")
        if arr.count<2 {
            return urlPath
        }
        let path1 = arr.first
        let path2 = arr.last
        
        if let fPath = path1, let extPath = path2 {
            if fPath.hasSuffix("@2x") || fPath.hasSuffix("@3x") {
                return urlPath
            }
            
            let retPath1 = fPath+"@\(Int(UIScreen.main.scale))x."+extPath
            let retPath2 = fPath+"@2x."+extPath
            if self.fileExists(atPath: retPath1) {
                return retPath1
            } else if self.fileExists(atPath: retPath2) {
                return retPath2
            } else {
                return urlPath
            }
        } else {
            return urlPath
        }
    }
    
    public func imageForUrl(_ forUrl:String, fromDisk:Bool) -> UIImage? {
        let key = self.keyForURL(forUrl)
        objc_sync_enter(self)
        let img = self.imageCache[key]
        objc_sync_exit(self)
        
        if let imgObj = img {
            return imgObj
        }
        
        if !fromDisk {
            return nil
        }
        
        if ZGFileUtil.isBundleURL(forUrl) {
            let filePath = self.retinaImagePath(urlPath: forUrl)
            
            if var image = self.loadImageFromBundle(filePath) {
                image = predrawnImageFromImage(image)
                self.storeImage(image: image, forUrl: forUrl)
                return image
            }
        } else if forUrl.hasPrefix("http") || forUrl.hasPrefix("//") || forUrl.hasPrefix("file://") {
            let data1 = self.dataForURL(forUrl: forUrl)
            if let imgData = data1 {
                if var image = ZGImageForData(imgData) {
                    image = predrawnImageFromImage(image)
                    self.storeImage(image: image, forUrl: forUrl)
                    return image
                }
            }
        } else {
            return UIImage.init(named: forUrl)
        }
  
        return nil;
    }
    
    public func cleanMemoryCache() {
        
        objc_sync_enter(self)
        self.imageCache.removeAll(keepingCapacity: true)
        objc_sync_exit(self)
    }
    
    private func removeFile(filePath:String) {
        let fm:FileManager = FileManager.default
        do {
            try fm.removeItem(atPath: filePath)
        } catch {
            //暂不处理删除失败的情况
        }
    }
    
    public func cleanExpiresData() {
        self.cleanMemoryCache()
        
        let fm:FileManager = FileManager.default
        do {
            let files:[String] = try fm.contentsOfDirectory(atPath: self.cachePath)
            for fileName in files {
                if fileName.hasSuffix(".hm") {
                    let filePath = self.cachePath.appendingFormat("/%@", fileName)
                    self.removeFile(filePath: filePath)
                }
            }
        } catch {
            //暂不处理异常情况
        }
    }
    
    public func loadImageFromBundle(_ path:String) -> UIImage? {
        let path1 = ZGFileUtil.pathForBundleUrl(path)
        if let filePath = path1 {
            return UIImage.init(contentsOfFile: filePath)
        } else {
            return nil
        }
    }
}
