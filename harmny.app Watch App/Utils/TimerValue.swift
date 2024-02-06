//
//  TimerValue.swift
//  harmny.app Watch App
//
//  Created by Roman Rastegaev on 05.01.2024.
//

import Foundation

class TimerValue {
    private var hours: Int32 = 0
    private var minutes: Int32 = 0
    private var seconds: Int32 = 0
    
    var stringValue: String
    
    static func from(_ elapsedTime: Int32) -> TimerValue {
        let hours = elapsedTime / 3600
        let minutes = (elapsedTime % 3600) / 60
        let seconds = elapsedTime % 60
        let stringValue = compute(hours, minutes, seconds)
        return TimerValue(hours, minutes, seconds, stringValue)
    }
    
    private static func compute(_ hours: Int32, _ minutes: Int32, _ seconds: Int32) -> String {
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    
    private init(_ hours: Int32, _ minutes: Int32, _ seconds: Int32, _ stringValue: String) {
        self.hours = hours
        self.minutes = minutes
        self.seconds = seconds
        self.stringValue = stringValue
    }
    
    func incrementAndGet() -> String {
        var newSeconds = seconds + 1
        var newMinutes = minutes
        var newHours = hours
        if (newSeconds == 60) {
            newSeconds = 0
            newMinutes += 1
            if (newMinutes == 60) {
                newMinutes = 0
                newHours += 1
            }
        }
        
        self.hours = newHours
        self.minutes = newMinutes
        self.seconds = newSeconds
        self.stringValue = TimerValue.compute(newHours, newMinutes, newSeconds)
        return self.stringValue
    }
}
