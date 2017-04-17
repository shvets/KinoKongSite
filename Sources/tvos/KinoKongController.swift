import UIKit
import SwiftyJSON
import SwiftSoup
import WebAPI
import TVSetKit

open class KinoKongController: KinoKongBaseCollectionViewController {
  override open var CellIdentifier: String { return "KinoKongCell" }

  var document: Document?

  override open func viewDidLoad() {
    super.viewDidLoad()

    self.clearsSelectionOnViewWillAppear = false

    let layout = UICollectionViewFlowLayout()

    layout.itemSize = CGSize(width: 450, height: 150)
    layout.sectionInset = UIEdgeInsets(top: 150.0, left: 20.0, bottom: 50.0, right: 20.0)
    layout.minimumInteritemSpacing = 20.0
    layout.minimumLineSpacing = 100.0

    collectionView?.collectionViewLayout = layout

    adapter = KinoKongServiceAdapter()

    self.clearsSelectionOnViewWillAppear = false

    loadData()
//    for name in MainMenuItems {
//      let item = MediaItem(name: name)
//
//      items.append(item)
//    }

    do {
      document = try service.fetchDocument(KinoKongAPI.SiteUrl)
    }
    catch {
      print("Cannot load document")
    }
  }

  func loadData() {
    items.append(MediaItem(name: "Bookmarks", imageName: "Star"))
    items.append(MediaItem(name: "History", imageName: "Bookmark"))
    items.append(MediaItem(name: "All Movies", imageName: "Retro TV"))
    items.append(MediaItem(name: "Genres", imageName: "Comedy"))
    items.append(MediaItem(name: "Themes", imageName: "Briefcase"))
    items.append(MediaItem(name: "Filters", imageName: "Filter"))
    items.append(MediaItem(name: "Settings", imageName: "Engineering"))
    items.append(MediaItem(name: "Search", imageName: "Search"))
  }

  override open func navigate(from view: UICollectionViewCell, playImmediately: Bool=false) {
    let mediaItem = getItem(for: view)

    switch mediaItem.name! {
      case "Genres":
        performSegue(withIdentifier: GenresGroupController.SegueIdentifier, sender: view)

      case "Themes":
        performSegue(withIdentifier: ThemesController.SegueIdentifier, sender: view)

      case "Filters":
        performSegue(withIdentifier: FiltersController.SegueIdentifier, sender: view)

      case "Settings":
        performSegue(withIdentifier: "Settings", sender: view)

      case "Search":
        performSegue(withIdentifier: SearchController.SegueIdentifier, sender: view)

      default:
        performSegue(withIdentifier: MediaItemsController.SegueIdentifier, sender: view)
    }
  }

  // MARK: - Navigation

  override open func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let identifier = segue.identifier {
      switch identifier {
        case GenresGroupController.SegueIdentifier:
          if let destination = segue.destination as? GenresGroupController {
            destination.document = document
          }

        case ThemesController.SegueIdentifier:
          if let destination = segue.destination as? ThemesController {
            destination.document = document
          }

        case FiltersController.SegueIdentifier:
          if let destination = segue.destination as? FiltersController {
            destination.document = document
          }

        case MediaItemsController.SegueIdentifier:
          if let destination = segue.destination.getActionController() as? MediaItemsController,
             let view = sender as? MediaNameCell {

            let mediaItem = getItem(for: view)

            let adapter = KinoKongServiceAdapter()

            adapter.requestType = mediaItem.name
            adapter.parentName = localizer.localize(mediaItem.name!)

            destination.adapter = adapter
            destination.collectionView?.collectionViewLayout = adapter.buildLayout()!
          }

        case SearchController.SegueIdentifier:
          if let destination = segue.destination.getActionController() as? SearchController {

            let adapter = KinoKongServiceAdapter()

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
