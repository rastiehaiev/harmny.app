//
//  ActivityStopwatchInfo.swift
//  harmny.app Watch App
//
//  Created by Roman Rastegaev on 05.01.2024.
//

import Foundation

struct ActivityStopwatchInfo {
    let status: Status
    let count: Int?
    let elapsedTimeSec: Int32
    
    private init(_ status: Status, _ count: Int?, _ elapsedTimeSec: Int32) {
        self.status = status
        self.count = count
        self.elapsedTimeSec = elapsedTimeSec
    }
    
    static func from(_ repetition: ActivityRepetition?) -> ActivityStopwatchInfo {
        if (repetition == nil || repetition!.completed == true) {
            return ActivityStopwatchInfo(.unstarted, 0, 0)
        }
        
        let status: ActivityStopwatchInfo.Status = if (repetition!.started == true) {
            .started
        } else {
            .paused
        }
        
        var elapsedTimeMs = repetition!.timeSpentMs ?? 0
        if (status == .started) {
            let lastStartedAtString = repetition!.lastStartedAt
            if (lastStartedAtString != nil) {
                let lastStartedAt = DateUtils.parse(lastStartedAtString!)
                if (lastStartedAt != nil) {
                    let timeDifferenceSec = Date().timeIntervalSince(lastStartedAt!)
                    let timeDifferenceMs = Int32(timeDifferenceSec * 1000)
                    elapsedTimeMs += timeDifferenceMs
                }
            }
        }
        return ActivityStopwatchInfo(status, repetition?.count, elapsedTimeMs / 1000)
    }
}

extension ActivityStopwatchInfo {
    enum Status {
        case unstarted
        case started
        case paused
    }
}
