import UIKit
import SwiftyJSON
import WebAPI
import TVSetKit

class KinoKongMediaItem: MediaItem {
  let service = KinoKongService.shared

  var episodes = [KinoKongAPI.Episode]()
  var files = [String]()
    
  override init(data: JSON) {
    super.init(data: data)

    self.episodes = []
    self.files = []
  }
  
  required convenience init(from decoder: Decoder) throws {
    fatalError("init(from:) has not been implemented")
  }
  
  override func isContainer() -> Bool {
    return type == "serie" || type == "season" || type == "rating"
  }

  override func getBitrates() throws -> [[String: Any]] {
    var bitrates: [[String: Any]] = []

    var urls: [String] = []

    if type == "episode" {
      urls = files
    }
    else {
      urls = try service.getUrls(id!)
    }

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
