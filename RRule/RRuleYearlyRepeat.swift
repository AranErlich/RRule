//
//  RRuleYearlyRepeat.swift
//  Bzik
//
//  Created by Aran Erlich on 24/08/2023.
//

import Foundation

struct RRuleYearlyRepeat: RRuleGenerative {
    enum ByMonth: String {
        case january = "1"
        case february = "2"
        case march = "3"
        case april = "4"
        case may = "5"
        case june = "6"
        case july = "7"
        case august = "8"
        case september = "9"
        case october = "10"
        case november = "11"
        case december = "12"
    }
    
    var repeatEvery: Int
    var bymonth: ByMonth
    var dayInMonth: Int?
    var weekInMonth: RRuleWeekInMonthPosition?
    
    var rule: String {
        var rule = ""
        
        if let dayInMonth = dayInMonth {
            rule += "BYMONTH=\(bymonth.rawValue);BYMONTHDAY=\(dayInMonth)"
        } else if let weekInMonth = weekInMonth {
            rule += "BYSETPOS=\(weekInMonth.week.rawValue);BYDAY=\(weekInMonth.day.rawValue);BYMONTH=\(bymonth.rawValue)"
        } else {
            // TODO: - empty?, potential error
            return rule
        }
        rule += "INTERVAL=\(repeatEvery)"
        
        return rule
    }
    
    init(repeatEvery: Int, bymonth: ByMonth, dayInMonth: Int?) {
        self.repeatEvery = repeatEvery
        self.bymonth = bymonth
        self.dayInMonth = dayInMonth
        self.weekInMonth = nil
    }
    
    init(repeatEvery: Int, bymonth: ByMonth, weekInMonth: RRuleWeekInMonthPosition?) {
        self.repeatEvery = repeatEvery
        self.bymonth = bymonth
        self.dayInMonth = nil
        self.weekInMonth = weekInMonth
    }
    
    init(_ value: [String], start: Date) {
        repeatEvery = 1
        bymonth = ByMonth(rawValue: String(start.component(.month) ?? 1)) ?? .january
        dayInMonth = start.component(.day) ?? 1
        weekInMonth = nil
        
        for item in value {
            let components = item.components(separatedBy: "=")
            guard let first = components.first, let last = components.last else { continue }
            
            if first == "INTERVAL" {
                repeatEvery = Int(last) ?? 1
            } else if first == "BYMONTH" {
                if let month = ByMonth(rawValue: last) {
                    bymonth = month
                }
            } else if first == "BYSETPOS" {
                let weekday = String(start.toString(style: .weekday).prefix(2)).uppercased()
                if let week = RRuleWeekInMonthPosition.WeekPosition(rawValue: last), let day = RRuleByDay(rawValue: weekday) {
                    weekInMonth = RRuleWeekInMonthPosition(week: week, day: day)
                    dayInMonth = nil
                }
            }
        }
    }
}
