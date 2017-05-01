import SwiftyJSON
import SwiftSoup
import WebAPI
import TVSetKit

class KinoKongDataSource: DataSource {
  let service = KinoKongService.shared

  override open func load(pageSize: Int, currentPage: Int, convert: Bool=true) throws -> [Any] {
    var result: [Any] = []

    let identifier = params["identifier"] as? String
    let bookmarks = params["bookmarks"] as! Bookmarks
    let history = params["history"] as! History
    let selectedItem = params["selectedItem"] as? MediaItem

    var episodes = [JSON]()

    var request = params["requestType"] as! String

    if selectedItem?.type == "rating" {
      request = "Seasons"
    }
    else if selectedItem?.type == "serie" {
      request = "Seasons"
    }
    else if selectedItem?.type == "season" {
      request = "Episodes"

      episodes = (selectedItem as! KinoKongMediaItem).episodes
    }

    switch request {
      case "Bookmarks":
        bookmarks.load()
        result = bookmarks.getBookmarks(pageSize: 60, page: currentPage)

      case "History":
        history.load()
        result = history.getHistoryItems(pageSize: 60, page: currentPage)

      case "All Movies":
        result = try service.getAllMovies(page: currentPage)["movies"] as! [Any]

      case "New Movies":
        result = try service.getNewMovies(page: currentPage)["movies"] as! [Any]

      case "All Series":
        result = try service.getAllSeries(page: currentPage)["movies"] as! [Any]

      case "Animations":
        result = try service.getAnimations(page: currentPage)["movies"] as! [Any]

      case "Anime":
        result = try service.getAnime(page: currentPage)["movies"] as! [Any]

      case "Shows":
        result = try service.getTvShows(page: currentPage)["movies"] as! [Any]

      case "Genres Group":
        let groupedGenres = try service.getGroupedGenres()

        let genresType = params["identifier"] as! String

        result = groupedGenres[genresType]!

      case "Genres":
        let path = selectedItem!.id

        result = try service.getMovies(path!, page: currentPage)["movies"] as! [Any]

      case "Popular":
        let groupedGenres = try service.getGroupedGenres()

        result = groupedGenres["top"]!

      case "Rating":
        let path = selectedItem!.id

        if path == "/podborka.html" {
          result = try service.getTags()
        }
        else {
          result = try service.getMoviesByCriteriaPaginated(path!, page: currentPage)["movies"] as! [Any]
        }

      case "Seasons":
        let path = selectedItem!.id!
        let name = selectedItem!.name!
        let thumb = selectedItem!.thumb!

        result = try service.getSeasons(path, serieName: name, thumb: thumb)

      case "Episodes":
        result = episodes

      case "Search":
        if !identifier!.isEmpty {
          result = try service.search(identifier!, page: currentPage)["movies"] as! [Any]
        }

      default:
        result = []
    }

    return convertToMediaItems(result)
  }

  func convertToMediaItems(_ items: [Any]) -> [MediaItem] {
    var newItems = [MediaItem]()

    for item in items {
      var jsonItem = item as? JSON

      if jsonItem == nil {
        jsonItem = JSON(item)
      }

      let movie = KinoKongMediaItem(data: jsonItem!)

      newItems += [movie]
    }

    return newItems
  }
}
