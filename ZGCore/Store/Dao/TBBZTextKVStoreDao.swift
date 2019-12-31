//
//
//  Created by 杨恩锋 on 2017/4/1.
//  Copyright © 2017年 zhe800. All rights reserved.
//

import UIKit
import CoreStore

class EFTextKVStoreDao : EFKVStoreDao {

    func saveText(_ textVo:EFTextKVStoreVo, completion:@escaping EFStoreCompletionHandler) -> Void {
        let text1 = CoreStore.fetchOne(
            From<EFTextKVStore>(),
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
                let kvStore = transaction.create(Into<EFTextKVStore>())
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
    
    func getText(key:String) -> EFTextKVStoreVo? {
        var retVo:EFTextKVStoreVo? = nil
        let text1 = CoreStore.fetchOne(
            From<EFTextKVStore>(),
            Where("z_key", isEqualTo:key)
        )
        if let text2 = text1 {
            retVo = EFTextKVStoreVo()
            retVo?.zKey = key
            retVo?.zValue = text2.z_value
        }
        return retVo
    }
    
    func deleteText(_ textVo:EFTextKVStoreVo) -> Void {
        let text1 = CoreStore.fetchOne(
            From<EFTextKVStore>(),
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
