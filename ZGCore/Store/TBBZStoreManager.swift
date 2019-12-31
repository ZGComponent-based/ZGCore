//

//  Created by 杨恩锋 on 2017/4/1.
//  Copyright © 2017年 zhe800. All rights reserved.
//

import UIKit
import CoreStore

public final class EFStoreManager {
    fileprivate let textDao:EFTextKVStoreDao
    fileprivate let blobDao:EFBlobKVStoreDao
    fileprivate var cache:[String:Any]
    
    public static var sharedInstance: EFStoreManager {
        struct Static {
            static let instance: EFStoreManager = EFStoreManager()
        }
        return Static.instance
    }
    
    fileprivate init() {
        CoreStore.defaultStack = DataStack(
            modelName: "tbbz_store"
        )
     
        let progress = CoreStore.addStorage(SQLiteStore(fileName: "tbbz_store.sqlite")) { (result) in
            
                switch result {
                case .success(let storage):
                    print(storage)
                case .failure(let error):
                    print(error)
                }
        }
        if let _ = progress {
            print("a migration has started")
        }
        textDao = EFTextKVStoreDao()
        blobDao = EFBlobKVStoreDao()
        cache = [:]
    }
    
    // MARK: -
    /// 缓存文本
    ///
    /// - parameter text: 如果长度小于255则会同时放到内存中
    /// - parameter key: 自定义key，需要加上模块名称做完前缀，如 home_config
    public func saveText(text:String, key:String, completion:@escaping EFStoreCompletionHandler) -> Void {
        let vo1 = EFTextKVStoreVo()
        vo1.zKey = key
        vo1.zValue = text
        textDao.saveText(vo1, completion: completion)
    }
    
    /// 通过key获取对应的内容，优先读取内存,  如果长度小于255则会同时放到内存中
    /// - parameter key: 自定义key，需要加上模块名称做完前缀，如 home_config
    /// - returns: key对应的内容
    public func getText(key:String) -> String? {
        let vo = textDao.getText(key: key)
        if let kvVo = vo {
            return kvVo.zValue
        }
        
        return nil
    }
    
    public func saveObject(object:NSCoding, key:String, completion:@escaping EFStoreCompletionHandler) -> Void {
        let vo1 = EFBlobKVStoreVo()
        vo1.zKey = key
        vo1.zValue = NSKeyedArchiver.archivedData(withRootObject: object)
        blobDao.saveData(vo1, completion: completion)
    }
    
    public func getObject(key:String) -> Any? {
        let vo = blobDao.getData(key: key)
        if let kvVo = vo {
            if let data = kvVo.zValue {
                return NSKeyedUnarchiver.unarchiveObject(with: data)
            }
        }
        
        return nil
    }
}
