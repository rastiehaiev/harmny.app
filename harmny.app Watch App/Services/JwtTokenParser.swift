//
//  JwtTokenParser.swift
//  harmny.app Watch App
//
//  Created by Roman Rastegaev on 03.01.2024.
//

import Foundation

class JwtTokenParser {
    
    func getExpirationDate(jwtToken: String) -> Date? {
        let segments = jwtToken.components(separatedBy: ".")
        guard segments.count == 3,
              let payloadData = base64UrlDecode(segments[1]),
              let payloadString = String(data: payloadData, encoding: .utf8),
              let data = payloadString.data(using: .utf8) else {
            return nil
        }
        
        do {
            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
               let expTimestamp = json["exp"] as? TimeInterval {
                return Date(timeIntervalSince1970: expTimestamp)
            }
        } catch {
            print("Error decoding JWT: \(error)")
        }
        return nil
    }
    
    private func base64UrlDecode(_ value: String) -> Data? {
        var base64 = value
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        
        let length = Double(base64.lengthOfBytes(using: String.Encoding.utf8))
        let requiredLength = 4 * ceil(length / 4.0)
        let paddingLength = requiredLength - length
        if paddingLength > 0 {
            let padding = "".padding(toLength: Int(paddingLength), withPad: "=", startingAt: 0)
            base64 += padding
        }
        
        return Data(base64Encoded: base64)
    }
}
