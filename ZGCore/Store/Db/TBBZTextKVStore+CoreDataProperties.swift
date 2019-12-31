//
//  EFTextKVStore+CoreDataProperties.swift
//  
//
//  Created by 杨恩锋 on 2017/4/1.
//
//

import Foundation
import CoreData


extension EFTextKVStore {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<EFTextKVStore> {
        return NSFetchRequest<EFTextKVStore>(entityName: "EFTextKVStore")
    }

    @NSManaged public var z_key: String?
    @NSManaged public var z_updated: Date?
    @NSManaged public var z_value: String?

}
