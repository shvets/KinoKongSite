import UIKit
import TVSetKit

class GenresTableViewController: UITableViewController {
  static let SegueIdentifier = "Genres"
  let CellIdentifier = "GenreTableCell"

#if os(iOS)
  public let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
#endif

  let localizer = Localizer(KinoKongServiceAdapter.BundleId, bundleClass: KinoKongSite.self)

  var parentId: String?

  private var items = Items()

  override func viewDidLoad() {
    super.viewDidLoad()

    self.clearsSelectionOnViewWillAppear = false

    title = localizer.localize("Genres")

    items.pageLoader.load = {
      let adapter = KinoKongServiceAdapter(mobile: true)
      adapter.params["requestType"] = "Genres Group"
      adapter.params["parentId"] = self.parentId

      return try adapter.load()
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

  // MARK: - Navigation

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let identifier = segue.identifier {
      switch identifier {
        case MediaItemsController.SegueIdentifier:
          if let destination = segue.destination.getActionController() as? MediaItemsController,
             let view = sender as? MediaNameTableCell,
             let indexPath = tableView.indexPath(for: view) {

            let adapter = KinoKongServiceAdapter(mobile: true)

            destination.params["requestType"] = "Genres"
            adapter.params["selectedItem"] = items.getItem(for: indexPath)

            destination.adapter = adapter
            destination.configuration = adapter.getConfiguration()
          }

        default: break
      }
    }
  }

}
