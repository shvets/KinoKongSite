import UIKit
import SwiftyJSON
import SwiftSoup
import WebAPI
import TVSetKit

class KinoKongServiceAdapter: ServiceAdapter {
  let service = KinoKongService.shared

  static let bookmarksFileName = NSHomeDirectory() + "/Library/Caches/kinokong-bookmarks.json"
  static let historyFileName = NSHomeDirectory() + "/Library/Caches/kinokong-history.json"

  override open class var StoryboardId: String { return "KinoKong" }
  override open class var BundleId: String { return "com.rubikon.KinoKongSite" }

  lazy var bookmarks = Bookmarks(bookmarksFileName)
  lazy var history = History(historyFileName)

  var episodes: [JSON]?

  public override init(mobile: Bool=false) {
    super.init(mobile: mobile)
    
    bookmarks.load()
    history.load()

    pageSize = 15
    rowSize = 3
  }

  override open func clone() -> ServiceAdapter {
    let cloned = KinoKongServiceAdapter(mobile: mobile!)

    cloned.clear()

    return cloned
  }

  open func instantiateController(controllerId: String) -> UIViewController {
    return UIViewController.instantiate(
      controllerId: controllerId,
      storyboardId: KinoKongServiceAdapter.StoryboardId,
      bundleId: KinoKongServiceAdapter.BundleId)
  }

  override func load() throws -> [MediaItem] {
    let dataSource = KinoKongDataSource()

    var params = RequestParams()

    params.identifier = requestType == "Search" ? query : parentId
    params.parentName = parentName
    params.bookmarks = bookmarks
    params.history = history
    params.selectedItem = selectedItem
    //params.document = document

    if let requestType = requestType {
      return try dataSource.load(requestType, params: params, pageSize: pageSize!, currentPage: currentPage)
    }
    else {
      return []
    }
  }

  override func buildLayout() -> UICollectionViewFlowLayout? {
    let layout = UICollectionViewFlowLayout()

    layout.itemSize = CGSize(width: 200*1.2, height: 300*1.2) // 200 x 300
    layout.sectionInset = UIEdgeInsets(top: 40.0, left: 40.0, bottom: 120.0, right: 40.0)
    layout.minimumInteritemSpacing = 40.0
    layout.minimumLineSpacing = 140.0

    layout.headerReferenceSize = CGSize(width: 500, height: 75)

    return layout
  }

  override func getDetailsImageFrame() -> CGRect? {
    return CGRect(x: 40, y: 40, width: 210*2.7, height: 300*2.7)
  }

  override func getUrl(_ params: [String: Any]) throws -> String {
    let id = params["id"] as! String
    let mediaItem = params["item"] as! MediaItem

    let urls: [String] = []
      //try service.getUrls(id, season: mediaItem.seasonNumber!, episode: mediaItem.episodeNumber!)

    var newUrls: [String] = []

//    for url in urls {
//      newUrls.append(url["url"]!)
//    }

    return newUrls[0]
  }

//  override func retrieveExtraInfo(_ item: MediaItem) throws {
//    let movieUrl = item.id!
//
//    if item.type == "movie" {
//      let document = try service.fetchDocument(movieUrl)
//
//      let mediaData = try service.getMediaData(document!)
//
//      var text = ""
//
//      if let year = mediaData["year"] as? String {
//        text += "\(year)\n"
//      }
//
//      if let countries = mediaData["countries"] as? [String] {
//        let txt = countries.joined(separator: ", ")
//
//        text += "\(txt)\n"
//      }
//
//      if let duration = mediaData["duration"] as? String {
//        text += "\(duration)\n\n"
//      }
//
//      if let tags = mediaData["tags"] as? [String] {
//        let txt = tags.joined(separator: ", ")
//
//        text += "\(txt)\n"
//      }
//
//      if let summary = mediaData["summary"] as? String {
//        text += "\(summary)\n"
//      }
//
//      item.description = text
//    }
//  }

  override func addBookmark(item: MediaItem) -> Bool {
    return bookmarks.addBookmark(item: item)
  }

  override func removeBookmark(item: MediaItem) -> Bool {
    return bookmarks.removeBookmark(item: item)
  }

  override func addHistoryItem(_ item: MediaItem) {
    history.add(item: item)
  }

}
