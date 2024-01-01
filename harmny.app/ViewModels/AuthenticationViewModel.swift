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
    
    private var authenticator: GoogleSignInAuthenticator = GoogleSignInAuthenticator()
    
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
                self.state = state
            case .failure(let error):
                print(error)
                self.state = .signedOut
            }
        }
    }
    
    /// Signs the user out.
    func signOut() {
        self.state = authenticator.signOut()
    }
    
    /// Disconnects the previously granted scope and logs the user out.
    func disconnect() {
        self.state = .intermediate(mode: .Disconnecting)
        authenticator.disconnect { result in
            switch result {
            case .success(let state):
                self.state = state
            case .failure(let error):
                print(error)
                self.state = .signedOut
            }
        }
    }
    
}

extension AuthenticationViewModel {
    /// An enumeration representing logged in status.
    enum State {
        /// The user is logged in and is the associated value of this case.
        case signedIn(googleUser: GIDGoogleUser, apiTokenData: ApiTokenData)
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
