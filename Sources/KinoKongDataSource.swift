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

    print(selectedItem?.type)

    if selectedItem?.type == "serie" {
      request = "Seasons"
    }
    else if selectedItem?.type == "season" {
      request = "Episodes"
    }

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

      case "Genres Group":
        let groupedGenres = try service.getGroupedGenres()

        let genresType = params.identifier!

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
        let path = ""
        let name = ""
        let thumb = ""
        let playlistUrl = try service.getSeriePlaylistUrl(path)
        let serieInfo = try service.getSerieInfo(playlistUrl)

        var data = [Any]()

        for (index, item) in serieInfo.enumerated() {
          let seasonName = item["comment"]
            //.replace('<b>', '').replace('</b>', '')

          let episodes: [[String: String]] = []
          //json.dumps(episodes)
            //item["playlist"]

          data.append(["type": "season", "id": path, "name": seasonName, "serieName": name, "season": index+1,
                       "thumb": thumb, "episodes": episodes])
        }

      case "Episodes":
        print("episodes")

//        episode_name = episode['comment'].replace('<br>', ' ')
//      thumb = params['thumb']
//      url = episode['file']
//
//      new_params = {
//      'type': 'episode',
//      'id': json.dumps(url),
//      'name': episode_name,
//      'serieName': params['serieName'],
//      'thumb': thumb,
//      'season': params['season'],
//      'episode': episode,
//      'episodeNumber': index+1
//    }

//        result = try service.getEpisodes(selectedItem!.parentId!, seasonNumber: selectedItem!.id!, thumb: selectedItem?.thumb)

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
