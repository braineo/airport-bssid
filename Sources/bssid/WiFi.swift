@preconcurrency import CoreWLAN
import Foundation

enum WiFiError: Error, CustomStringConvertible {
    case noInterface
    case interfaceOff
    case notFound(String)

    var description: String {
        switch self {
        case .noInterface: return "No Wi-Fi interface available."
        case .interfaceOff: return "Wi-Fi interface is powered off."
        case .notFound(let what): return "Cannot find \(what)."
        }
    }
}

struct WiFi {
    let interface: CWInterface

    init() throws {
        guard let iface = CWWiFiClient.shared().interface() else {
            throw WiFiError.noInterface
        }
        guard iface.powerOn() else {
            throw WiFiError.interfaceOff
        }
        self.interface = iface
    }

    func scan(name: String? = nil) async throws -> [CWNetwork] {
        try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    let networks = try interface.scanForNetworks(withName: name, includeHidden: true)
                    continuation.resume(returning: Array(networks))
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    func associate(to network: CWNetwork, password: String) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    try interface.associate(to: network, password: password)
                    continuation.resume()
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}
