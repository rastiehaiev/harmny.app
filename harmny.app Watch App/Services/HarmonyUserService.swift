//
//  HarmonyUserService.swift
//  harmny.app Watch App
//
//  Created by Roman Rastegaev on 03.01.2024.
//

import Foundation

class HarmonyUserService {
    private let url: URL
    
    init() {
        guard let url = URL(string: "https://api.harmny.io/auth") else { fatalError("Failed to create auth endpoint URL.") }
        self.url = url
    }
    
    func refreshToken(_ refreshToken: String, completion: @escaping (Result<TokenData, Error>) -> Void) {
        let refreshTokenUrl = url.appendingPathComponent("refresh-token")
        var request = URLRequest(url: refreshTokenUrl)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let payload: [String: Any] = [
            "token": refreshToken
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: payload, options: [])
        } catch {
            fatalError("Failed to serialise request body.")
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    completion(.failure(HttpError.invalidResponse))
                    return
                }
                
                if (!(200...299).contains(httpResponse.statusCode)) {
                    print(httpResponse.statusCode)
                    print(refreshToken)
                    print(String(data: data!, encoding: .utf8) ?? "???")
                    completion(.failure(HttpError.invalidStatusCode))
                    return
                }
                
                guard let data = data else {
                    completion(.failure(HttpError.emptyResponse))
                    return
                }
                
                do {
                    let apiTokenData = try JSONDecoder().decode(TokenData.self, from: data)
                    completion(.success(apiTokenData))
                } catch (let error) {
                    completion(.failure(error))
                }
            }
        }.resume()
    }
}

extension HarmonyUserService {
    
    enum HttpError: Error {
        case invalidResponse
        case invalidStatusCode
        case emptyResponse
    }
}
