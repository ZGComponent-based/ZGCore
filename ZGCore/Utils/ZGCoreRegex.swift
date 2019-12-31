//
//  ZGCoreRegex.swift
//
//  Created by zhaogang on 2017/3/9.
//

import Foundation


public func ~= (input: String, pattern: String) -> Bool {
    return ZGCoreRegex(pattern).test(input)
}

public struct ZGCoreRegex {
    let internalExpression: NSRegularExpression?
    let pattern: String
    
    public init(_ pattern: String) {
        self.pattern = pattern
        
        do {
            self.internalExpression = try NSRegularExpression(
                pattern: pattern,
                options: [.caseInsensitive, .dotMatchesLineSeparators])
        }
        catch {
            self.internalExpression = nil
            print(error)
        }
    }
    
    public func test(_ input: String) -> Bool {
        if let expression = self.internalExpression {
            let len = String.init(input).count
            let range:NSRange = NSMakeRange(0, len)
            let matches = expression.matches(in: input,
                                             options: NSRegularExpression.MatchingOptions.reportCompletion,
                                             range: range)
            return matches.count > 0
        }
        
        return false
    }
    
    public func matches(_ input: String) -> [NSTextCheckingResult]? {
        if let expression = self.internalExpression {
            let len = String.init(input).count
            let range:NSRange = NSMakeRange(0, len)
            
            return expression.matches(
                in: input,
                options: NSRegularExpression.MatchingOptions.reportCompletion,
                range: range)
        }
        
        return nil
    }
    
    @discardableResult
    public func replaceMatches(_ input:NSMutableString, withString:String) -> Int {
        if let expression = self.internalExpression {
            let len = input.length
            let range:NSRange = NSMakeRange(0, len)
            return expression.replaceMatches(
                in: input,
                options: .reportCompletion,
                range: range,
                withTemplate: withString)
            
        }
        
        return 0
    }
    
}
