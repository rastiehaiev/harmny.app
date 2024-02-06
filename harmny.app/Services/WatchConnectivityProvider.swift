//
//  WatchConnectivityProvider.swift
//  harmny.app
//
//  Created by Roman Rastegaev on 02.01.2024.
//

import WatchConnectivity

class WatchConnectivityProvider: NSObject, WCSessionDelegate, ObservableObject {
    
    static let shared = WatchConnectivityProvider()
    
    private var receiveContextHandlers = [([String : Any]) -> Void]()
    private var receiveMessageHandlers = [(WCSession, [String : Any]) -> Void]()
    
    func registerReceiveContextHandler(receiveContextHandler: @escaping ([String: Any]) -> Void) {
        receiveContextHandlers.append(receiveContextHandler)
    }
    
    func registerReceiveMessageHandler(receiveMessageHandler: @escaping (WCSession, [String: Any]) -> Void) {
        receiveMessageHandlers.append(receiveMessageHandler)
    }
    
    func sendTokenData(_ tokenData: TokenData) {
        guard let session = getWatchSession() else { return }
        do {
            try session.updateApplicationContext(tokenData.toDict())
        } catch let error {
            print("Failed to send data to Watch device. Reason: \(error)")
        }
    }
    
    func clearTokenData() {
        guard let session = getWatchSession() else { return }
        do {
            try session.updateApplicationContext([:])
        } catch let error {
            print("Failed to send data to Watch device. Reason: \(error)")
        }
    }
    
    private func getWatchSession() -> WCSession? {
        if WCSession.isSupported() {
            let session = WCSession.default
            if session.isPaired && session.isWatchAppInstalled {
                return session
            }
        }
        return nil
    }
    
    override init() {
        super.init()
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        } else {
            print("[ios] Session is not supported.")
        }
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        print("Received message from Watch device: \(message)")
        receiveMessageHandlers.forEach { receiveMessageHandler in
            receiveMessageHandler(session, message)
        }
    }
    
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        DispatchQueue.main.async { [weak self] in
            self?.receiveContextHandlers.forEach { receiveContextHandler in
                receiveContextHandler(applicationContext)
            }
        }
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("[ios] Session state: \(activationState).")
        if error != nil {
            print("[ios] Error: \(String(describing: error)).")
        }
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        print("[ios] Session became inactive.")
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        print("[ios] Session deactivated.")
    }
}
