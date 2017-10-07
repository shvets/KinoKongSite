import SwiftyJSON
import SwiftSoup
import WebAPI
import TVSetKit

class KinoKongDataSource: DataSource {
  let service = KinoKongService.shared

  override open func load(params: Parameters) throws -> [Any] {
    var result : Any?

    let bookmarks = params["bookmarks"] as! Bookmarks
    let history = params["history"] as! History
    let selectedItem = params["selectedItem"] as? MediaItem

    var episodes = [KinoKongAPI.Episode]()

    var request = params["requestType"] as! String
    //let pageSize = params["pageSize"] as? Int
    let currentPage = params["currentPage"] as! Int

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
      if let genresType = params["parentId"] as? String {
        let groupedGenres = try service.getGroupedGenres()

        result = groupedGenres[genresType]!
      }

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

      let playlistUrl = try service.getSeriePlaylistUrl(path)

      result = try service.getSeasons(playlistUrl)

    case "Episodes":
      result = episodes

    case "Search":
      if let query = params["query"] as? String {
        if !query.isEmpty {
          result = try service.search(query, page: currentPage)["movies"] as! [Any]
        }
      }

    default:
      result = []
    }

    return convertToMediaItems(result as Any, selectedItem: selectedItem)
  }

  func convertToMediaItems(_ items: Any, selectedItem: MediaItem?) -> [MediaItem] {
    var newItems = [MediaItem]()

    if let seasons = items as? [KinoKongAPI.Season] {
      if let selectedItem = selectedItem {
        let path = selectedItem.id!
        let thumb = selectedItem.thumb!

        for (index, season) in seasons.enumerated() {
          let encoder = JSONEncoder()
          encoder.outputFormatting = .prettyPrinted

          if let data = try? encoder.encode(season) {
            let movie = KinoKongMediaItem(data: JSON(data))

            movie.name = season.name
            movie.type = "season"
            movie.id = path
            movie.thumb = thumb
            movie.seasonNumber = String(index+1)

            movie.episodes = season.playlist

            newItems += [movie]
          }
        }
      }

    }
    else if let episodes = items as? [KinoKongAPI.Episode] {
      if let selectedItem = selectedItem {
        let thumb = selectedItem.thumb!

        for episode in episodes {
          let movie = KinoKongMediaItem(data: JSON(Data()))

          movie.name = episode.name
          movie.type = "episode"
          movie.id = episode.files[0]
          movie.files = episode.files
          movie.thumb = thumb

          newItems += [movie]
        }
      }
    }
    else if let items = items as? [Any] {
      for item in items {
        var jsonItem = item as? JSON

        if jsonItem == nil {
          jsonItem = JSON(item)
        }

        let movie = KinoKongMediaItem(data: jsonItem!)

        newItems += [movie]
      }
    }

    return newItems
  }
}
