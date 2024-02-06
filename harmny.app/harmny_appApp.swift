//
//  harmny_appApp.swift
//  harmny.app
//
//  Created by Roman Rastegaev on 30.12.2023.
//

import SwiftUI
import GoogleSignIn

@main
struct harmny_appApp: App {
    @StateObject private var authViewModel = AuthenticationViewModel()
    @StateObject private var connectivityProvider = WatchConnectivityProvider.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authViewModel)
                .environmentObject(connectivityProvider)
                .onAppear {
                    GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
                        if let user = user {
                            self.authViewModel.signIn(user: user)
                        } else if let error = error {
                            self.authViewModel.state = .signedOut
                            print("There was an error restoring the previous sign-in: \(error)")
                        } else {
                            self.authViewModel.state = .signedOut
                        }
                    }
                }
                .onOpenURL { url in
                    GIDSignIn.sharedInstance.handle(url)
                }
        }
    }
}
