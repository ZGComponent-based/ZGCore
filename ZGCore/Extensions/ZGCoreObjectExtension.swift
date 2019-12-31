//
//  File.swift
//  ZGCore
//
//  Created by mac on 2018/5/24.
//

import Foundation
//添加object属性
private var AnalysisNameKey: String = "analysis_name"
private var AnalysisIdKey: String = "analysis_id"
private var AnalysisParameterKey: String = "analysis_parameter"
private var DataParameterKey: String = "data_parameter"
public extension NSObject {
    var analysis_name:String? {
        
        get {
            return (objc_getAssociatedObject(self, &AnalysisNameKey) as? String)
        }
        set(newValue) {
            objc_setAssociatedObject(self, &AnalysisNameKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
        
    }
    
    
    var analysis_id:String? {
        
        get {
            return (objc_getAssociatedObject(self, &AnalysisIdKey) as? String)
        }
        set(newValue) {
            objc_setAssociatedObject(self, &AnalysisIdKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
        
    }
    var analysis_parameter:String? {
        
        get {
            return (objc_getAssociatedObject(self, &AnalysisParameterKey) as? String)
        }
        set(newValue) {
            objc_setAssociatedObject(self, &AnalysisParameterKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
        
    }
    
    var data_parameter:Any? {
        
        get {
            return (objc_getAssociatedObject(self, &DataParameterKey) as? Any)
        }
        set(newValue) {
            objc_setAssociatedObject(self, &DataParameterKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
        
    }
    
}
