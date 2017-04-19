import UIKit
import SwiftyJSON
import WebAPI
import TVSetKit

class KinoKongMediaItem: MediaItem {
  let service = KinoKongService.shared

  override func isContainer() -> Bool {
    return type == "serie" || type == "season"
  }

//  override func resolveType() {
//    var serial = false
//
//    do {
//      serial = try service.isSerial(id!)
//    }
//    catch {
//      print("cannot check if it is serial.")
//    }
//
//    if serial {
//      type = "serie"
//    }
//    else {
//      type = "movie"
//    }
//  }

  override func getBitrates() throws -> [[String: Any]] {
    var bitrates: [[String: Any]] = []

    let urls = try service.getUrls(id!)

    let qualityLevels = QualityLevel.availableLevels(urls.count)

    for (index, url) in urls.enumerated() {
      let metadata = service.getMetadata(url)

      var bitrate: [String: Any] = [:]
      bitrate["id"] = metadata["width"]
      bitrate["url"] = url

      bitrate["name"] = qualityLevels[index].rawValue

      bitrates.append(bitrate)
    }

    return bitrates
  }

}
