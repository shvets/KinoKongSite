import UIKit
import SwiftyJSON
import SwiftSoup
import WebAPI
import TVSetKit

class PopularGroupController: KinoKongBaseCollectionViewController {
  static let SegueIdentifier = "Popular Group"

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

  override open func tapped(_ gesture: UITapGestureRecognizer) {
    performSegue(withIdentifier: GenresController.SegueIdentifier, sender: view)
  }

  // MARK: - Navigation

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let identifier = segue.identifier {
      switch identifier {
        case GenresController.SegueIdentifier:
          if let destination = segue.destination as? GenresTableViewController,
             let selectedCell = sender as? MediaNameCell {
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
