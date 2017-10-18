import UIKit
import TVSetKit

open class KinoKongTableViewController: UITableViewController {
  let CellIdentifier = "KinoKongTableCell"

  let localizer = Localizer(KinoKongServiceAdapter.BundleId, bundleClass: KinoKongSite.self)

  private var items = Items()

  override open func viewDidLoad() {
    super.viewDidLoad()

    self.clearsSelectionOnViewWillAppear = false

    title = localizer.localize("KinoKong")

    items.pageLoader.load = {
      return self.getMenuItems()
    }

    items.loadInitialData(tableView)
  }

  func getMenuItems() -> [Item] {
    return [
      MediaName(name: "Bookmarks", imageName: "Star"),
      MediaName(name: "History", imageName: "Bookmark"),
      MediaName(name: "All Movies", imageName: "Retro TV"),
      MediaName(name: "New Movies", imageName: "Retro TV"),
      MediaName(name: "All Series", imageName: "Retro TV"),
      MediaName(name: "Animations", imageName: "Retro TV"),
      MediaName(name: "Anime", imageName: "Retro TV"),
      MediaName(name: "Shows", imageName: "Briefcase"),
      MediaName(name: "Genres", imageName: "Comedy"),
      MediaName(name: "Popular", imageName: "Briefcase"),
      MediaName(name: "Settings", imageName: "Engineering"),
      MediaName(name: "Search", imageName: "Search")
    ]
  }

  // MARK: UITableViewDataSource

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

//      let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.longPressed(_:)))
//      tableView.addGestureRecognizer(longPressRecognizer)

      return cell
    }
    else {
      return UITableViewCell()
    }
  }

  override open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if let view = tableView.cellForRow(at: indexPath),
      let indexPath = tableView.indexPath(for: view) {
      let mediaItem = items.getItem(for: indexPath)

      switch mediaItem.name! {
        case "Genres":
          performSegue(withIdentifier: GenresGroupTableViewController.SegueIdentifier, sender: view)

        case "Popular":
          performSegue(withIdentifier: PopularTableViewController.SegueIdentifier, sender: view)

        case "Settings":
          performSegue(withIdentifier: "Settings", sender: view)

        case "Search":
          performSegue(withIdentifier: SearchTableController.SegueIdentifier, sender: view)

        default:
          performSegue(withIdentifier: MediaItemsController.SegueIdentifier, sender: view)
      }
    }
  }

  // MARK: - Navigation

  override open func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let identifier = segue.identifier {
      switch identifier {
        case MediaItemsController.SegueIdentifier:
          if let destination = segue.destination.getActionController() as? MediaItemsController,
             let view = sender as? MediaNameTableCell,
             let indexPath = tableView.indexPath(for: view) {

            let mediaItem = items.getItem(for: indexPath)

            let adapter = KinoKongServiceAdapter(mobile: true)

            destination.params["requestType"] = mediaItem.name
            destination.params["parentName"] = localizer.localize(mediaItem.name!)

            destination.adapter = adapter
            destination.configuration = adapter.getConfiguration()
          }

        case SearchTableController.SegueIdentifier:
          if let destination = segue.destination.getActionController() as? SearchTableController {
            let adapter = KinoKongServiceAdapter(mobile: true)

            destination.params["requestType"] = "Search"
            destination.params["parentName"] = localizer.localize("Search Results")

            destination.adapter = adapter
            destination.configuration = adapter.getConfiguration()
          }

        default:
          break
      }
    }
  }

}
