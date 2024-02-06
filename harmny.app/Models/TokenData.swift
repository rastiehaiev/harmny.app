//
//  Wrapper.swift
//  harmny.app
//
//  Created by Roman Rastegaev on 02.01.2024.
//

import Foundation

struct TokenData: Codable {
    var token: String
    var refreshToken: String
    
    enum CodingKeys: String, CodingKey {
        case token, refreshToken = "refresh_token"
    }
    
    func toDict() -> [String: Any] {
        return ["token": self.token, "refresh_token": self.refreshToken]
    }
}
