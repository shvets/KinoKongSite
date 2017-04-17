import UIKit
import SwiftyJSON
import SwiftSoup
import WebAPI
import TVSetKit

class NewMoviesTableController: KinoKongBaseTableViewController {
  static let SegueIdentifier = "Themes"
  override open var CellIdentifier: String { return "ThemeTableCell" }

  let ThemesMenu = [
    "Top Seven",
    "New Movies",
    "Premiers"
  ]

  var document: Document?

  override func viewDidLoad() {
    super.viewDidLoad()

    self.clearsSelectionOnViewWillAppear = false

    adapter = KinoKongServiceAdapter(mobile: true)

    for name in ThemesMenu {
      let item = MediaItem(name: name)

      items.append(item)
    }
  }

  override open func navigate(from view: UITableViewCell) {
    performSegue(withIdentifier: MediaItemsController.SegueIdentifier, sender: view)
  }

  // MARK: - Navigation

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let identifier = segue.identifier {
      switch identifier {
        case MediaItemsController.SegueIdentifier:
          if let destination = segue.destination.getActionController() as? MediaItemsController,
             let view = sender as? MediaNameTableCell {

            let adapter = KinoKongServiceAdapter(mobile: true)

            adapter.requestType = "Themes"
            adapter.selectedItem = getItem(for: view)

            destination.adapter = adapter
          }

        default: break
      }
    }
  }

}
