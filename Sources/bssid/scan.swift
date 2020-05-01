import Guaka
import CoreWLAN
import Foundation

var scanCommand = Command(
        usage: "scan",
        configuration: configuration,
        run: execute
)

private func configuration(command: Command) {
    command.add(flags: [
        // Add your flags here
    ])
    // Other configurations
    command.longMessage = "Scan WiFi APs. If SSIDs are given, only show result of those SSIDs"
    command.example = "bssid scan ssid1 ssid2"
}

private func execute(flags: Flags, args: [String]) {
    // Execute code here
    let ssidNames = Set(args)
    let ssidName: String? = args.count == 1 ? args[0] : nil
    if (args.count > 0) {
        print("Scanning \(ssidNames.joined(separator: ", "))")
    } else {
        print("No SSID specified, scanning all")
    }

    let wifiClient = CWWiFiClient()
    guard let interface = wifiClient.interface(), interface.powerOn() else {
        print("Cannot create interface or interface is not turned on")
        return
    }

    guard let networks = try? scanNetworks(interface, name: ssidName) else {
        print("Failed at scanning \(ssidName ?? "")")
        return
    }

    for network in networks.filter({ ssidNames.count > 0 ? ssidNames.contains($0.ssid ?? "") : true }).sorted(by: { $0.rssiValue > $1.rssiValue }) {
        print(String(format: "ssid: %@, bssid: %@, channel: %d, dBm %d", network.ssid ?? "",
                network.bssid ?? "", network.wlanChannel?.channelNumber ?? -1, network.rssiValue))
    }
}
