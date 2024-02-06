//
//  ActivitiesDataModel.swift
//  harmny.app Watch App
//
//  Created by Roman Rastegaev on 02.01.2024.
//

import Foundation

class ActivitiesViewModel: ObservableObject {
    
    @Published var state = ActivitiesViewModel.State.loading
    
    private let tokenService = TokenService.shared
    private let activityService = HarmonyActivityService.shared
    private let watchConnectivityProvider = WatchConnectivityProvider.shared
    
    init() {
        watchConnectivityProvider.registerReceiveHandler { applicationContext in
            print("Received application context \(applicationContext)")
            self.processTokenData(applicationContext)
        }
        //        UserDefaults.standard.removeObject(forKey: "token")
        //        UserDefaults.standard.removeObject(forKey: "refresh_token")
        self.initialise()
    }
    
    func initialise() {
        self.updateState(.loading)
        tokenService.get() { result in
            switch result {
            case .noToken:
                self.askTokenDataFromIosDevice()
            case .failedToRefreshToken(let error):
                print("Failed to refresh token. Reason: \(error)")
                self.tokenService.clear()
                self.updateState(.unauthenticated)
            case .success(let apiToken):
                self.listActivities(apiToken.token.value)
            }
        }
    }
    
    private func askTokenDataFromIosDevice() {
        guard let session = watchConnectivityProvider.getSession() else {
            print("Failed to obtain WatchConnectivity session.")
            self.updateState(.unauthenticated)
            return
        }
        let message: [String: Any] = ["ping": true]
        print("Sending ping message to iOS device.")
        session.sendMessage(message, replyHandler: { message in
            self.processTokenData(message)
        }, errorHandler: { error in
            print("Failed to send message to iOS device. Reason: \(error)")
            self.updateState(.unauthenticated)
        })
    }
    
    private func processTokenData(_ data: [String: Any]) {
        guard let token = data["token"] as? String,
              let refreshToken = data["refresh_token"] as? String else {
            self.updateState(.unauthenticated)
            return
        }
        
        if (token.isEmpty || refreshToken.isEmpty) {
            self.updateState(.unauthenticated)
        } else {
            let apiToken = self.tokenService.save(token, refreshToken, sendToIos: false)
            if (apiToken != nil) {
                self.listActivities(apiToken!.token.value)
            } else {
                fatalError("Failed to save token into storage.")
            }
        }
    }
    
    private func listActivities(_ token: String) {
        activityService.list(token) { listActivitiesResult in
            switch listActivitiesResult {
            case .success(let activities):
                let observableActivities = activities.map { activity in ActivityObservable.create(from: activity) }
                self.updateState(.loaded(activities: observableActivities))
            case .failure(let error):
                print("Failed to list activities. Reason: \(error)")
                self.updateState(.failedToLoad(errorMessage: "Failed to load activities"))
            }
        }
    }
    
    private func updateState(_ state: ActivitiesViewModel.State) {
        DispatchQueue.main.async { self.state = state }
    }
}

extension ActivitiesViewModel {
    
    enum State {
        case unauthenticated
        case loading
        case failedToLoad(errorMessage: String)
        case loaded(activities: [ActivityObservable])
    }
}
