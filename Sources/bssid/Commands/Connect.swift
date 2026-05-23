import ArgumentParser
import CoreLocation
import CoreWLAN
import Darwin
import Foundation

struct Connect: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Connect to a Wi-Fi network by BSSID, or by SSID (+ optional channel).",
        discussion: """
        Examples:
          bssid connect 12:ab:cd:34:ef:56
          bssid connect --ssid MyNetwork
          bssid connect --ssid MyNetwork --channel 36
        """
    )

    @Argument(help: "BSSID of the access point (e.g. 12:ab:cd:34:ef:56).")
    var bssid: String?

    @Option(name: .long, help: "SSID of the Wi-Fi network. Use instead of a BSSID.")
    var ssid: String?

    @Option(name: .long, help: "Wi-Fi channel number. Narrows --ssid to a specific AP.")
    var channel: Int?

    func validate() throws {
        if (bssid ?? "").isEmpty && (ssid ?? "").isEmpty {
            throw ValidationError("Provide a BSSID argument or --ssid.")
        }
    }

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

        let wifi = try WiFi()
        let networks = try await wifi.scan()

        let target = networks.first { network in
            if let bssid, !bssid.isEmpty, network.bssid != bssid { return false }
            if let ssid, !ssid.isEmpty, network.ssid != ssid { return false }
            if let channel, network.wlanChannel?.channelNumber != channel { return false }
            return true
        }

        guard let network = target else {
            print("Cannot find specified access point.")
            if let bssid, !bssid.isEmpty { print("requested BSSID: \(bssid)") }
            if let ssid, !ssid.isEmpty { print("requested SSID: \(ssid)") }
            if let channel { print("requested channel: \(channel)") }
            throw ExitCode.failure
        }

        print("Input WiFi password")
        let password = String(cString: getpass(""))

        do {
            try await wifi.associate(to: network, password: password)
            print("Connected to \(network.ssid ?? "") (\(network.bssid ?? "?"))")
        } catch {
            print("Failed connecting to \(network.ssid ?? "") (\(network.bssid ?? "?")): \(error)")
            throw ExitCode.failure
        }
    }
}
