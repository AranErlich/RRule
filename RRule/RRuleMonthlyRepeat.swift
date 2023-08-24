//
//  RRuleMonthlyRepeat.swift
//  Bzik
//
//  Created by Aran Erlich on 24/08/2023.
//

import Foundation

struct RRuleMonthlyRepeat: RRuleGenerative {
    /// 1-999
    var repeatEvery: Int
    var dayInMonth: Int?
    var weekPosition: RRuleWeekInMonthPosition?
    
    init(repeatEvery: Int, dayInMonth: Int?) {
        self.repeatEvery = repeatEvery
        self.dayInMonth = dayInMonth
        self.weekPosition = nil
    }
    
    init(repeatEvery: Int, weekPosition: RRuleWeekInMonthPosition?) {
        self.repeatEvery = repeatEvery
        self.weekPosition = weekPosition
        self.dayInMonth = nil
    }
    
    var rule: String {
        var rule = ""
        if let dayInMonth = dayInMonth {
            rule += "BYMONTHDAY=\(dayInMonth);"
        } else if let weekPosition = weekPosition {
            rule += "BYSETPOS=\(weekPosition.week.rawValue);BYDAY=\(weekPosition.day.rawValue);"
        } else {
            // TODO: - empty?, potential error
            return rule
        }
        rule += "INTERVAL=\(repeatEvery)"
        
        return rule
    }
    
    init(_ value: [String], start: Date) {
        repeatEvery = 1
        dayInMonth = start.component(.day)
        weekPosition = nil
        
        for item in value {
            let components = item.components(separatedBy: "=")
            guard let first = components.first, let last = components.last else { continue }
            
            if first == "INTERVAL" {
                repeatEvery = Int(last) ?? 1
            } else if first == "BYMONTHDAY" {
                dayInMonth = Int(last) ?? start.component(.day)
                weekPosition = nil
            } else if first == "BYDAY" {
                if let intervalChar = last.first, intervalChar != "-" {
                    let index = last.index(last.startIndex, offsetBy: 1)
                    
                    if let weekPosition = RRuleWeekInMonthPosition.WeekPosition(rawValue: String(intervalChar)),
                       let byDay = RRuleByDay(rawValue: String(last[index..<last.endIndex])) {
                        self.weekPosition = RRuleWeekInMonthPosition(week: weekPosition, day: byDay)
                        dayInMonth = nil
                    }
                } else {
                    let weekInterval = String(last.prefix(2))
                    let dayString = String(last.suffix(2))
                    
                    if let weekPosition = RRuleWeekInMonthPosition.WeekPosition(rawValue: String(weekInterval)),
                       let byDay = RRuleByDay(rawValue: dayString) {
                        self.weekPosition = RRuleWeekInMonthPosition(week: weekPosition, day: byDay)
                        dayInMonth = nil
                    }
                }
            }
        }
    }
}
