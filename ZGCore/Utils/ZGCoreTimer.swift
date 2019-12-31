//
//  ZGCoreTimer.swift
//  Pods
//
//  Created by zhaogang on 2017/6/6.
//
//

import UIKit

public class ZGCoreTimer {
    public typealias TimerBlock = (ZGCoreTimer) -> Void
    public var timerBlock:TimerBlock?
    
    var timer:Timer?
    var repeats:Bool
    
    public var timeInterval:TimeInterval = 3
    
    public required init (repeats:Bool = true, timeInterval:TimeInterval = 1) {
        self.repeats = repeats
        self.timeInterval = timeInterval
    }
    
    @objc func fireTimer(_ timer:Timer) {
        guard let timerBlock = self.timerBlock else {
            return
        }
        timerBlock(self)
    }
    
    public func start() {
        self.stop()
        
        if #available(iOS 10.0, *) {
            self.timer = Timer.scheduledTimer(withTimeInterval: self.timeInterval,
                                              repeats: self.repeats,
                                              block: {[weak self] (tm) in
                                                self?.fireTimer(tm)
            })
        } else {
            self.timer = Timer.scheduledTimer(timeInterval: self.timeInterval,
                                              target: self,
                                              selector: #selector(fireTimer(_:)),
                                              userInfo: nil,
                                              repeats: self.repeats)
        }
    }
    
    public func stop() {
        guard let timer = self.timer else {
            return
        }
        timer.invalidate()
        self.timer = nil
    }
}
