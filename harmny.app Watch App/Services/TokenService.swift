//
//  TokenStorage.swift
//  harmny.app Watch App
//
//  Created by Roman Rastegaev on 03.01.2024.
//

import Foundation

class TokenService {
    private let jwtTokenParser = JwtTokenParser()
    private let userDefaults = UserDefaults.standard
    private let harmonyUserService = HarmonyUserService()
    private let watchConnectivityProvider = WatchConnectivityProvider.shared
    
    static let shared = TokenService()
    
    func get(completion: @escaping (TokenService.GetTokenResult) -> Void) {
        guard let token = userDefaults.string(forKey: "token"),
              let tokenExpiration = jwtTokenParser.getExpirationDate(jwtToken: token) else {
            completion(.noToken)
            return
        }
        guard let refreshToken = userDefaults.string(forKey: "refreshToken"),
              let refreshTokenExpiration = jwtTokenParser.getExpirationDate(jwtToken: refreshToken) else {
            completion(.noToken)
            return
        }
        
        let tokenInfo = TokenInfo(value: token, expiration: tokenExpiration)
        let refreshTokenInfo = TokenInfo(value: refreshToken, expiration: refreshTokenExpiration)
        if (!tokenInfo.isExpired()) {
            completion(.success(token: ApiToken(token: tokenInfo, refreshToken: refreshTokenInfo)))
        } else {
            if (refreshTokenInfo.isExpired()) {
                completion(.noToken)
            } else {
                harmonyUserService.refreshToken(refreshToken) { result in
                    switch result {
                    case .success(let tokenData):
                        let apiToken = self.save(tokenData.token, tokenData.refreshToken, sendToIos: true)
                        if (apiToken != nil) {
                            completion(.success(token: apiToken!))
                        } else {
                            fatalError("Failed to save token.")
                        }
                    case .failure(let error):
                        completion(.failedToRefreshToken(error: error))
                    }
                }
            }
        }
    }
    
    func save(_ token: String, _ refreshToken: String, sendToIos: Bool = false) -> ApiToken? {
        guard let tokenExpiration = jwtTokenParser.getExpirationDate(jwtToken: token) else {
            return nil
        }
        
        guard let refreshTokenExpiration = jwtTokenParser.getExpirationDate(jwtToken: refreshToken) else {
            return nil
        }
        
        userDefaults.setValue(token, forKey: "token")
        userDefaults.setValue(refreshToken, forKey: "refreshToken")
        if (sendToIos) {
            watchConnectivityProvider.sendTokenData(TokenData(token: token, refreshToken: refreshToken))
        }
        
        return ApiToken(
            token: TokenInfo(value: token, expiration: tokenExpiration),
            refreshToken: TokenInfo(value: refreshToken, expiration: refreshTokenExpiration)
        )
    }
    
    func clear() {
        userDefaults.removeObject(forKey: "token")
        userDefaults.removeObject(forKey: "refreshToken")
        watchConnectivityProvider.sendSignOutContext()
    }
}

extension TokenService {
    enum GetTokenResult {
        case success(token: ApiToken)
        case failedToRefreshToken(error: Error)
        case noToken
    }
}
