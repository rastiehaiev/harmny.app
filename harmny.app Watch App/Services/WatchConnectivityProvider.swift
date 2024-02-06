//
//  WatchConnectivityProvider.swift
//  harmny.app Watch App
//
//  Created by Roman Rastegaev on 02.01.2024.
//

import SwiftUI
import WatchConnectivity

class WatchConnectivityProvider: NSObject, WCSessionDelegate, ObservableObject {
    
    static let shared = WatchConnectivityProvider()
    
    private var receiveHandlers = [([String : Any]) -> Void]()
    
    override init() {
        super.init()
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
    }
    
    func sendTokenData(_ tokenData: TokenData) {
        guard let session = getSession() else { return }
        do {
            try session.updateApplicationContext(tokenData.toDict())
        } catch let error {
            print("Failed to send data to iOS device. Reason: \(error)")
        }
    }
    
    func sendSignOutContext() {
        guard let session = getSession() else { return }
        do {
            try session.updateApplicationContext(["signout": true])
        } catch let error {
            print("Failed to send data to iOS device. Reason: \(error)")
        }
    }
    
    func registerReceiveHandler(receiveHandler: @escaping ([String: Any]) -> Void) {
        receiveHandlers.append(receiveHandler)
    }
    
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        DispatchQueue.main.async { [weak self] in
            self?.receiveHandlers.forEach { receiveHandler in
                receiveHandler(applicationContext)
            }
        }
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if error != nil {
            print("[watch] Error: \(String(describing: error)).")
        }
    }
    
    func getSession() -> WCSession? {
        if WCSession.isSupported() {
            return WCSession.default
        }
        return nil
    }
}
