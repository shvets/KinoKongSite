import WebAPI

public class KinoKongService {

  static let shared: KinoKongAPI = {
    return KinoKongAPI()
  }()

}
