//
//  ActivityViewModel.swift
//  harmny.app Watch App
//
//  Created by Roman Rastegaev on 04.01.2024.
//

import Foundation

class ActivityViewModel: ObservableObject {
    
    @Published var state = ActivityViewModel.State.loading
    
    private var activity: ActivityObservable
    private let tokenService = TokenService.shared
    private let activityService = HarmonyActivityService.shared
    
    init(_ activity: ActivityObservable) {
        self.activity = activity
        self.state = .loading
        self.loadActivity()
    }
    
    func startOrResume(_ count: Int?) {
        let completion: (Result<ActivityRepetition, Error>) -> Void = { result in
            switch result {
            case .failure(let error):
                print("Failed to start activity. Reason: \(error)")
                self.updateState(.failedToLoad)
            case .success(let activityRepetition):
                self.updateStateFromRepetition(activityRepetition)
                if (self.activity.currentRepetitionId == nil) {
                    self.activity.currentRepetitionId = activityRepetition.id
                }
            }
        }
        
        withToken { token in
            if (self.activity.currentRepetitionId != nil) {
                self.activityService.startRepetition(
                    token,
                    activityId: self.activity.id,
                    activityRepetitionId: self.activity.currentRepetitionId!,
                    count: count,
                    completion: completion
                )
            } else {
                self.activityService.createRepetition(
                    token,
                    activityId: self.activity.id,
                    completion: completion
                )
            }
        }
    }
    
    func pause() {
        withToken { token in
            self.activityService.pauseRepetition(
                token,
                activityId: self.activity.id,
                activityRepetitionId: self.activity.currentRepetitionId!
            ) { result in
                switch result {
                case .failure(let error):
                    print("Failed to pause activity. Reason: \(error)")
                    self.updateState(.failedToLoad)
                case .success(let activityRepetition):
                    self.updateStateFromRepetition(activityRepetition)
                }
            }
        }
    }
    
    func delete() {
        withToken { token in
            self.activityService.deleteRepetition(
                token,
                activityId: self.activity.id,
                activityRepetitionId: self.activity.currentRepetitionId!
            ) { result in
                switch result {
                case .failure(let error):
                    print("Failed to delete activity. Reason: \(error)")
                    self.updateState(.failedToLoad)
                case .success:
                    self.activity.currentRepetitionId = nil
                    self.updateStateFromRepetition(nil)
                }
            }
        }
    }
    
    func complete(_ count: Int?) {
        withToken { token in
            self.activityService.completeRepetition(
                token,
                activityId: self.activity.id,
                activityRepetitionId: self.activity.currentRepetitionId!,
                count: count
            ) { result in
                switch result {
                case .failure(let error):
                    print("Failed to complete activity. Reason: \(error)")
                    self.updateState(.failedToLoad)
                case .success:
                    self.activity.currentRepetitionId = nil
                    self.updateStateFromRepetition(nil)
                }
            }
        }
    }
    
    private func loadActivity() {
        self.updateState(.loading)
        withToken { token in
            // Get activity first and check its current repetition ID
            self.activityService.get(token, self.activity.id) { result in
                switch result {
                case .failure(let error):
                    print("Failed to load activity. Reason: \(error)")
                    self.updateState(.failedToLoad)
                case .success(let activityDetails):
                    let activityRepetition = activityDetails.currentRepetition
                    self.updateStateFromRepetition(activityRepetition)
                }
            }
        }
    }
    
    private func withToken(completion: @escaping (String) -> Void) {
        tokenService.get { result in
            switch result {
            case .noToken:
                fallthrough
            case .failedToRefreshToken:
                self.updateState(.unauthenticated)
            case .success(let apiToken):
                let token = apiToken.token.value
                completion(token)
            }
        }
    }
    
    private func updateStateFromRepetition(_ activityRepetition: ActivityRepetition?) {
        self.updateState(.loaded(ActivityStopwatchInfo.from(activityRepetition)))
    }
    
    private func updateState(_ state: ActivityViewModel.State) {
        DispatchQueue.main.async { self.state = state }
    }
}

extension ActivityViewModel {
    
    enum State: Equatable {
        
        static func == (lhs: ActivityViewModel.State, rhs: ActivityViewModel.State) -> Bool {
            switch (lhs, rhs) {
            case (.loading, .loading), (.failedToLoad, .failedToLoad), (.unauthenticated, .unauthenticated):
                return true
            default:
                // TODO: implement later if needed
                return false
            }
        }
        
        case loading
        case failedToLoad
        case loaded(ActivityStopwatchInfo)
        case unauthenticated
    }
}
