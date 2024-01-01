//
//  ContentView.swift
//  harmny.app
//
//  Created by Roman Rastegaev on 30.12.2023.
//

import SwiftUI
import GoogleSignIn

struct ContentView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    
    var body: some View {
        return NavigationView {
            switch authViewModel.state {
            case .signedIn:
                UserProfileView()
            case .signedOut:
                SignInView()
//                    .navigationTitle(
//                        NSLocalizedString(
//                            "Sign-in",
//                            comment: "Sign-in navigation title"
//                        ))
            case .intermediate(let mode):
                Text(mode.rawValue)
            }
        }
        //.navigationViewStyle(StackNavigationViewStyle())
    }
}
