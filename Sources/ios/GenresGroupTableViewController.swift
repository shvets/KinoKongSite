import UIKit
import SwiftyJSON
import SwiftSoup
import WebAPI
import TVSetKit

class GenresGroupTableViewController: KinoKongBaseTableViewController {
  static let SegueIdentifier = "Genres Group"

  override open var CellIdentifier: String { return "GenreGroupTableCell" }

  let GENRES_MENU = [
    "Movies",
    "Series",
    "Anime"
  ]

  override func viewDidLoad() {
    super.viewDidLoad()

    self.clearsSelectionOnViewWillAppear = false

    adapter = KinoKongServiceAdapter(mobile: true)

    for name in GENRES_MENU {
      let item = MediaItem(name: name)

      items.append(item)
    }
  }

  override open func navigate(from view: UITableViewCell) {
    performSegue(withIdentifier: GenresController.SegueIdentifier, sender: view)
  }

  // MARK: - Navigation

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let identifier = segue.identifier {
      switch identifier {
        case GenresController.SegueIdentifier:
          if let destination = segue.destination as? GenresTableViewController,
             let selectedCell = sender as? MediaNameTableCell {
            adapter.params.requestType = "Genres Group"

            let mediaItem = getItem(for: selectedCell)

            switch mediaItem.name! {
              case "Movies":
                adapter.params.parentId = "films"

              case "Series":
                adapter.params.parentId = "serial"

              case "Anime":
                adapter.params.parentId = "anime"

              default: break
            }

            destination.adapter = adapter
          }

        default: break
      }
    }
  }
}
