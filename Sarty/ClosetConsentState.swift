import SwiftUI

final class ClosetConsentState {

  private init() {}

  private static let defaults = UserDefaults.standard

  static var closetConsentAgree: Bool {
    get { defaults.bool(forKey: "closetConsentAgree") }
    set { defaults.set(newValue, forKey: "closetConsentAgree") }
  }
    
    static var closetConsentAgreeEULA: Bool {
      get { defaults.bool(forKey: "closetConsentAgreeEULA") }
      set { defaults.set(newValue, forKey: "closetConsentAgreeEULA") }
    }

}
