import CoreLocation
import Foundation

final class LocationAuthorizer: NSObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    private var cachedStatus: CLAuthorizationStatus = .notDetermined
    private var statusChanged = false

    override init() {
        super.init()
        manager.delegate = self
        cachedStatus = manager.authorizationStatus
    }

    var status: CLAuthorizationStatus { cachedStatus }

    var servicesEnabled: Bool { CLLocationManager.locationServicesEnabled() }

    /// Request authorization if needed and wait for a terminal status by pumping the main
    /// runloop. We also start a real updates request, since `requestWhenInUseAuthorization`
    /// alone is often a no-op on modern macOS unless the app actually consumes location.
    func ensureAuthorization(timeout: TimeInterval = 30) -> CLAuthorizationStatus {
        if cachedStatus != .notDetermined {
            return cachedStatus
        }

        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()

        let timer = Timer(timeInterval: 60, repeats: true) { _ in }
        RunLoop.main.add(timer, forMode: .default)
        defer {
            timer.invalidate()
            manager.stopUpdatingLocation()
        }

        let deadline = Date().addingTimeInterval(timeout)
        while !statusChanged && cachedStatus == .notDetermined && Date() < deadline {
            RunLoop.main.run(mode: .default, before: Date().addingTimeInterval(0.5))
        }
        return cachedStatus
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        statusChanged = true
        cachedStatus = manager.authorizationStatus
    }
}
