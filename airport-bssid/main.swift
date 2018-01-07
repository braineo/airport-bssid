//
//  main.swift
//  airport-bssid
//
//  Created by Binbin Ye on 2018/01/07.
//  Copyright © 2018 Binbin Ye. All rights reserved.
//

import Foundation
import CoreWLAN

print("Hello, World!")
var targetNetwork = CWNetwork()
if let wifiClient = CWWiFiClient() {
    if let interface = wifiClient.interface() {
        if !interface.powerOn() {
            print("Wifi interface is not activated")
        } else {
            print(interface.interfaceName!)
            print(interface.activePHYMode())
            let networks = try interface.scanForNetworks(withSSID: nil)
            print("\("ESSID".padding(toLength: 24, withPad: " ", startingAt: 0))" +
                    "\("BSSID".padding(toLength: 17, withPad: " ", startingAt: 0))  " +
                    "\("Ch".padding(toLength: 3, withPad: " ", startingAt: 0))  " + "dBm")
            for network in networks {
                if network.bssid! == "some bssid" {
                    targetNetwork = network
                }
                print("\(network.ssid?.padding(toLength: 24, withPad: " ", startingAt: 0) ?? "")" +
                        "\(network.bssid?.padding(toLength: 17, withPad: " ", startingAt: 0) ?? "")  " +
                        "\(network.wlanChannel.channelNumber)".padding(toLength: 3, withPad: " ", startingAt: 0) + "  \(network.rssiValue)"
                )
            }
            try interface.associate(to: targetNetwork, password: "wifi password")
        }
    }
} else {

}
