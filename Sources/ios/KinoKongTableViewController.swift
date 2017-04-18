import UIKit
import SwiftyJSON
import SwiftSoup
import WebAPI
import TVSetKit

open class KinoKongTableViewController: KinoKongBaseTableViewController {
  override open var CellIdentifier: String { return "KinoKongTableCell" }

  var document: Document?

  override open func viewDidLoad() {
    super.viewDidLoad()

    self.clearsSelectionOnViewWillAppear = false

    title = localizer.localize("KinoKong")

    self.clearsSelectionOnViewWillAppear = false

    loadData()
  }

  func loadData() {
    items.append(MediaItem(name: "Bookmarks", imageName: "Star"))
    items.append(MediaItem(name: "History", imageName: "Bookmark"))
    items.append(MediaItem(name: "All Movies", imageName: "Retro TV"))
    items.append(MediaItem(name: "New Movies", imageName: "Retro TV"))
    items.append(MediaItem(name: "All Series", imageName: "Retro TV"))
    items.append(MediaItem(name: "Animations", imageName: "Retro TV"))
    items.append(MediaItem(name: "Anime", imageName: "Retro TV"))
    items.append(MediaItem(name: "Shows", imageName: "Briefcase"))
    items.append(MediaItem(name: "Genres", imageName: "Comedy"))
    items.append(MediaItem(name: "Popular", imageName: "Briefcase"))
    items.append(MediaItem(name: "Settings", imageName: "Engineering"))
    items.append(MediaItem(name: "Search", imageName: "Search"))
  }

  override open func navigate(from view: UITableViewCell) {
    let mediaItem = getItem(for: view)

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

  // MARK: - Navigation

  override open func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let identifier = segue.identifier {
      switch identifier {
        case PopularTableViewController.SegueIdentifier:
          if let destination = segue.destination as? PopularTableViewController {
            let adapter = KinoKongServiceAdapter(mobile: true)
            adapter.requestType = "Popular"

            destination.adapter = adapter
          }

        case MediaItemsController.SegueIdentifier:
          if let destination = segue.destination.getActionController() as? MediaItemsController,
             let view = sender as? MediaNameTableCell {

            let mediaItem = getItem(for: view)

            let adapter = KinoKongServiceAdapter(mobile: true)

            adapter.requestType = mediaItem.name
            adapter.parentName = localizer.localize(mediaItem.name!)

            destination.adapter = adapter
          }

        case SearchTableController.SegueIdentifier:
          if let destination = segue.destination.getActionController() as? SearchTableController {

            let adapter = KinoKongServiceAdapter(mobile: true)

            adapter.requestType = "Search"
            adapter.parentName = localizer.localize("Search Results")

            destination.adapter = adapter
          }

        default:
          break
      }
    }
  }

}
