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
            guard let type = message["type"] as? String,
                  type == "selectTamagotchi",
                  let idString = message["id"] as? String,
                  let id = UUID(uuidString: idString),
                  let name = message["name"] as? String,
                  let imageSetName = message["imageSetName"] as? String,
                  let energy = message["energy"] as? Int,
                  let fullness = message["fullness"] as? Int,
                  let happiness = message["happiness"] as? Int else {
                print("⌚️ watchOS: Received invalid message")
                return
            }

            print("⌚️ watchOS: Received tamagotchi from iPhone")
            print("  - ID: \(idString)")
            print("  - ImageSet: \(imageSetName)")

            let stats = TamagotchiStats(energy: energy, fullness: fullness, happiness: happiness)
            let tamagotchi = Tamagotchi(id: id, name: name, imageSetName: imageSetName, stats: stats)

            tamagotchiManager?.loadTamagotchi(tamagotchi)
        }
    }

    nonisolated func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any]) {
        Task { @MainActor in
            print("⌚️ watchOS: Received userInfo from iPhone")

            guard let type = userInfo["type"] as? String,
                  type == "selectTamagotchi",
                  let idString = userInfo["id"] as? String,
                  let id = UUID(uuidString: idString),
                  let name = userInfo["name"] as? String,
                  let imageSetName = userInfo["imageSetName"] as? String,
                  let energy = userInfo["energy"] as? Int,
                  let fullness = userInfo["fullness"] as? Int,
                  let happiness = userInfo["happiness"] as? Int else {
                print("⌚️ watchOS: Received invalid userInfo")
                return
            }

            print("⌚️ watchOS: Processing userInfo")
            print("  - ID: \(idString)")
            print("  - ImageSet: \(imageSetName)")

            let stats = TamagotchiStats(energy: energy, fullness: fullness, happiness: happiness)
            let tamagotchi = Tamagotchi(id: id, name: name, imageSetName: imageSetName, stats: stats)

            tamagotchiManager?.loadTamagotchi(tamagotchi)
        }
    }

    nonisolated func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        Task { @MainActor in
            print("⌚️ watchOS: Received applicationContext from iPhone")

            guard let type = applicationContext["type"] as? String,
                  type == "selectTamagotchi",
                  let idString = applicationContext["id"] as? String,
                  let id = UUID(uuidString: idString),
                  let name = applicationContext["name"] as? String,
                  let imageSetName = applicationContext["imageSetName"] as? String,
                  let energy = applicationContext["energy"] as? Int,
                  let fullness = applicationContext["fullness"] as? Int,
                  let happiness = applicationContext["happiness"] as? Int else {
                print("⌚️ watchOS: Received invalid applicationContext")
                return
            }

            print("⌚️ watchOS: Processing application context")
            print("  - ID: \(idString)")
            print("  - ImageSet: \(imageSetName)")

            let stats = TamagotchiStats(energy: energy, fullness: fullness, happiness: happiness)
            let tamagotchi = Tamagotchi(id: id, name: name, imageSetName: imageSetName, stats: stats)

            tamagotchiManager?.loadTamagotchi(tamagotchi)
        }
    }
}
