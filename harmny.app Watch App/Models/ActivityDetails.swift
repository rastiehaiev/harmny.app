//
//  ActivityDetails.swift
//  harmny.app Watch App
//
//  Created by Roman Rastegaev on 04.01.2024.
//

import Foundation

struct ActivityDetails: Codable, Identifiable {
    var id: String
    var name: String
    var group: Bool
    var currentRepetition: ActivityRepetition?
    
    enum CodingKeys: String, CodingKey {
        case id, name, group, currentRepetition = "current_repetition"
    }
}

struct ActivityRepetition: Codable, Identifiable {
    var id: String
    var count: Int?
    var lastStartedAt: String?
    var timeSpentMs: Int32?
    var started: Bool?
    var completed: Bool?
    
    enum CodingKeys: String, CodingKey {
        case id, count, lastStartedAt = "last_started_at", timeSpentMs = "time_spent_ms", started, completed
    }
}
