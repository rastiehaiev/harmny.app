//
//  Activity.swift
//  harmny.app Watch App
//
//  Created by Roman Rastegaev on 02.01.2024.
//

import Foundation

struct Activity: Codable, Identifiable {
    var id: String
    var name: String
    var group: Bool
    var currentRepetitionId: String?
    var childActivities: [Activity]?
    
    enum CodingKeys: String, CodingKey {
        case id, name, group, childActivities = "child_activities", currentRepetitionId = "current_repetition_id"
    }
}
