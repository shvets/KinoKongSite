import UIKit
import SwiftyJSON
import SwiftSoup
import WebAPI
import TVSetKit

class GenresGroupController: KinoKongBaseCollectionViewController {
  static let SegueIdentifier = "Genres Group"

  override open var CellIdentifier: String { return "GenreGroupCell" }

  let GENRES_MENU = [
    "Movies",
    "Series",
    "Anime"
  ]

  override func viewDidLoad() {
    super.viewDidLoad()

    self.clearsSelectionOnViewWillAppear = false

    let layout = UICollectionViewFlowLayout()

    layout.itemSize = CGSize(width: 450, height: 150)
    layout.sectionInset = UIEdgeInsets(top: 100.0, left: 20.0, bottom: 50.0, right: 20.0)
    layout.minimumInteritemSpacing = 10.0
    layout.minimumLineSpacing = 100.0

    collectionView?.collectionViewLayout = layout

    adapter = KinoKongServiceAdapter()

    for name in GENRES_MENU {
      let item = MediaItem(name: name)

      items.append(item)
    }
  }

  override open func tapped(_ gesture: UITapGestureRecognizer) {
    performSegue(withIdentifier: GenresController.SegueIdentifier, sender: gesture.view)
  }

  // MARK: - Navigation

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let identifier = segue.identifier {
      switch identifier {
        case GenresController.SegueIdentifier:
          if let destination = segue.destination as? GenresController,
             let selectedCell = sender as? MediaNameCell {
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
