import UIKit
import SwiftyJSON
import SwiftSoup
import WebAPI
import TVSetKit

class PopularTableViewController: KinoKongBaseTableViewController {
  static let SegueIdentifier = "Popular"

  override public var CellIdentifier: String { return "PopularTableCell" }

  override func viewDidLoad() {
    super.viewDidLoad()

    self.clearsSelectionOnViewWillAppear = false

    loadInitialData()
  }

  override open func navigate(from view: UITableViewCell) {
    performSegue(withIdentifier: MediaItemsController.SegueIdentifier, sender: view)
  }

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let identifier = segue.identifier {
      switch identifier {
        case MediaItemsController.SegueIdentifier:
          if let destination = segue.destination.getActionController() as? MediaItemsController,
             let view = sender as? MediaNameTableCell {

            let adapter = KinoKongServiceAdapter(mobile: true)

            adapter.requestType = "Rating"
            adapter.selectedItem = getItem(for: view)

            destination.adapter = adapter
          }

        default: break
      }
    }
  }

}
