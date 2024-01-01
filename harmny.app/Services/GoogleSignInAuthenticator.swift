//
//  GoogleSignInAuthenticator.swift
//  harmny.app
//
//  Created by Roman Rastegaev on 30.12.2023.
//

import Foundation
import GoogleSignIn

/// An observable class for authenticating via Google.
final class GoogleSignInAuthenticator: ObservableObject {
    
    /// Signs in the user based upon the selected account.'
    /// - note: Successful calls to this will set the `authViewModel`'s `state` property.
    func signIn(googleUser: GIDGoogleUser?, completion: @escaping (Result<AuthenticationViewModel.State, Error>) -> Void) {
        let handleUserAndTokenDataResult: (GIDGoogleUser, Result<ApiTokenData, Error>) -> Void = { user, result in
            switch result {
            case .success(let tokenData):
                let state = AuthenticationViewModel.State.signedIn(googleUser: user, apiTokenData: tokenData)
                completion(.success(state))
            case .failure(let error):
                completion(.failure(error))
            }
        }
        
        if (googleUser == nil) {
            signIn { result in
                switch result {
                case .success(let user):
                    self.exchangeIdTokenToApiAccessToken(idToken: user.idToken!.tokenString) { result in
                        handleUserAndTokenDataResult(user, result)
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        } else {
            self.exchangeIdTokenToApiAccessToken(idToken: googleUser!.idToken!.tokenString) { result in
                handleUserAndTokenDataResult(googleUser!, result)
            }
        }
    }
    
    /// Signs out the current user.
    func signOut() -> AuthenticationViewModel.State {
        GIDSignIn.sharedInstance.signOut()
        return AuthenticationViewModel.State.signedOut
    }
    
    /// Disconnects the previously granted scope and signs the user out.
    func disconnect(completion: @escaping (Result<AuthenticationViewModel.State, Error>) -> Void) {
        GIDSignIn.sharedInstance.disconnect { error in
            if let error = error {
                print("Encountered error disconnecting scope: \(error).")
            }
            completion(.success(self.signOut()))
        }
    }
    
    private func signIn(completion: @escaping (Result<GIDGoogleUser, Error>) -> Void) {
        guard let rootViewController = UIApplication.shared.keyWindowPresentedController else {
            fatalError("No root view controller!")
        }
        
        GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { signInResult, error in
            guard let signInResult = signInResult else {
                completion(.failure(error!))
                return
            }
            completion(.success(signInResult.user))
        }
    }
    
    private func exchangeIdTokenToApiAccessToken(idToken: String, completion: @escaping (Result<ApiTokenData, Error>) -> Void) {
        guard let url = URL(string: "https://api.harmny.io/auth/ios") else {
            completion(.failure(URLError(.badURL)))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let payload: [String: Any] = [
            "id_token": idToken
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: payload, options: [])
        } catch {
            completion(.failure(URLError(URLError.Code.cannotParseResponse)))
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    completion(.failure(URLError(.badServerResponse)))
                    return
                }
                
                if !(200...299).contains(httpResponse.statusCode) {
                    completion(.failure(URLError(.badServerResponse)))
                    return
                }
                
                guard let data = data else {
                    completion(.failure(URLError(.badServerResponse)))
                    return
                }
                
                do {
                    let apiTokenData = try JSONDecoder().decode(ApiTokenData.self, from: data)
                    completion(.success(apiTokenData))
                } catch {
                    completion(.failure(URLError(.badServerResponse)))
                    return
                }
            }
        }.resume()
    }
}
