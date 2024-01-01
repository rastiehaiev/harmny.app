//
//  SignInView.swift
//  harmny.app
//
//  Created by Roman Rastegaev on 30.12.2023.
//

import SwiftUI
import GoogleSignInSwift

struct SignInView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @ObservedObject var vm = GoogleSignInButtonViewModel(
        scheme: GoogleSignInButtonColorScheme.dark,
        style: GoogleSignInButtonStyle.wide
    )
    
    var body: some View {
        VStack {
            HStack {
                VStack {
                    GoogleSignInButton(viewModel: vm, action: self.signIn)
                        .accessibilityIdentifier("GoogleSignInButton")
                        .accessibility(hint: Text("Sign in with Google."))
                        .padding()
                        .pickerStyle(.segmented)
                }
            }
            Spacer()
        }
    }
    
    private func signIn() {
        authViewModel.signIn()
    }
}
