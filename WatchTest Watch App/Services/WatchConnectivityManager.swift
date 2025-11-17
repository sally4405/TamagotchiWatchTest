//
//  WatchConnectivityManager.swift
//  WatchTest Watch App
//
//  Created by sello.axz on 11/10/25.
//

import Foundation
import WatchConnectivity

@MainActor
class WatchConnectivityManager: NSObject, ObservableObject {
    static let shared = WatchConnectivityManager()
    
    weak var tamagotchiManager: TamagotchiManager?
    private var session: WCSession?
    
    @Published var isReachable: Bool = false
    
    override init() {
        super.init()
        
        if WCSession.isSupported() {
            session = WCSession.default
            session?.delegate = self
            session?.activate()
        }
    }
    
    // MARK: - Send to iPhone
    func sendStatsToiPhone(id: UUID, stats: TamagotchiStats) {
        guard let session = session else { return }
        
        print("⌚️ watchOS: Sending stats to iPhone")
        print("  - ID: \(id.uuidString)")
        print("  - Energy: \(stats.energy)")
        
        let message: [String: Any] = [
            "type": "updateStats",
            "id": id.uuidString,
            "energy": stats.energy,
            "fullness": stats.fullness,
            "happiness": stats.happiness
        ]
        
        if session.isReachable {
            session.sendMessage(message, replyHandler: nil) { error in
                print("⌚️ watchOS: Failed to send message - \(error.localizedDescription)")
                self.session?.transferUserInfo(message)
            }
        } else {
            print("⌚️ watchOS: iPhone not reachable, sending via transferUserInfo")
            session.transferUserInfo(message)
        }
    }
    
    func sendInventoryToiPhone(_ inventory: [String: Int]) {
        guard let session = session else { return }
        
        print("⌚️ watchOS: Sending inventory to iPhone")
        
        let context: [String: Any] = [
            "type": "updateInventory",
            "inventory": inventory
        ]
        
        do {
            try session.updateApplicationContext(context)
            print("⌚️ watchOS: Inventory context updated")
        } catch {
            print("⌚️ watchOS: Failed to update inventory - \(error)")
        }
    }
}

// MARK: - WCSessionDelegate
extension WatchConnectivityManager: WCSessionDelegate {
    nonisolated func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        Task { @MainActor in
            print("⌚️ watchOS: Session activated - \(activationState.rawValue)")
            if let error = error {
                print("⌚️ watchOS: Activation error - \(error.localizedDescription)")
            }
        }
    }
    
    nonisolated func sessionReachabilityDidChange(_ session: WCSession) {
        Task { @MainActor in
            self.isReachable = session.isReachable
            print("⌚️ watchOS: Reachability changed - \(isReachable)")
        }
    }
    nonisolated func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        Task { @MainActor in
            print("⌚️ watchOS: Received message from iPhone")
            handleReceivedData(message)
        }
    }
    
    nonisolated func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any]) {
        Task { @MainActor in
            print("⌚️ watchOS: Received userInfo from iPhone")
            handleReceivedData(userInfo)
        }
    }
    
    nonisolated func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        Task { @MainActor in
            print("⌚️ watchOS: Received applicationContext from iPhone")
            handleReceivedData(applicationContext)
        }
    }
    
    // MARK: - Message Handling
    private func handleReceivedData(_ data: [String: Any]) {
        guard let type = data["type"] as? String else { return }
        
        switch type {
        case "selectTamagotchi":
            handleSelectTamagotchi(data)
        case "clearTamagotchi":
            handleClearTamagotchi()
        default:
            print("⌚️ watchOS: Unknown type - \(type)")
        }
    }
    
    private func handleSelectTamagotchi(_ data: [String: Any]) {
        guard let idString = data["id"] as? String,
              let id = UUID(uuidString: idString),
              let name = data["name"] as? String,
              let imageSetName = data["imageSetName"] as? String,
              let energy = data["energy"] as? Int,
              let fullness = data["fullness"] as? Int,
              let happiness = data["happiness"] as? Int else {
            print("⌚️ watchOS: Invalid selectTamagotchi data")
            return
        }
        
        print("⌚️ watchOS: Received tamagotchi from iPhone")
        print("  - ID: \(idString)")
        print("  - ImageSet: \(imageSetName)")
        
        let stats = TamagotchiStats(energy: energy, fullness: fullness, happiness: happiness)
        let tamagotchi = Tamagotchi(id: id, name: name, imageSetName: imageSetName, stats: stats)
        
        tamagotchiManager?.loadTamagotchi(tamagotchi)
    }
    
    private func handleClearTamagotchi() {
        print("⌚️ watchOS: Clearing tamagotchi")
        tamagotchiManager?.clearTamagotchi()
    }
}
