import SwiftyJSON
import SwiftSoup
import WebAPI
import TVSetKit

class KinoKongDataSource: DataSource {
  let service = KinoKongService.shared

  func load(_ requestType: String, params: RequestParams, pageSize: Int, currentPage: Int) throws -> [MediaItem] {
    var result: [Any] = []

    let identifier = params.identifier
    let bookmarks = params.bookmarks!
    let history = params.history!
    let selectedItem = params.selectedItem

    var request = requestType

//    if selectedItem?.type == "serie" {
//      request = "Seasons"
//    }
//    else if selectedItem?.type == "season" {
//      request = "Episodes"
//    }

    switch request {
      case "Bookmarks":
        bookmarks.load()
        result = bookmarks.getBookmarks(pageSize: pageSize, page: currentPage)

      case "History":
        history.load()
        result = history.getHistoryItems(pageSize: pageSize, page: currentPage)

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

//      case "Genres":
//        result = try service.getGenres(document)
//


//      case "Seasons":
//        result = try service.getSeasons(identifier!, parentName: params.parentName!, thumb: selectedItem?.thumb)
//
//      case "Episodes":
//        result = try service.getEpisodes(selectedItem!.parentId!, seasonNumber: selectedItem!.id!, thumb: selectedItem?.thumb)
//
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
