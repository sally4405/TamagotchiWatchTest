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
    func sendTamagotchiToWatch(_ tamagotchi: Tamagotchi) {
        guard let session = session else { return }
        
        print("📱 iOS: Sending tamagotchi to Watch")
        print("  - ID: \(tamagotchi.id.uuidString)")
        print("  - ImageSet: \(tamagotchi.imageSetName)")
        
        let message: [String: Any] = [
            "type": "selectTamagotchi",
            "id": tamagotchi.id.uuidString,
            "name": tamagotchi.name,
            "imageSetName": tamagotchi.imageSetName,
            "energy": tamagotchi.stats.energy,
            "fullness": tamagotchi.stats.fullness,
            "happiness": tamagotchi.stats.happiness
        ]
        
        if session.isReachable {
            session.sendMessage(message, replyHandler: nil) { error in
                print("📱 iOS: Failed to send message - \(error.localizedDescription)")
                self.sendViaUserInfo(message)
            }
        } else {
            sendViaUserInfo(message)
        }
    }
    
    private func sendViaUserInfo(_ message: [String: Any]) {
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
            guard let type = message["type"] as? String,
                  type == "updateStats",
                  let idString = message["id"] as? String,
                  let id = UUID(uuidString: idString),
                  let energy = message["energy"] as? Int,
                  let fullness = message["fullness"] as? Int,
                  let happiness = message["happiness"] as? Int else {
                print("📱 iOS: Received invalid message")
                return
            }
            
            print("📱 iOS: Received stats update from Watch")
            print("  - ID: \(idString)")
            print("  - Energy: \(energy)")
            
            let stats = TamagotchiStats(energy: energy, fullness: fullness, happiness: happiness)
            tamagotchiManager?.updateStats(id: id, stats: stats)
        }
    }
    
    nonisolated func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any]) {
        Task { @MainActor in
            guard let type = userInfo["type"] as? String,
                  type == "updateStats",
                  let idString = userInfo["id"] as? String,
                  let id = UUID(uuidString: idString),
                  let energy = userInfo["energy"] as? Int,
                  let fullness = userInfo["fullness"] as? Int,
                  let happiness = userInfo["happiness"] as? Int else {
                print("📱 iOS: Received invalid userInfo")
                return
            }
            
            print("📱 iOS: Received stats update from Watch (userInfo)")
            print("  - ID: \(idString)")
            print("  - Energy: \(energy)")
            
            let stats = TamagotchiStats(energy: energy, fullness: fullness, happiness: happiness)
            tamagotchiManager?.updateStats(id: id, stats: stats)
        }
    }
    
    nonisolated func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String: Any]) {
        Task { @MainActor in
            guard let type = applicationContext["type"] as? String else { return }
            
            if type == "updateInventory" {
                if let inventory = applicationContext["inventory"] as? [String: Int] {
                    print("📱 iOS: Received inventory from Watch")
                    print("  - Items count: \(inventory.count)")
                    self.watchInventory = inventory
                }
            }
        }
    }
    
    nonisolated func sessionDidBecomeInactive(_ session: WCSession) {
        print("📱 iOS: Session became inactive")
    }
    
    nonisolated func sessionDidDeactivate(_ session: WCSession) {
        print("📱 iOS: Session deactivated")
        session.activate()
    }
}
