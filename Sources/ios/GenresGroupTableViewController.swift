import UIKit
import SwiftSoup
import WebAPI
import TVSetKit

class GenresGroupTableViewController: UITableViewController {
  static let SegueIdentifier = "Genres Group"
  let CellIdentifier = "GenreGroupTableCell"

  let localizer = Localizer(KinoKongServiceAdapter.BundleId, bundleClass: KinoKongSite.self)

  private var items: Items!

  override func viewDidLoad() {
    super.viewDidLoad()

    self.clearsSelectionOnViewWillAppear = false

    items = Items() {
      return self.loadGenresGroupMenu()
    }

    items.loadInitialData(tableView)
  }

   func loadGenresGroupMenu() -> [Item] {
    return [
      MediaName(name: "Movies"),
      MediaName(name: "Series"),
      MediaName(name: "Anime")
    ]
  }

  override open func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }

  override open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return items.count
  }

  override open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier, for: indexPath) as? MediaNameTableCell {
      let item = items[indexPath.row]

      cell.configureCell(item: item, localizedName: localizer.getLocalizedName(item.name))

      return cell
    }
    else {
      return UITableViewCell()
    }
  }

  override open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if let view = tableView.cellForRow(at: indexPath),
       let indexPath = tableView.indexPath(for: view) {
      performSegue(withIdentifier: GenresController.SegueIdentifier, sender: view)
    }
  }

  // MARK: - Navigation

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let identifier = segue.identifier {
      switch identifier {
        case GenresController.SegueIdentifier:
          if let destination = segue.destination as? GenresTableViewController,
             let selectedCell = sender as? MediaNameTableCell,
             let indexPath = tableView.indexPath(for: selectedCell) {

            let mediaItem = items.getItem(for: indexPath)
            
            switch mediaItem.name! {
            case "Movies":
              destination.parentId = "films"
              
            case "Series":
              destination.parentId = "serial"
              
            case "Anime":
              destination.parentId = "anime"
              
            default: break
            }

          }

        default: break
      }
    }
  }
}
