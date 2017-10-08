import UIKit
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

    self.clearsSelectionOnViewWillAppear = false

    loadData()
  }

  func loadData() {
    items.append(MediaName(name: "Bookmarks", imageName: "Star"))
    items.append(MediaName(name: "History", imageName: "Bookmark"))
    items.append(MediaName(name: "All Movies", imageName: "Retro TV"))
    items.append(MediaName(name: "New Movies", imageName: "Retro TV"))
    items.append(MediaName(name: "All Series", imageName: "Retro TV"))
    items.append(MediaName(name: "Animations", imageName: "Retro TV"))
    items.append(MediaName(name: "Anime", imageName: "Retro TV"))
    items.append(MediaName(name: "Shows", imageName: "Briefcase"))
    items.append(MediaName(name: "Genres", imageName: "Comedy"))
    items.append(MediaName(name: "Popular", imageName: "Briefcase"))
    items.append(MediaName(name: "Settings", imageName: "Engineering"))
    items.append(MediaName(name: "Search", imageName: "Search"))
  }

  override open func navigate(from view: UICollectionViewCell, playImmediately: Bool=false) {
    let mediaItem = getItem(for: view)

    switch mediaItem.name! {
      case "Genres":
        performSegue(withIdentifier: GenresGroupController.SegueIdentifier, sender: view)

      case "Popular":
        performSegue(withIdentifier: PopularController.SegueIdentifier, sender: view)

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
        case PopularController.SegueIdentifier:
          if let destination = segue.destination as? PopularController {
            let adapter = KinoKongServiceAdapter()
            adapter.params["requestType"] = "Popular"

            destination.adapter = adapter
          }
        
        case MediaItemsController.SegueIdentifier:
          if let destination = segue.destination.getActionController() as? MediaItemsController,
             let view = sender as? MediaNameCell {

            let mediaItem = getItem(for: view)

            let adapter = KinoKongServiceAdapter()

            adapter.params["requestType"] = mediaItem.name
            adapter.params["parentName"] = localizer.localize(mediaItem.name!)

            destination.adapter = adapter
            destination.collectionView?.collectionViewLayout = adapter.buildLayout()!
          }

        case SearchController.SegueIdentifier:
          if let destination = segue.destination.getActionController() as? SearchController {

            let adapter = KinoKongServiceAdapter()

            adapter.params["requestType"] = "Search"
            adapter.params["parentName"] = localizer.localize("Search Results")

            destination.adapter = adapter
          }

        default:
          break
      }
    }
   }

}
