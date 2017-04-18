import UIKit
import SwiftyJSON
import SwiftSoup
import WebAPI
import TVSetKit

class PopularTableViewController: KinoKongBaseTableViewController {
  static let SegueIdentifier = "Genres"

  override public var CellIdentifier: String { return "PopularTableCell" }

//  var document: Document?
//
//  override func viewDidLoad() {
//    super.viewDidLoad()
//
//    self.clearsSelectionOnViewWillAppear = false
//
//    do {
//      let genres = try service.getGenres(document!, type: adapter.parentId!) as! [[String: String]]
//
//      for genre in genres {
//        let item = MediaItem(name: localizer.localize(genre["name"]!), id: genre["id"]!)
//
//        items.append(item)
//      }
//    }
//    catch {
//      print("Error getting document")
//    }
//  }
//
//  override open func navigate(from view: UITableViewCell) {
//    performSegue(withIdentifier: MediaItemsController.SegueIdentifier, sender: view)
//  }
//
//  // MARK: - Navigation
//
//  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//    if let identifier = segue.identifier {
//      switch identifier {
//      case MediaItemsController.SegueIdentifier:
//        if let destination = segue.destination.getActionController() as? MediaItemsController,
//           let view = sender as? MediaNameTableCell {
//
//          let adapter = KinoKongServiceAdapter(mobile: true)
//
//          adapter.requestType = "Movies"
//          adapter.selectedItem = getItem(for: view)
//
//          destination.adapter = adapter
//        }
//
//      default: break
//      }
//    }
//  }

}
