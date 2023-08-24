//
//  RRuleDailyRepeat.swift
//  Bzik
//
//  Created by Aran Erlich on 24/08/2023.
//

import Foundation

struct RRuleDailyRepeat: RRuleGenerative {
    let every: Int
    
    var rule: String {
        "INTERVAL=\(every)"
    }
    
    init(every: Int) {
        self.every = every
    }
    
    init(_ value: [String]) {
        let reduced = value.reduce(1) { partialResult, value in
            var temp = partialResult
            let components = value.components(separatedBy: "=")
            if let first = components.first, let last = components.last, first == "INTERVAL", let intValue = Int(last) {
                temp = intValue
            }
            
            return temp
        }
        
        every = reduced
    }
}
