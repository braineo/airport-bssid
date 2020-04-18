import Foundation
import CoreWLAN
import CoreLocation

public func scanNetworks(_ interface: CWInterface, name: String? = nil) throws -> Set<CWNetwork> {
    let locationManager = CLLocationManager()
    if #available(macOS 10.15, *) {
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
    }
  if #available(macOS 10.13, *) {
    return try interface.scanForNetworks(withName: name, includeHidden: true)
  } else {
    return try interface.scanForNetworks(withName: name)
  }
}
