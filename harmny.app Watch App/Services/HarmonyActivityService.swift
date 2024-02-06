//
//  HarmonyActivitiesService.swift
//  harmny.app Watch App
//
//  Created by Roman Rastegaev on 03.01.2024.
//

import Foundation

class HarmonyActivityService {
    
    static let shared = HarmonyActivityService()
    
    private let url: URL
    
    init() {
        guard let url = URL(string: "https://api.harmny.io/activities") else { fatalError("Failed to create activities endpoint URL.") }
        self.url = url
    }
    
    func list(_ token: String, completion: @escaping (Result<[Activity], Error>) -> Void) {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
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
                    completion(.failure(HttpError.invalidStatusCode))
                    return
                }
                
                guard let data = data else {
                    completion(.success([Activity]()))
                    return
                }
                
                do {
                    let activities = try JSONDecoder().decode([Activity].self, from: data)
                    completion(.success(activities))
                } catch (let error) {
                    completion(.failure(error))
                }
            }
        }.resume()
    }
    
    func get(_ token: String, _ activityId: String, completion: @escaping (Result<ActivityDetails, Error>) -> Void) {
        let activityDetailsUrl = url.appendingPathComponent(activityId)
        
        var request = URLRequest(url: activityDetailsUrl)
        request.httpMethod = "GET"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
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
                    print(request)
                    print(httpResponse.statusCode)
                    completion(.failure(HttpError.invalidStatusCode))
                    return
                }
                
                guard let data = data else {
                    completion(.failure(HttpError.invalidResponse))
                    return
                }
                
                do {
                    let activityDetails = try JSONDecoder().decode(ActivityDetails.self, from: data)
                    completion(.success(activityDetails))
                } catch (let error) {
                    completion(.failure(error))
                }
            }
        }.resume()
    }
    
    func createRepetition(_ token: String, activityId: String, completion: @escaping (Result<ActivityRepetition, Error>) -> Void) {
        print("Creating activity repetition.")
        
        let targetUrl = url.appendingPathComponent(activityId)
            .appendingPathComponent("repetitions")
        
        var request = URLRequest(url: targetUrl)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let payload: [String: Any] = ["started": true]
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
                    print(request)
                    print(httpResponse.statusCode)
                    completion(.failure(HttpError.invalidStatusCode))
                    return
                }
                
                guard let data = data else {
                    completion(.failure(HttpError.invalidResponse))
                    return
                }
                
                do {
                    let activityRepetition = try JSONDecoder().decode(ActivityRepetition.self, from: data)
                    completion(.success(activityRepetition))
                } catch (let error) {
                    completion(.failure(error))
                }
            }
        }.resume()
    }
    
    func startRepetition(
        _ token: String,
        activityId: String,
        activityRepetitionId: String,
        count: Int?,
        completion: @escaping (Result<ActivityRepetition, Error>) -> Void
    ) {
        print("Starting activity repetition.")
        let targetUrl = url.appendingPathComponent(activityId)
            .appendingPathComponent("repetitions")
            .appendingPathComponent(activityRepetitionId)
            .appendingPathComponent("start")
        
        var request = URLRequest(url: targetUrl)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let payload: [String: Any] = if count != nil { ["count": count!] } else {[:]}
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
                    print(request)
                    print(httpResponse.statusCode)
                    completion(.failure(HttpError.invalidStatusCode))
                    return
                }
                
                guard let data = data else {
                    completion(.failure(HttpError.invalidResponse))
                    return
                }
                
                do {
                    let activityRepetition = try JSONDecoder().decode(ActivityRepetition.self, from: data)
                    completion(.success(activityRepetition))
                } catch (let error) {
                    completion(.failure(error))
                }
            }
        }.resume()
    }
    
    func pauseRepetition(
        _ token: String,
        activityId: String,
        activityRepetitionId: String,
        completion: @escaping (Result<ActivityRepetition, Error>) -> Void
    ) {
        print("Pausing activity repetition.")
        
        let targetUrl = url.appendingPathComponent(activityId)
            .appendingPathComponent("repetitions")
            .appendingPathComponent(activityRepetitionId)
            .appendingPathComponent("pause")
        
        var request = URLRequest(url: targetUrl)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let payload: [String: Any] = [:]
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
                    print(request)
                    print(httpResponse.statusCode)
                    completion(.failure(HttpError.invalidStatusCode))
                    return
                }
                
                guard let data = data else {
                    completion(.failure(HttpError.invalidResponse))
                    return
                }
                
                do {
                    let activityRepetition = try JSONDecoder().decode(ActivityRepetition.self, from: data)
                    completion(.success(activityRepetition))
                } catch (let error) {
                    completion(.failure(error))
                }
            }
        }.resume()
    }
    
    func deleteRepetition(
        _ token: String,
        activityId: String,
        activityRepetitionId: String,
        completion: @escaping (Result<ActivityRepetition, Error>) -> Void
    ) {
        print("Deleting activity repetition.")
        
        let targetUrl = url.appendingPathComponent(activityId)
            .appendingPathComponent("repetitions")
            .appendingPathComponent(activityRepetitionId)
        
        var request = URLRequest(url: targetUrl)
        request.httpMethod = "DELETE"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
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
                    print(request)
                    print(httpResponse.statusCode)
                    completion(.failure(HttpError.invalidStatusCode))
                    return
                }
                
                guard let data = data else {
                    completion(.failure(HttpError.invalidResponse))
                    return
                }
                
                do {
                    let activityRepetition = try JSONDecoder().decode(ActivityRepetition.self, from: data)
                    completion(.success(activityRepetition))
                } catch (let error) {
                    completion(.failure(error))
                }
            }
        }.resume()
    }
    
    func completeRepetition(
        _ token: String,
        activityId: String,
        activityRepetitionId: String,
        count: Int?,
        completion: @escaping (Result<ActivityRepetition, Error>) -> Void
    ) {
        print("Completing activity repetition.")
        
        let targetUrl = url.appendingPathComponent(activityId)
            .appendingPathComponent("repetitions")
            .appendingPathComponent(activityRepetitionId)
        
        var request = URLRequest(url: targetUrl)
        request.httpMethod = "PUT"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let payload: [String: Any] = if count != nil {
            ["completed": true, "count": count!]
        } else {
            ["completed": true]
        }
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
                    print(request)
                    print(httpResponse.statusCode)
                    completion(.failure(HttpError.invalidStatusCode))
                    return
                }
                
                guard let data = data else {
                    completion(.failure(HttpError.invalidResponse))
                    return
                }
                
                do {
                    let activityRepetition = try JSONDecoder().decode(ActivityRepetition.self, from: data)
                    completion(.success(activityRepetition))
                } catch (let error) {
                    completion(.failure(error))
                }
            }
        }.resume()
    }
}

extension HarmonyActivityService {
    
    enum HttpError: Error {
        case invalidResponse
        case invalidStatusCode
    }
}
