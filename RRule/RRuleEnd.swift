//
//  RRuleEnd.swift
//  Bzik
//
//  Created by Aran Erlich on 24/08/2023.
//

import Foundation

enum RRuleEnd: RRuleGenerative {
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
    
    init?(_ recurrence: String) {
        let array = recurrence.components(separatedBy: ";")
        self = .never
        
        for item in array {
            let components = item.components(separatedBy: "=")
            guard let first = components.first, let last = components.last else { continue }
            
            if first == "COUNT" {
                if let count = Int(last) {
                    self = .after(count)
                }
            } else if first == "UNTIL" {
                if let stringDate = last.components(separatedBy: "T").first, let date = Date(fromString: stringDate, format: .custom("yyyyMMdd")) {
                    self = .onDate(date)
                }
            }
        }
    }
}
