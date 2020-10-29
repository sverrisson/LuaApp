//
//  Utilities.swift
//  LuaApp
//
//  Created by Hannes Sverrisson on 29/10/2020.
//

import Foundation

struct RunTimer: CustomStringConvertible {
    var begin: CFAbsoluteTime
    var end: CFAbsoluteTime
    
    init() {
        begin = CFAbsoluteTimeGetCurrent()
        end = 0
    }
    
    mutating func start() {
        begin = CFAbsoluteTimeGetCurrent()
        end = 0
    }
    
    @discardableResult
    mutating func stop() -> Double {
        if (end == 0) { end = CFAbsoluteTimeGetCurrent() }
        return Double(end - begin)
    }
    
    var duration: CFAbsoluteTime {
        get {
            if (end == 0) { return CFAbsoluteTimeGetCurrent() - begin }
            else { return end - begin }
        }
    }
    var description: String {
        let time = duration
        if (time > 100) {return " \(time/60) min"}
        else if (time < 1e-6) {return " \(time*1e9) ns"}
        else if (time < 1e-3) {return " \(time*1e6) µs"}
        else if (time < 1) {return " \(time*1000) ms"}
        else {return " \(time) s"}
    }
}
