import ArgumentParser

@main
struct BSSID: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "bssid",
        abstract: "List Wi-Fi access points and connect by BSSID, SSID, or channel.",
        version: "1.0.0",
        subcommands: [Scan.self, Connect.self]
    )
}
