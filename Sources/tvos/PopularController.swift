import UIKit
import SwiftyJSON
import SwiftSoup
import WebAPI
import TVSetKit

class PopularController: KinoKongBaseCollectionViewController {
  static let SegueIdentifier = "Popular"

  override public var CellIdentifier: String { return "PopularCell" }

  override func viewDidLoad() {
    super.viewDidLoad()

    self.clearsSelectionOnViewWillAppear = false

    let layout = UICollectionViewFlowLayout()

    layout.itemSize = CGSize(width: 450, height: 150)
    layout.sectionInset = UIEdgeInsets(top: 150.0, left: 20.0, bottom: 50.0, right: 20.0)
    layout.minimumInteritemSpacing = 20.0
    layout.minimumLineSpacing = 100.0

    collectionView?.collectionViewLayout = layout

    collectionView?.backgroundView = activityIndicatorView
    adapter.spinner = PlainSpinner(activityIndicatorView)

    loadInitialData()
  }

  override open func navigate(from view: UICollectionViewCell, playImmediately: Bool=false) {
    performSegue(withIdentifier: MediaItemsController.SegueIdentifier, sender: view)
  }

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let identifier = segue.identifier {
      switch identifier {
        case MediaItemsController.SegueIdentifier:
          if let destination = segue.destination.getActionController() as? MediaItemsController,
             let view = sender as? MediaNameCell {

            let adapter = KinoKongServiceAdapter()

            adapter.requestType = "Rating"
            adapter.selectedItem = getItem(for: view)

            destination.adapter = adapter
            destination.collectionView?.collectionViewLayout = adapter.buildLayout()!
          }

        default: break
      }
    }
  }

}
