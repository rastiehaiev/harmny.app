//
//  ActivityObservable.swift
//  harmny.app Watch App
//
//  Created by Roman Rastegaev on 07.01.2024.
//

import Foundation

class ActivityObservable: ObservableObject {
    var id: String
    var name: String
    var group: Bool
    var currentRepetitionId: String?
    var childActivities: [ActivityObservable]?
    
    static func create(from: Activity) -> ActivityObservable {
        return ActivityObservable(
            id: from.id,
            name: from.name,
            group: from.group,
            currentRepetitionId: from.currentRepetitionId,
            childActivities: from.childActivities?.map { activity in ActivityObservable.create(from: activity) }
        )
    }
    
    private init(
        id: String,
        name: String,
        group: Bool,
        currentRepetitionId: String? = nil,
        childActivities: [ActivityObservable]? = nil
    ) {
        self.id = id
        self.name = name
        self.group = group
        self.currentRepetitionId = currentRepetitionId
        self.childActivities = childActivities
    }
}
