import UIKit
import SwiftyJSON
import WebAPI
import TVSetKit

class KinoKongMediaItem: MediaItem {
  let service = KinoKongService.shared

  var episodes = [JSON]()

  override init(data: JSON) {
    super.init(data: data)

    self.episodes = []

    let episodes = data["episodes"].arrayValue

    for episode in episodes {
      self.episodes.append(episode)
    }
  }

  override func isContainer() -> Bool {
    return type == "serie" || type == "season" || type == "rating"
  }

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
