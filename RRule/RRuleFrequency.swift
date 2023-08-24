//
//  RRuleFrequency.swift
//  Bzik
//
//  Created by Aran Erlich on 24/08/2023.
//

import Foundation

enum RRuleFrequency: RRuleGenerative {
    /// 1-999 days, use CycleRepeat
    case daily(RRuleGenerative)
    /// use WeeklyRepeat object
    case weekly(RRuleGenerative)
    /// use MonthlyRepeat object
    case monthly(RRuleGenerative)
    /// use YearlyRepeat object
    case yearly(RRuleGenerative)
    
    var rawValue: String {
        switch self {
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
    
    init?(_ rawValue: String, start: Date) {
        let array = rawValue.components(separatedBy: ";")
        guard let frequency = array.first, let type = frequency.components(separatedBy: "=").last else { return nil }
        
        
        switch type {
        case "DAILY":
            let repeatRule = RRuleDailyRepeat(array)
            self = .daily(repeatRule)
        case "WEEKLY":
            let repeatRule = RRuleWeeklyRepeat(array, start: start)
            self = .weekly(repeatRule)
        case "MONTHLY":
            let repeatRule = RRuleMonthlyRepeat(array, start: start)
            self = .monthly(repeatRule)
        case "YEARLY":
            let repeatRule = RRuleYearlyRepeat(array, start: start)
            self = .yearly(repeatRule)
        default:
            return nil
        }
    }
}
