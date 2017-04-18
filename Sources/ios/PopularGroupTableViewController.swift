import UIKit
import SwiftyJSON
import SwiftSoup
import WebAPI
import TVSetKit

class PopularGroupTableViewController: KinoKongBaseTableViewController {
  static let SegueIdentifier = "Genres Group"

  override open var CellIdentifier: String { return "PopularGroupTableCell" }

  let POPULAR_MENU = [
    "Movies",
    "Series",
    "Anime"
  ]

  override func viewDidLoad() {
    super.viewDidLoad()

    self.clearsSelectionOnViewWillAppear = false

    loadInitialData()
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
            adapter.requestType = "Genres Group"

            let mediaItem = getItem(for: selectedCell)

            switch mediaItem.name! {
              case "Movies":
                adapter.parentId = "films"

              case "Series":
                adapter.parentId = "serial"

              case "Anime":
                adapter.parentId = "anime"

              default: break
            }

            destination.adapter = adapter
          }

        default: break
      }
    }
  }
}
