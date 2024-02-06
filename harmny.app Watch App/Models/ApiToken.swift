//
//  ApiToken.swift
//  harmny.app Watch App
//
//  Created by Roman Rastegaev on 03.01.2024.
//

import Foundation

struct ApiToken {
    let token: TokenInfo
    let refreshToken: TokenInfo
}

struct TokenInfo {
    let value: String
    let expiration: Date
    
    func isExpired() -> Bool {
        return expiration < Date().addingTimeInterval(60)
    }
}
