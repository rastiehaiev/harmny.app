//
//  UserProfileImageLoader.swift
//  harmny.app
//
//  Created by Roman Rastegaev on 30.12.2023.
//

import Combine
import SwiftUI
import GoogleSignIn

/// An observable class for loading the current user's profile image.
final class UserProfileImageLoader: ObservableObject {
    private let userProfile: GIDProfileData
    private let imageLoaderQueue = DispatchQueue(label: "com.google.loader.image")
    /// A `UIImage` property containing the current user's profile image.
    /// - note: This will default to a placeholder, and updates will be published to subscribers.
    @Published var image = UIImage(named: "PlaceholderAvatar")!
    
    /// Creates an instance of this loader with provided user profile.
    /// - note: The instance will asynchronously fetch the image data upon creation.
    init(userProfile: GIDProfileData) {
        self.userProfile = userProfile
        guard userProfile.hasImage else {
            return
        }
        
        imageLoaderQueue.async {
            let dimension = 45 * UIScreen.main.scale
            guard let url = userProfile.imageURL(withDimension: UInt(dimension)),
                  let data = try? Data(contentsOf: url),
                  let image = UIImage(data: data) else {
                return
            }
            DispatchQueue.main.async {
                self.image = image
            }
        }
    }
}
