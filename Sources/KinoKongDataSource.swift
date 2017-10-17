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
      result = bookmarks.getBookmarks(pageSize: 60, page: currentPage)

    case "History":
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

  func convertToMediaItems(_ items: Any, selectedItem: MediaItem?) -> [Item] {
    var newItems = [Item]()

    if let items = items as? [KinoKongAPI.Season] {
      if let selectedItem = selectedItem {
        let path = selectedItem.id!
        let thumb = selectedItem.thumb!

        newItems = copySeasonsItems(items, path: path, thumb: thumb)
      }
    }
    else if let items = items as? [KinoKongAPI.Episode] {
      if let selectedItem = selectedItem {
        let thumb = selectedItem.thumb!

        newItems = copyEpisodesItems(items, thumb: thumb)
      }
    }
    else if let items = items as? [[String: Any]] {
      newItems = copyMediaItems(items)
    }
    else if let items = items as? [HistoryItem] {
      for item in items {
        let movie = KinoKongMediaItem(data: ["name": ""])

        movie.name = item.item.name
        movie.id = item.item.id
        movie.description = item.item.description
        movie.thumb = item.item.thumb
        movie.type = item.item.type

        newItems += [movie]
      }
    }
    else if let items = items as? [BookmarkItem] {
      for item in items {
        let movie = KinoKongMediaItem(data: ["name": ""])

        movie.name = item.item.name
        movie.id = item.item.id
        movie.description = item.item.description
        movie.thumb = item.item.thumb
        movie.type = item.item.type

        newItems += [movie]
      }
    }
    
    return newItems
  }

  func copySeasonsItems(_ items: [KinoKongAPI.Season], path: String, thumb: String) -> [KinoKongMediaItem] {
    var newItems: [KinoKongMediaItem] = []

    for (index, item) in items.enumerated() {
      let newItem = KinoKongMediaItem(data: ["name": ""])

      newItem.name = item.name
      newItem.id = path
      newItem.type = "season"
      newItem.thumb = thumb
      newItem.seasonNumber = String(index+1)
      newItem.episodes = item.playlist

      newItems.append(newItem)
    }

    return newItems
  }

  func copyEpisodesItems(_ items: [KinoKongAPI.Episode], thumb: String) -> [KinoKongMediaItem] {
    var newItems: [KinoKongMediaItem] = []

    for item in items {
      let newItem = KinoKongMediaItem(data: ["name": ""])

      newItem.name = item.name
      newItem.id = item.files[0]
      newItem.type = "episode"
      newItem.files = item.files
      newItem.thumb = thumb

      newItems.append(newItem)
    }

    return newItems
  }

  func copyMediaItems(_ items:  [[String: Any]] ) -> [KinoKongMediaItem] {
    var newItems: [KinoKongMediaItem] = []
    
    for item in items {
      let newItem = KinoKongMediaItem(data: ["name": ""])

      if let dict = item as? [String: String] {
        newItem.name = dict["name"]
        newItem.id = dict["id"]
        newItem.type = dict["type"]
        newItem.thumb = dict["thumb"]
      }

      newItems.append(newItem)
    }
    
    return newItems
  }
}
