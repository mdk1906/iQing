//
//  NSDate+Utilities.swift
//  Qingwen
//
//  Created by mumu on 16/11/29.
//  Copyright © 2016年 iQing. All rights reserved.
//

import UIKit

let D_MINUTE	= 60.0
let D_HOUR		= 3600.0
let D_DAY		= 86400.0
let D_WEEK		= 604800.0
let D_YEAR		= 31556926.0

let componentFlags: Set<Calendar.Component> = [.era, .year,.month, .day, .hour, .minute, .second, .weekday, .weekdayOrdinal]

extension Date {
    
    func isToday() -> Bool {
        return self.isEqualToDateIgnoringTime(date: self)
    }
    
    static func shortTimeBeforeNow(_ date : Date) -> String {
        
        let ti = -date.timeIntervalSinceNow
        if ti > D_YEAR {
            return "\(Int(ti / D_YEAR))年前"
        }
        else if ti > D_WEEK{
            return "\(Int(ti / D_WEEK))周前"
        }
        else if ti > D_DAY {
            return "\(Int(ti / D_DAY))天前"
        }
        else if ti > D_HOUR {
            return "\(Int(ti / D_HOUR))小时前"
        }
        else if ti > D_MINUTE {
            return "\(Int(ti / D_MINUTE))分钟前"
        }
        else {
            return "刚刚"
        }
    }
    
    public func minutesBeforeNow() -> NSInteger {
        let ti = self.timeIntervalSinceNow
        let minutes = abs(NSInteger(ti / D_MINUTE))
        return minutes
    }
    
    public func hoursBeforeNow() -> NSInteger {
        let ti = self.timeIntervalSinceNow
        let hours = abs(NSInteger(ti / D_HOUR))
        return hours
    }
    
    public func daysBeforeNow() -> NSInteger {
        let ti = self.timeIntervalSinceNow
        let days = abs(NSInteger(ti / D_DAY))
        return days
    }
    
    private func isEqualToDateIgnoringTime(date: Date) -> Bool {
        let calendar = Calendar.current
        var components1 = calendar.dateComponents(componentFlags, from: Date())
        var components2 = calendar.dateComponents(componentFlags, from: date)
        return ((components1.year == components2.year) && (components1.month! == components2.month!) && (components1.day == components2.day))
    }
    
}
