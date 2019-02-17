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
}

private func execute(flags: Flags, args: [String]) {
    // Execute code here
    if (args.count != 1) {
        print("require a SSID name")
        return
    }

    print("scanning \(args[0])")
    let ssidName = args[0]

    let wifiClient = CWWiFiClient()
    guard let interface = wifiClient.interface(), interface.powerOn() else {
        print("Cannot create interface or interface is not turned on")
        return
    }

    guard let networks = try? interface.scanForNetworks(withName: ssidName) else {
        print("Failed at scanning \(ssidName)")
        return
    }

    for network in networks {
        print(String(format: "ssid: %@, bssid: %@, channel: %d", network.ssid ?? "",
                network.bssid ?? "", network.wlanChannel?.channelNumber ?? -1))
    }
}
