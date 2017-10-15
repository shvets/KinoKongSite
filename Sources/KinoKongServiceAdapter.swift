import UIKit
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

  var bookmarksManager: BookmarksManager!
  var historyManager: HistoryManager!
    
  public init(mobile: Bool=false) {
    super.init(dataSource: KinoKongDataSource(), mobile: mobile)
    
    bookmarks.load()
    history.load()
    
    bookmarksManager = BookmarksManager(bookmarks)
    historyManager = HistoryManager(history)


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

  func getConfiguration() -> [String: Any] {
    if mobile {
      return [
        "pageSize": 15,
        "rowSize": 1
      ]
    }
    else {
      return [
        "pageSize": 15,
        "rowSize": 5
      ]
    }
  }
}
