import Guaka
import CoreLocation

setupCommands()
let locationManager = CLLocationManager()
if #available(macOS 10.15, *) {
    locationManager.requestAlwaysAuthorization()
}
rootCommand.execute()
