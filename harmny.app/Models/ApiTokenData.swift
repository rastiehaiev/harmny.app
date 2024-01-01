//
//  ApiTokenResponse.swift
//  harmny.app
//
//  Created by Roman Rastegaev on 01.01.2024.
//

import Foundation

struct ApiTokenData: Codable {   
    var token: String
    var refreshToken: String
    
    enum CodingKeys: String, CodingKey {
        case token, refreshToken = "refresh_token"
    }
}
