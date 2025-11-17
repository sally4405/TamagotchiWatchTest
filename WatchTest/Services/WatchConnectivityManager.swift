//
//  WatchConnectivityManager.swift
//  WatchTest
//
//  Created by sello.axz on 11/4/25.
//

import Foundation
import WatchConnectivity

@MainActor
class WatchConnectivityManager: NSObject, ObservableObject {
    static let shared = WatchConnectivityManager()
    
    weak var tamagotchiManager: TamagotchiManager?
    private var session: WCSession?
    
    @Published var isReachable: Bool = false
    @Published var watchInventory: [String: Int] = [:]
    
    override init() {
        super.init()
        
        if WCSession.isSupported() {
            session = WCSession.default
            session?.delegate = self
            session?.activate()
        }
    }
    
    // MARK: - Send to Watch
    func sendTamagotchiToWatch(_ tamagotchi: Tamagotchi? = nil) {
        guard let session = session else { return }
        var message: [String: Any] = [:]
                
        if let tamagotchi = tamagotchi {
            print("📱 iOS: Sending tamagotchi to Watch")
            print("  - ID: \(tamagotchi.id.uuidString)")
            print("  - ImageSet: \(tamagotchi.imageSetName)")
            
            message = [
                "type": "selectTamagotchi",
                "id": tamagotchi.id.uuidString,
                "name": tamagotchi.name,
                "imageSetName": tamagotchi.imageSetName,
                "energy": tamagotchi.stats.energy,
                "fullness": tamagotchi.stats.fullness,
                "happiness": tamagotchi.stats.happiness
            ]
        } else {
            print("📱 iOS: Sending clear tamagotchi to Watch")
            
            message = ["type": "clearTamagotchi"]
        }
        
        if session.isReachable {
            session.sendMessage(message, replyHandler: nil) { error in
                print("📱 iOS: Failed to send message - \(error.localizedDescription)")
                self.sendViaContext(message)
            }
        } else {
            sendViaContext(message)
        }
    }
    
    private func sendViaContext(_ message: [String: Any]) {
        do {
            try session?.updateApplicationContext(message)
            print("📱 iOS: Updated application context")
        } catch {
            print("📱 iOS: Failed to update context - \(error)")
            session?.transferUserInfo(message)
        }
    }
}

extension WatchConnectivityManager: WCSessionDelegate {
    nonisolated func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        Task { @MainActor in
            print("📱 iOS: Session activated - \(activationState.rawValue)")
            if let error = error {
                print("📱 iOS: Activation error - \(error.localizedDescription)")
            }
        }
    }
    
    nonisolated func sessionReachabilityDidChange(_ session: WCSession) {
        Task { @MainActor in
            isReachable = session.isReachable
            print("📱 iOS: Reachability changed - \(isReachable)")
        }
    }
    
    nonisolated func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        Task { @MainActor in
            print("📱 iOS: Received message from Watch")
            handleReceivedData(message)
        }
    }
    
    nonisolated func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any]) {
        Task { @MainActor in
            print("📱 iOS: Received user info from Watch")
            handleReceivedData(userInfo)
        }
    }
    
    nonisolated func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String: Any]) {
        Task { @MainActor in
            print("📱 iOS: Received application context from Watch")
            handleReceivedData(applicationContext)
        }
    }
    
    nonisolated func sessionDidBecomeInactive(_ session: WCSession) {
        print("📱 iOS: Session became inactive")
    }
    
    nonisolated func sessionDidDeactivate(_ session: WCSession) {
        print("📱 iOS: Session deactivated")
        session.activate()
    }
    
    // MARK: - Message Handling
    private func handleReceivedData(_ data: [String: Any]) {
        guard let type = data["type"] as? String else { return }
        
        switch type {
        case "updateStats":
            handleUpdateStats(data)
        case "updateInventory":
            handleUpdateInventory(data)
        default:
            print("📱 iOS: Unknown type - \(type)")
        }
    }
    
    private func handleUpdateStats(_ data: [String: Any]) {
        guard let idString = data["id"] as? String,
              let id = UUID(uuidString: idString),
              let energy = data["energy"] as? Int,
              let fullness = data["fullness"] as? Int,
              let happiness = data["happiness"] as? Int else {
            print("📱 iOS: Invalid updateStats data")
            return
        }
        
        print("📱 iOS: Received stats update from Watch")
        print("  - ID: \(idString)")
        
        let stats = TamagotchiStats(energy: energy, fullness: fullness, happiness: happiness)
        tamagotchiManager?.updateStats(id: id, stats: stats)
    }
    
    private func handleUpdateInventory(_ data: [String: Any]) {
        guard let inventory = data["inventory"] as? [String: Int] else {
            print("📱 iOS: Invalid updateInventory data")
            return
        }
        
        print("📱 iOS: Received inventory update from Watch")
        print("  - Items count: \(inventory.count)")
        
        self.watchInventory = inventory
    }
}
