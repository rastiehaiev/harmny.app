//
//  UserProfileView.swift
//  harmny.app
//
//  Created by Roman Rastegaev on 30.12.2023.
//

import SwiftUI
import GoogleSignIn

struct UserProfileView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    private var user: GIDGoogleUser? {
        return GIDSignIn.sharedInstance.currentUser
    }
    
    var body: some View {
        return Group {
            if let userProfile = user?.profile {
                VStack {
                    HStack {
                        UserProfileImageView(userProfile: userProfile).padding(.leading)
                        VStack(alignment: .leading) {
                            Text(userProfile.name).font(.headline)
                            Text(userProfile.email)
                        }
                    }
                    Spacer()
                }
                .toolbar {
                    ToolbarItemGroup(placement: .navigationBarTrailing) {
                        Button(NSLocalizedString("Disconnect", comment: "Disconnect"), action: disconnect)
                        Button(NSLocalizedString("Sign Out", comment: "Sign Out"), action: signOut)
                    }
                }
            } else {
                Text(NSLocalizedString("Failed to get user profile!", comment: "Empty user profile text"))
            }
        }
    }
    
    private func disconnect() {
        authViewModel.disconnect()
    }
    
    private func signOut() {
        authViewModel.signOut()
    }
}
