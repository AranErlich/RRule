//
//  RRuleFactory.swift
//  Bzik
//
//  Created by Aran Erlich on 27/07/2023.
//

// shutout to: https://freetools.textmagic.com/rrule-generator for giving the free tool to have na understanable logic
// Google iCalendar documentation for recurring events: https://developers.google.com/calendar/api/concepts/events-calendars#recurring_events
// RFC 5545 documentation: https://datatracker.ietf.org/doc/html/rfc5545

import Foundation

struct RRuleFactory {
    
    private let freq: Frequency
    private let end: End
    
    init(freq: Frequency, end: End) {
        self.freq = freq
        self.end = end
    }
    
    var rrule: String? {
        var rrule: String = "RRULE:"
        rrule += freq.rule
        switch freq {
        case .hourly(let ruleGenerative), .daily(let ruleGenerative), .weekly(let ruleGenerative), .monthly(let ruleGenerative), .yearly(let ruleGenerative):
            rrule += ruleGenerative.rule
        }
        rrule += end.rule
        
        return rrule
    }
    
    enum Frequency: RRuleGenerative {
        /// 1-999 hours
        case hourly(RRuleGenerative)
        /// 1-999 days
        case daily(RRuleGenerative)
        case weekly(RRuleGenerative)
        case monthly(RRuleGenerative)
        case yearly(RRuleGenerative)
        
        var rawValue: String {
            switch self {
            case .hourly:
                return "HOURLY"
            case .daily:
                return "DAILY"
            case .weekly:
                return "WEEKLY"
            case .monthly:
                return "MONTHLY"
            case .yearly:
                return "YEARLY"
            }
        }
        
        var rule: String {
            "FREQ=\(rawValue);"
        }
    }
    
    enum End: RRuleGenerative {
        case never
        case after(Int)
        case onDate(Date)
        
        var rule: String {
            var rule = ""
            
            switch self {
            case .never:
                break
            case .after(let count):
                rule += ";COUNT=\(count)"
            case .onDate(let date):
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyyMMdd"
                let stringFormat = formatter.string(from: date)
                rule += ";UNTIL=\(stringFormat)T000000Z"
            }
            
            return rule
        }
    }
    
    /// Should use for hourly and daily cases
    struct CycleRepeat: RRuleGenerative {
        let every: Int
        
        var rule: String {
            "INTERVAL=\(every)"
        }
    }
    
    struct WeeklyRepeat: RRuleGenerative {
        let repeatEvery: Int
        let byday: [ByDay]
        
        private var days: String {
            let reduced = byday.reduce("") { partialResult, day in
                var result = partialResult
                
                if partialResult.isEmpty {
                    result += day.rawValue
                } else {
                    result += "," + day.rawValue
                }
                
                return result
            }
            
            return reduced
        }
        
        var rule: String {
            "BYDAY=\(days);INTERVAL=\(repeatEvery)"
        }
    }
    
    struct MonthlyRepeat: RRuleGenerative {
        /// 1-999
        let repeatEvery: Int
        let dayInMonth: Int?
        let weekPosition: WeekInMonthPosition?
        
        init(repeatEvery: Int, dayInMonth: Int?) {
            self.repeatEvery = repeatEvery
            self.dayInMonth = dayInMonth
            self.weekPosition = nil
        }
        
        init(repeatEvery: Int, weekPosition: WeekInMonthPosition?) {
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
    }
    
    struct YearlyRepeat: RRuleGenerative {
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
        
        let bymonth: ByMonth
        let dayInMonth: Int?
        let weekInMonth: WeekInMonthPosition?
        
        init(bymonth: ByMonth, dayInMonth: Int?) {
            self.bymonth = bymonth
            self.dayInMonth = dayInMonth
            self.weekInMonth = nil
        }
        
        init(bymonth: ByMonth, weekInMonth: WeekInMonthPosition?) {
            self.bymonth = bymonth
            self.dayInMonth = nil
            self.weekInMonth = weekInMonth
        }
        
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
            
            return rule
        }
    }
    
    struct WeekInMonthPosition {
        enum WeekPosition: String {
            case first = "1"
            case second = "2"
            case third = "3"
            case fourth = "4"
            case last = "-1"
        }
        
        let week: WeekPosition
        let day: ByDay
    }
    
    enum ByDay: String {
        case sunday = "SU"
        case monday = "MO"
        case tuesday = "TU"
        case wednesday = "WE"
        case thursday = "TH"
        case friday = "FR"
        case saturday = "SA"
    }
    
}

protocol RRuleGenerative {
    var rule: String { get }
}
