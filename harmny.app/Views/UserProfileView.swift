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
        if let userProfile = user?.profile {
            VStack {
                HStack {
                    UserProfileImageView(userProfile: userProfile)
                        .padding(.leading, 15)
                    VStack(alignment: .leading) {
                        Text(userProfile.name)
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text(userProfile.email)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(.leading, 5)
                    .frame(maxWidth: .infinity)
                }
                .frame(maxWidth: .infinity)
                HStack {
                    Text("You've successfully signed in! You can use your Apple Watch device now for managing your activities.")
                }
                .padding(20)
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button(NSLocalizedString("Disconnect", comment: "Disconnect"), action: disconnect)
                    Button(NSLocalizedString("Sign Out", comment: "Sign Out"), action: signOut)
                }
            }
        } else {
            VStack {
                Text(NSLocalizedString("Failed to get user profile!", comment: "Empty user profile text"))
            }
        }
        //        if let userProfile = user?.profile {
        //            VStack {
        //                HStack {
        //                    UserProfileImageView(userProfile: userProfile)
        //                    VStack(alignment: .leading) {
        //                        Text(userProfile.name).font(.headline)
        //                        Text(userProfile.email)
        //                    }
        //                    .frame(maxWidth: .infinity)
        //                    .border(Color.black, width: 1)
        //                }
        //                Spacer()
        //            }
        //        } else {
        //            VStack {
        //                Text(NSLocalizedString("Failed to get user profile!", comment: "Empty user profile text"))
        //            }
        //        }
    }
    
    //    var body: some View {
    //        if let userProfile = user?.profile {
    //            VStack(alignment: .leading) {
    //                HStack {
    //                    UserProfileImageView(userProfile: userProfile)
    //                    VStack {
    //                        Text(userProfile.name).font(.headline)
    //                        Text(userProfile.email)
    //                    }
    //                }
    //                Spacer()
    //            }
    //            .frame(maxWidth: .infinity)
    //            .toolbar {
    //                ToolbarItemGroup(placement: .navigationBarTrailing) {
    //                    Button(NSLocalizedString("Disconnect", comment: "Disconnect"), action: disconnect)
    //                    Button(NSLocalizedString("Sign Out", comment: "Sign Out"), action: signOut)
    //                }
    //            }
    //        } else {
    //            VStack {
    //                Text(NSLocalizedString("Failed to get user profile!", comment: "Empty user profile text"))
    //            }
    //        }
    //    }
    
    private func disconnect() {
        authViewModel.disconnect()
    }
    
    private func signOut() {
        authViewModel.signOut()
    }
}
