import Foundation
import CoreWLAN

func scanNetworks(_ interface: CWInterface, name: String? = nil) throws -> Set<CWNetwork> {
  if #available(macOS 10.13, *) {
    return try interface.scanForNetworks(withName: name, includeHidden: true)
  } else {
    return try interface.scanForNetworks(withName: name)
  }
}