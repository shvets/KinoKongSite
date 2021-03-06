import UIKit
import MediaApis
import TVSetKit

class KinoKongMediaItem: MediaItem {
  let service = KinoKongService.shared

  var episodes = [KinoKongAPI.Episode]()
  var files = [String]()

  public override init(data: [String: String]) {
    super.init(data: data)
  }

  required convenience init(from decoder: Decoder) throws {
    fatalError("init(from:) has not been implemented")
  }
  
  override func isContainer() -> Bool {
    return type == "serie" || type == "season" || type == "rating"
  }

  override func getBitrates() throws -> [[String: String]] {
    var bitrates: [[String: String]] = []

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

      var bitrate: [String: String] = [:]
      bitrate["id"] = metadata["width"]
      bitrate["url"] = url

      bitrate["name"] = qualityLevels[index].rawValue

      bitrates.append(bitrate)
    }

    return bitrates
  }

}
