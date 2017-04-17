import UIKit
import SwiftyJSON
import SwiftSoup
import WebAPI
import TVSetKit

class FiltersController: KinoKongBaseCollectionViewController {
  static let SegueIdentifier = "Filters"

  override open var CellIdentifier: String { return "FilterCell" }

  let FiltersMenu = [
    "By Actors",
    "By Directors",
    "By Countries",
    "By Years"
  ]

  var document: Document?

  override func viewDidLoad() {
    super.viewDidLoad()

    self.clearsSelectionOnViewWillAppear = false

    adapter = KinoKongServiceAdapter()

    let layout = UICollectionViewFlowLayout()

    layout.itemSize = CGSize(width: 450, height: 150)
    layout.sectionInset = UIEdgeInsets(top: 100.0, left: 20.0, bottom: 50.0, right: 20.0)
    layout.minimumInteritemSpacing = 10.0
    layout.minimumLineSpacing = 100.0

    collectionView?.collectionViewLayout = layout

    for name in FiltersMenu {
      let item = MediaItem(name: name)

      items.append(item)
    }
  }

  override open func tapped(_ gesture: UITapGestureRecognizer) {
    let selectedCell = gesture.view as! MediaNameCell

    let requestType = getItem(for: selectedCell).name

    if requestType == "By Actors" {
      performSegue(withIdentifier: LettersController.SegueIdentifier, sender: gesture.view)
    }
    else if requestType == "By Directors" {
      performSegue(withIdentifier: LettersController.SegueIdentifier, sender: gesture.view)
    }
    else if requestType == "By Countries" {
      performSegue(withIdentifier: CountriesController.SegueIdentifier, sender: gesture.view)
    }
    else if requestType == "By Years" {
      performSegue(withIdentifier: YearsController.SegueIdentifier, sender: gesture.view)
    }
  }

  // MARK: - Navigation

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let identifier = segue.identifier {
      switch identifier {
        case LettersController.SegueIdentifier:
          if let destination = segue.destination as? LettersController,
             let selectedCell = sender as? MediaNameCell {

            let requestType = getItem(for: selectedCell).name

            destination.document = document
            destination.requestType = requestType
          }
        case CountriesController.SegueIdentifier:
          if let destination = segue.destination as? CountriesController {
            destination.document = document
          }
        case YearsController.SegueIdentifier:
          if let destination = segue.destination as? YearsController {
            destination.document = document
          }
        default: break
      }
    }
  }

}
