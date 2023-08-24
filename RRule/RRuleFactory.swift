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

protocol RRuleGenerative {
    var rule: String { get }
}

struct RRuleFactory {
    
    private let freq: RRuleFrequency
    private let end: RRuleEnd
    
    init(freq: RRuleFrequency, end: RRuleEnd) {
        self.freq = freq
        self.end = end
    }
    
    init?(_ recurrence: [String], start: Date) {
        // TZID = time zone id
        let reduced = recurrence.reduce("") { partialResult, value in
            var temp = ""
            let split = value.components(separatedBy: ":")
            if let first = split.first, let last = split.last, first == "RRULE" {
                temp = last
            }
            
            return temp
        }
        guard let frequency = RRuleFrequency(reduced, start: start), let e = RRuleEnd(reduced) else { return nil }
        freq = frequency
        end = e
    }
    
    var rrule: String? {
        var rrule: String = "RRULE:"
        rrule += freq.rule
        switch freq {
        case .daily(let ruleGenerative), .weekly(let ruleGenerative), .monthly(let ruleGenerative), .yearly(let ruleGenerative):
            rrule += ruleGenerative.rule
        }
        rrule += end.rule
        
        return rrule
    }
    
}

struct RRuleWeekInMonthPosition {
    enum WeekPosition: String {
        case first = "1"
        case second = "2"
        case third = "3"
        case fourth = "4"
        case last = "-1"
    }
    
    let week: WeekPosition
    let day: RRuleByDay
}

enum RRuleByDay: String {
    case sunday = "SU"
    case monday = "MO"
    case tuesday = "TU"
    case wednesday = "WE"
    case thursday = "TH"
    case friday = "FR"
    case saturday = "SA"
}
