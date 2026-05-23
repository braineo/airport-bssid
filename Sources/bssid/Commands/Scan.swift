import ArgumentParser
import CoreLocation
import Foundation

struct Scan: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Scan Wi-Fi access points. If SSIDs are given, only show those."
    )

    @Argument(help: "Optional SSIDs to filter the scan results.")
    var ssids: [String] = []

    func run() async throws {
        let authorizer = LocationAuthorizer()
        if !authorizer.servicesEnabled {
            throw ValidationError(
                "Location Services is disabled system-wide. Enable it in "
                + "System Settings → Privacy & Security → Location Services."
            )
        }
        let status = authorizer.ensureAuthorization()
        guard status == .authorizedAlways || status == .authorized else {
            throw ValidationError(
                "Location permission is required to read BSSIDs (status: \(status.rawValue)). "
                + "Open System Settings → Privacy & Security → Location Services and enable bssid, "
                + "or run `tccutil reset Location dev.braineo.bssid` and try again. "
                + "On macOS 14+ Apple may also restrict BSSID return entirely for unentitled apps."
            )
        }

        let filter = Set(ssids)
        if filter.isEmpty {
            print("No SSID specified, scanning all")
        } else {
            print("Scanning \(filter.sorted().joined(separator: ", "))")
        }

        let wifi = try WiFi()
        let networks = try await wifi.scan()

        let rows = networks
            .filter { filter.isEmpty || filter.contains($0.ssid ?? "") }
            .sorted { $0.rssiValue > $1.rssiValue }

        for network in rows {
            print(String(
                format: "ssid: %@, bssid: %@, channel: %d, dBm %d",
                network.ssid ?? "",
                network.bssid ?? "",
                network.wlanChannel?.channelNumber ?? -1,
                network.rssiValue
            ))
        }
    }
}
