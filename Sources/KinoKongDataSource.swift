import SwiftSoup
import MediaApis
import TVSetKit

class KinoKongDataSource: DataSource {
  let service = KinoKongService.shared

  override open func load(params: Parameters) throws -> [Any] {
    var items: [Any] = []

    let selectedItem = params["selectedItem"] as? MediaItem

    var episodes = [KinoKongAPI.Episode]()

    var request = params["requestType"] as! String
    let currentPage = params["currentPage"] as? Int ?? 1

    if selectedItem?.type == "rating" {
      request = "Seasons"
    }
    else if selectedItem?.type == "serie" {
      request = "Seasons"
    }
    else if selectedItem?.type == "season" {
      request = "Episodes"

      if let selectedItem = selectedItem as? KinoKongMediaItem {
        episodes = selectedItem.episodes
      }
    }

    switch request {
    case "Bookmarks":
      if let bookmarksManager = params["bookmarksManager"] as? BookmarksManager,
         let bookmarks = bookmarksManager.bookmarks {
        bookmarks.load()
        let data = bookmarks.getBookmarks(pageSize: 60, page: currentPage)

        items = adjustItems(data)
      }

    case "History":
      if let historyManager = params["historyManager"] as? HistoryManager,
         let history = historyManager.history {
        history.load()
        let data = history.getHistoryItems(pageSize: 60, page: currentPage)

        items = adjustItems(data)
      }

    case "All Movies":
      let data = try service.getAllMovies(page: currentPage).items
      
      items = adjustItems(data)

    case "New Movies":
      let data = try service.getNewMovies(page: currentPage).items
      
      items = adjustItems(data)

    case "All Series":
      let data = try service.getAllSeries(page: currentPage).items
      
      items = adjustItems(data)

    case "Animations":
      let data = try service.getAnimations(page: currentPage).items
      
      items = adjustItems(data)

    case "Anime":
      let data = try service.getAnime(page: currentPage).items
      
      items = adjustItems(data)

    case "Shows":
      let data = try service.getTvShows(page: currentPage).items
     
      items = adjustItems(data)

    case "Genres Group":
      if let genresType = params["parentId"] as? String {
        let groupedGenres = try service.getGroupedGenres()

        if let data = groupedGenres[genresType] {
          items = adjustItems(data)
        }
      }

    case "Genres":
      if let selectedItem = selectedItem,
        let path = selectedItem.id {
         let data = try service.getMovies(path, page: currentPage).items
        
        items = adjustItems(data)
      }

    case "Popular":
      let groupedGenres = try service.getGroupedGenres()

      if let data = groupedGenres["top"] {
        items = adjustItems(data)
      }

    case "Rating":
      if let selectedItem = selectedItem,
         let path = selectedItem.id {
        if path == "/kino-podborka.html" {
          items = try service.getTags()
        }
        else {
          let data = try service.getMoviesByCriteriaPaginated(path, page: currentPage).items
          
          items = adjustItems(data)
        }
      }

    case "Seasons":
      if let selectedItem = selectedItem,
         let path = selectedItem.id {
        let playlistUrl = try service.getSeriePlaylistUrl(path)
        
        if !playlistUrl.isEmpty {
          let seasons = try service.getSeasons(playlistUrl, path: path)
        
          if let posterUrl = try service.getSeriePosterUrl("\(KinoKongAPI.SiteUrl)/\(path)") {
            selectedItem.thumb = posterUrl
          }
          
          items = adjustItems(seasons, selectedItem: selectedItem)
        }
      }

    case "Episodes":
      if let selectedItem = selectedItem {
        items = adjustItems(episodes, selectedItem: selectedItem)
      }

    case "Search":
      if let query = params["query"] as? String {
        if !query.isEmpty {
          let data = try service.search(query, page: currentPage).items
          
          items = adjustItems(data)
        }
      }

    default:
      items = []
    }

    return items
  }

  func adjustItems(_ items: [Any], selectedItem: MediaItem?=nil) -> [Item] {
    var newItems = [Item]()

    if let items = items as? [HistoryItem] {
      newItems = transform(items) { item in
        createHistoryItem(item as! HistoryItem)
      }
    }
    else if let items = items as? [BookmarkItem] {
      newItems = transform(items) { item in
        createBookmarkItem(item as! BookmarkItem)
      }
    }
    else if let items = items as? [KinoKongAPI.Season] {
      newItems = transformWithIndex(items) { (index, item) in
        let seasonNumber = String(index+1)
        
        return createSeasonItem(item as! KinoKongAPI.Season, selectedItem: selectedItem!, seasonNumber: seasonNumber)
      }
    }
    else if let items = items as? [KinoKongAPI.Episode] {
      newItems = transform(items) { item in
        createEpisodeItem(item as! KinoKongAPI.Episode, selectedItem: selectedItem!)
      }
    }
    else if let items = items as? [[String: Any]] {
      newItems = transform(items) { item in
        createMediaItem(item as! [String: Any])
      }
    }
    else if let items = items as? [Item] {
      newItems = items
    }

    return newItems
  }

  func createHistoryItem(_ item: HistoryItem) -> Item {
    let newItem = KinoKongMediaItem(data: ["name": ""])

    newItem.name = item.item.name
    newItem.id = item.item.id
    newItem.description = item.item.description
    newItem.thumb = item.item.thumb
    newItem.type = item.item.type

    return newItem
  }

  func createBookmarkItem(_ item: BookmarkItem) -> Item {
    let newItem = KinoKongMediaItem(data: ["name": ""])

    newItem.name = item.item.name
    newItem.id = item.item.id
    newItem.description = item.item.description
    newItem.thumb = item.item.thumb
    newItem.type = item.item.type

    return newItem
  }

    func createSeasonItem(_ item: KinoKongAPI.Season, selectedItem: MediaItem, seasonNumber: String) -> Item {
    let newItem = KinoKongMediaItem(data: ["name": ""])

    newItem.name = item.name
    
    if let path = selectedItem.id {
      newItem.id = path
    }
    
    newItem.type = "season"
    
    if let thumb = selectedItem.thumb {
      newItem.thumb = thumb
    }
    
    newItem.seasonNumber = seasonNumber
    newItem.episodes = item.playlist

    return newItem
  }

    func createEpisodeItem(_ item: KinoKongAPI.Episode, selectedItem: MediaItem) -> Item {
    let newItem = KinoKongMediaItem(data: ["name": ""])

    newItem.name = item.name
    newItem.id = item.files[0]
    newItem.type = "episode"
    newItem.files = item.files
        
    if let thumb = selectedItem.thumb {
      newItem.thumb = thumb
    }

    return newItem
  }

  func createMediaItem(_ item: [String: Any]) -> Item {
    let newItem = KinoKongMediaItem(data: ["name": ""])

    if let dict = item as? [String: String] {
      newItem.name = dict["name"]
      newItem.id = dict["id"]
      newItem.type = dict["type"]
      newItem.thumb = dict["thumb"]
    }

    return newItem
  }

}
