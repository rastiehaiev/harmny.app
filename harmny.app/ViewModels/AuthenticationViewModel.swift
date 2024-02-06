//
//  AuthenticationViewModel.swift
//  harmny.app
//
//  Created by Roman Rastegaev on 30.12.2023.
//

import SwiftUI
import GoogleSignIn

/// A class conforming to `ObservableObject` used to represent a user's authentication status.
final class AuthenticationViewModel: ObservableObject {
    /// The user's log in status.
    /// - note: This will publish updates when its value changes.
    @Published var state: State = .intermediate(mode: .Initialising)
    
    private let authenticator: GoogleSignInAuthenticator = GoogleSignInAuthenticator()
    private let watchConnectivityProvider = WatchConnectivityProvider.shared
    
    init() {
        watchConnectivityProvider.registerReceiveMessageHandler { session, message in
            let ping = (message["ping"] as? Bool) == true
            if (ping) {
                switch self.state {
                case .signedIn(_, let tokenData):
                    session.sendMessage(tokenData.toDict(), replyHandler: nil)
                default:
                    print("Failed to send token data on Watch device request as not signed in.")
                }
            }
        }
        watchConnectivityProvider.registerReceiveContextHandler { context in
            let isSignOut = (context["signout"] as? Bool) ?? false
            if (isSignOut) {
                print("Received sign-out request from Watch device.")
                self.signOut()
            }
        }
    }
    
    /// Signs the user in.
    func signIn(user: GIDGoogleUser? = nil) {
        var mode: AuthenticationViewModel.IntermediateStateMode = .Initialising
        if (user == nil) {
            mode = .SigningIn
        }
        
        self.state = .intermediate(mode: mode)
        authenticator.signIn(googleUser: user) { result in
            switch result {
            case .success(let state):
                self.updateState(state)
            case .failure(let error):
                print(error)
                self.updateState(.signedOut)
            }
        }
    }
    
    /// Signs the user out.
    func signOut() {
        self.updateState(authenticator.signOut())
    }
    
    /// Disconnects the previously granted scope and logs the user out.
    func disconnect() {
        self.state = .intermediate(mode: .Disconnecting)
        authenticator.disconnect { result in
            switch result {
            case .success(let state):
                self.updateState(state)
            case .failure(let error):
                print(error)
                self.updateState(.signedOut)
            }
        }
    }
    
    private func updateState(_ state: AuthenticationViewModel.State) {
        self.state = state
        switch state {
        case .signedIn(_, let tokenData):
            watchConnectivityProvider.sendTokenData(tokenData)
        case .signedOut:
            watchConnectivityProvider.clearTokenData()
        case .intermediate:
            return
        }
    }
}

extension AuthenticationViewModel {
    /// An enumeration representing logged in status.
    enum State {
        /// The user is logged in and is the associated value of this case.
        case signedIn(googleUser: GIDGoogleUser, tokenData: TokenData)
        /// The user is logged out.
        case signedOut
        case intermediate(mode: IntermediateStateMode)
    }
    
    enum IntermediateStateMode: String {
        case Initialising = "Initialising..."
        case SigningIn = "Signing in..."
        case Disconnecting = "Disconecting..."
    }
}
