import UIKit
import SwiftyJSON
import SwiftSoup
import WebAPI
import TVSetKit

class KinoKongServiceAdapter: ServiceAdapter {
  static let bookmarksFileName = NSHomeDirectory() + "/Library/Caches/kinokong-bookmarks.json"
  static let historyFileName = NSHomeDirectory() + "/Library/Caches/kinokong-history.json"

  override open class var StoryboardId: String { return "KinoKong" }
  override open class var BundleId: String { return "com.rubikon.KinoKongSite" }

    lazy var bookmarks = Bookmarks(KinoKongServiceAdapter.bookmarksFileName)
    lazy var history = History(KinoKongServiceAdapter.historyFileName)

  var episodes: [JSON]?

  public init(mobile: Bool=false) {
    super.init(dataSource: KinoKongDataSource(), mobile: mobile)
    
    bookmarks.load()
    history.load()

    pageLoader.pageSize = 15
    pageLoader.rowSize = 5

    pageLoader.load = {
      return try self.load()
    }
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

  override open func load() throws -> [Any] {
    params["bookmarks"] = bookmarks
    params["history"] = history

    return try super.load()
  }

  override func buildLayout() -> UICollectionViewFlowLayout? {
    let layout = UICollectionViewFlowLayout()

    layout.itemSize = CGSize(width: 180*1.6, height: 248*1.6) // 180 x 248
    layout.sectionInset = UIEdgeInsets(top: 40.0, left: 40.0, bottom: 120.0, right: 40.0)
    layout.minimumInteritemSpacing = 40.0
    layout.minimumLineSpacing = 85.0

    layout.headerReferenceSize = CGSize(width: 500, height: 75)

    return layout
  }

  override func getDetailsImageFrame() -> CGRect? {
    return CGRect(x: 40, y: 40, width: 180*2.7, height: 248*2.7)
  }

  override func getUrl(_ params: [String: Any]) throws -> String {
    let bitrate = params["bitrate"] as! [String: String]

    return bitrate["url"]!
  }

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
