import UIKit
import SwiftyJSON
import WebAPI
import TVSetKit

class KinoKongMediaItem: MediaItem {
  let service = KinoKongService.shared

  var episodes = [JSON]()

  override init(data: JSON) {
    super.init(data: data)

//    self.seasonNumber = data["seasonNumber"].stringValue
//    self.episodeNumber = data["episodeNumber"].stringValue

    self.episodes = []

    let episodes = data["episodes"].arrayValue

    for episode in episodes {
      self.episodes.append(episode)
    }
//
//    self.items = []
//
//    let items = data["items"].arrayValue
//
//    for item in items {
//      self.items.append(item)
//    }
  }

  override func isContainer() -> Bool {
    return type == "serie" || type == "season" || type == "rating"
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

    var urls: [String] = []

    if type == "episode" {
      urls = [id!]
    }
    else {
      urls = try service.getUrls(id!)
    }

    let qualityLevels = QualityLevel.availableLevels(urls.count)

    for (index, url) in urls.enumerated() {
      print(url)
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
