import Guaka
import Foundation
import CoreWLAN

var connectCommand = Command(
    usage: "connect",
    configuration: configuration,
    run: execute
)

private func configuration(command: Command) {
    command.add(flags: [
        Flag(longName: "bssid", type: String.self, description: "BSSID of WiFi access point"),
        Flag(longName: "ssid", type: String.self, description: "SSID of Wifi access point"),
        Flag(longName: "channel", type: Int.self, description: "Wifi channel of SSID")
        ])
    // Other configurations
    command.shortMessage = "connect to a WiFi network with given BSSID"
    command.example = "bssid connect 12:ab:cd:34:ef:56"
}

private func execute(flags: Flags, args: [String]) {
    // Execute code here
    let requestSSID = flags.getString(name: "ssid") ?? ""
    let requestBSSID = args.count > 0 ? args[0] : ""
    let requestChannel = flags.getInt(name: "channel") ?? -1

    if (requestBSSID.isEmpty && requestSSID.isEmpty) {
        print("require a BSSID or pass a SSID by --ssid")
        return
    }

    let wifiClient = CWWiFiClient()
    guard let interface = wifiClient.interface(), interface.powerOn() else {
        print("Cannot create interface or interface is not turned on")
        return
    }

    guard let networks = try? scanNetworks(interface) else {
        return
    }

    for network in networks {
        if !((!requestBSSID.isEmpty && network.bssid == requestBSSID) || (!requestSSID.isEmpty && network.ssid == requestSSID)) {
            continue
        } else {
            if requestChannel > -1 && network.wlanChannel?.channelNumber ?? 0 != requestChannel {
                continue
            } else {
                print("Input WiFi password")
                let password = String(cString: getpass(""))
                do {
                    try interface.associate(to: network, password: password)
                    return
                } catch {
                    print(String(format: "Failed connecting to %@, bssid %@"),
                        network.ssid ?? "", network.bssid ?? "")
                    return
                }
            }
        }
    }

    print("Cannot find specified access point")
    if !requestBSSID.isEmpty {
        print(String(format: "request BSSID %@", requestBSSID))
    }
    if !requestSSID.isEmpty {
        print(String(format: "request SSID %@", requestSSID))
    }
    if requestChannel > -1 {
        print(String(format: "request channel %@", requestSSID, String(requestChannel)))
    }
}
