import TVSetKit

open class KinoKongBaseTableViewController: BaseTableViewController {
  let service = KinoKongService.shared

  override open func viewDidLoad() {
    super.viewDidLoad()

    localizer = Localizer(KinoKongServiceAdapter.BundleId)
  }

}
