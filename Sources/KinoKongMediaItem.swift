import UIKit
import SwiftyJSON
import WebAPI
import TVSetKit

class KinoKongMediaItem: MediaItem {
//  let service = KinoKongService.shared
//
//  override func isContainer() -> Bool {
//    return type == "serie" || type == "season"
//  }

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
//
//  override func getBitrates() throws -> [[String: Any]] {
//    let urls = try service.getUrls(id!, season: seasonNumber!, episode: episodeNumber!)
//
//    let qualityLevels = QualityLevel.availableLevels(urls.count)
//
//    var bitrates: [[String: Any]] = []
//
//    for (index, item) in urls.enumerated() {
//      var bitrate: [String: Any] = [:]
//      bitrate["id"] = item["bandwidth"]
//
//      bitrate["name"] = qualityLevels[index].rawValue
//
//      bitrates.append(bitrate)
//    }
//
//    return bitrates
//  }

}
