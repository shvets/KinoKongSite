import WebAPI
import TVSetKit

public class KinoKongService {
  static let shared: KinoKongAPI = {
    return KinoKongAPI()
  }()

  static let bookmarksFileName = NSHomeDirectory() + "/Library/Caches/kinokong-bookmarks.json"
  static let historyFileName = NSHomeDirectory() + "/Library/Caches/kinokong-history.json"

  public static let StoryboardId = "KinoKong"
  public static let BundleId = "com.rubikon.KinoKongSite"

  lazy var bookmarks = Bookmarks(KinoKongService.bookmarksFileName)
  lazy var history = History(KinoKongService.historyFileName)

  lazy var bookmarksManager = BookmarksManager(bookmarks)
  lazy var historyManager = HistoryManager(history)

  var dataSource = KinoKongDataSource()

  let mobile: Bool

  public init(_ mobile: Bool=false) {
    self.mobile = mobile
  }

  func buildLayout() -> UICollectionViewFlowLayout? {
    let layout = UICollectionViewFlowLayout()

    layout.itemSize = CGSize(width: 180*1.6, height: 248*1.6) // 180 x 248
    layout.sectionInset = UIEdgeInsets(top: 40.0, left: 40.0, bottom: 120.0, right: 40.0)
    layout.minimumInteritemSpacing = 40.0
    layout.minimumLineSpacing = 85.0

    layout.headerReferenceSize = CGSize(width: 500, height: 75)

    return layout
  }

  func getDetailsImageFrame() -> CGRect? {
    return CGRect(x: 40, y: 40, width: 180*2.7, height: 248*2.7)
  }

  func getConfiguration() -> [String: Any] {
    var conf = [String: Any]()

    conf["pageSize"] = 15

    if mobile {
      conf["rowSize"] = 1
    }
    else {
      conf["rowSize"] = 5
    }

    conf["mobile"] = mobile

    conf["bookmarksManager"] = bookmarksManager
    conf["historyManager"] = historyManager
    conf["dataSource"] = dataSource
    conf["storyboardId"] = KinoKongService.StoryboardId
    conf["bundleId"] = KinoKongService.BundleId
    conf["detailsImageFrame"] = getDetailsImageFrame()
    conf["buildLayout"] = buildLayout()

    return conf
  }
}
