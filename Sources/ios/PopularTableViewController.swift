import UIKit
import TVSetKit

class PopularTableViewController: UITableViewController {
  static let SegueIdentifier = "Popular"

  let CellIdentifier = "PopularTableCell"

#if os(iOS)
  public let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
#endif

  let localizer = Localizer(KinoKongService.BundleId, bundleClass: KinoKongSite.self)

  let service = KinoKongService(true)

  private var items = Items()

  override func viewDidLoad() {
    super.viewDidLoad()

    self.clearsSelectionOnViewWillAppear = false

    items.pageLoader.load = {
      var params = Parameters()
      params["requestType"] = "Popular"
      //params["pageSize"] = self.service.getConfiguration()["pageSize"] as! Int

      return try self.service.dataSource.load(params: params)
    }

    #if os(iOS)
      tableView?.backgroundView = activityIndicatorView
      items.pageLoader.spinner = PlainSpinner(activityIndicatorView)
    #endif
    
    items.loadInitialData(tableView)
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
    if let view = tableView.cellForRow(at: indexPath) {
      performSegue(withIdentifier: MediaItemsController.SegueIdentifier, sender: view)
    }
  }

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let identifier = segue.identifier {
      switch identifier {
        case MediaItemsController.SegueIdentifier:
          if let destination = segue.destination.getActionController() as? MediaItemsController,
             let view = sender as? MediaNameTableCell,
              let indexPath = tableView?.indexPath(for: view) {

            destination.params["requestType"] = "Rating"
            destination.params["selectedItem"] = items.getItem(for: indexPath)

            destination.configuration = service.getConfiguration()
          }

        default: break
      }
    }
  }

}
