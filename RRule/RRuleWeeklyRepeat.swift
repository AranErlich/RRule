//
//  RRuleWeeklyRepeat.swift
//  Bzik
//
//  Created by Aran Erlich on 24/08/2023.
//

import Foundation

struct RRuleWeeklyRepeat: RRuleGenerative {
    var repeatEvery: Int
    var byday: [RRuleByDay]
    
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
    
    init(repeatEvery: Int, byday: [RRuleByDay]) {
        self.repeatEvery = repeatEvery
        self.byday = byday
    }
    
    init(_ value: [String], start: Date) {
        repeatEvery = 1
        let weekday = String(start.toString(style: .weekday).prefix(2)).uppercased()
        let day = RRuleByDay(rawValue: weekday) ?? .sunday
        byday = [day]
        
        for item in value {
            let components = item.components(separatedBy: "=")
            guard let first = components.first, let last = components.last else { continue }
            
            if first == "INTERVAL" {
                guard let intValue = Int(last) else { continue }
                repeatEvery = intValue
            } else if first == "BYDAY" {
                let days = last.components(separatedBy: ",")
                var daysArray: [RRuleByDay] = []
                days.forEach({ daysArray.append(RRuleByDay(rawValue: $0) ?? .sunday) })
                byday = daysArray
            }
        }
    }
}
