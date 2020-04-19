import Guaka
import Foundation
import CoreWLAN

var connectSsidCommand = Command(
        usage: "connect-ssid",
        configuration: configuration,
        run: execute
)

private func configuration(command: Command) {
    command.add(flags: [
        // Add your flags here
    ])
    // Other configurations
    command.shortMessage = "connect to a WiFi network with given SSID and channel"
    command.example = "bssid connect WifiNetwork 54"
}

private func execute(flags: Flags, args: [String]) {
    // Execute code here

    if (args.count != 2) {
        print("require a SSID and channel")
        return
    }
    let ssid = args[0]
    let channel = (args[1] as NSString).integerValue

    let wifiClient = CWWiFiClient()
    guard let interface = wifiClient.interface(), interface.powerOn() else {
        print("Cannot create interface or interface is not turned on")
        return
    }

    guard let networks = try? scanNetworks(interface) else {
        return
    }

    for network in networks {
        if network.ssid ?? "" == ssid && network.wlanChannel?.channelNumber ?? 0 == channel {
            print("Input WiFi password")
            let password = String(cString: getpass(""))
            do {
                try interface.associate(to: network, password: password)
            } catch {
                print(String(format: "Failed connecting to %@, bssid %@"),
                        network.ssid ?? "", network.bssid ?? "")
            }
        }
    }
}
