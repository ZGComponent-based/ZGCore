//
//  EFBlobKVStoreDao.swift
//  EFCoreDemo
//
//  Created by 杨恩锋 on 2017/4/1.
//  Copyright © 2017年 zhe800. All rights reserved.
//

import UIKit
import CoreStore

class EFBlobKVStoreDao: EFKVStoreDao {
    func saveData(_ textVo:EFBlobKVStoreVo, completion:@escaping EFStoreCompletionHandler) -> Void {
        let text1 = CoreStore.fetchOne(
            From<EFBlobKVStore>(),
            Where("z_key", isEqualTo:textVo.zKey)
        )
        if let text2 = text1 {
            CoreStore.beginAsynchronous { (transaction) -> Void in
                let text3 = transaction.edit(text2)!
                text3.z_value = textVo.zValue
                text3.z_updated = Date()
                transaction.commit()
            }
        } else {
            CoreStore.beginAsynchronous { (transaction) -> Void in
                let kvStore = transaction.create(Into<EFBlobKVStore>())
                kvStore.z_value = textVo.zValue
                kvStore.z_key = textVo.zKey
                kvStore.z_updated = Date()
                
                transaction.commit { (result) -> Void in
                    var success = false
                    switch result {
                    case .success(_):
                        success = true
                    case .failure(_):
                        success = false
                    }
                    
                    completion(success)
                }
            }
        }
    }
    
    func getData(key:String) -> EFBlobKVStoreVo? {
        var retVo:EFBlobKVStoreVo? = nil
        let text1 = CoreStore.fetchOne(
            From<EFBlobKVStore>(),
            Where("z_key", isEqualTo:key)
        )
        if let text2 = text1 {
            retVo = EFBlobKVStoreVo()
            retVo?.zKey = key
            retVo?.zValue = text2.z_value
        }
        return retVo
    }
    
    func deleteData(_ textVo:EFBlobKVStoreVo) -> Void {
        let text1 = CoreStore.fetchOne(
            From<EFBlobKVStore>(),
            Where("z_key", isEqualTo:textVo.zKey)
        )
        if let text2 = text1 {
            CoreStore.beginAsynchronous { (transaction) -> Void in
                transaction.delete(text2)
                transaction.commit()
            }
        }
    }
}
