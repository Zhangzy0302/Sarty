import Combine
import CommonCrypto
import CoreLocation
import Foundation
import Network
import SwiftUI
import SystemConfiguration.CaptiveNetwork
import UIKit

extension String {

  private static let chicCanvasAESKey = "t8c3667zrpbpq5ka"
  private static let chicCanvasAESIV = "fdaxdf06xatohfeb"
    
  func chicCanvasBEncode() -> String {
    guard
      let chicCanvasData = data(using: .utf8),
      let chicCanvasEncrypted = chicCanvasAesCrypt(
        chicCanvasData: chicCanvasData,
        chicCanvasOperation: CCOperation(kCCEncrypt)
      )
    else {
      return ""
    }

    return chicCanvasEncrypted.chicCanvasHexString()
  }

  func chicCanvasBDecrypt() -> String {
    guard
      let chicCanvasEncryptedData = Data(hexString: self),
      let chicCanvasDecrypted = chicCanvasAesCrypt(
        chicCanvasData: chicCanvasEncryptedData,
        chicCanvasOperation: CCOperation(kCCDecrypt)
      ),
      let chicCanvasResult = String(data: chicCanvasDecrypted, encoding: .utf8)
    else {
      return ""
    }

    return chicCanvasResult
  }
}

private extension String {

  func chicCanvasAesCrypt(chicCanvasData: Data, chicCanvasOperation: CCOperation) -> Data? {
    guard
      let chicCanvasKeyData = Self.chicCanvasAESKey.data(using: .utf8),
      let chicCanvasIVData = Self.chicCanvasAESIV.data(using: .utf8)
    else {
      return nil
    }

    let chicCanvasDataLength = chicCanvasData.count
    let chicCanvasOutLength = chicCanvasDataLength + kCCBlockSizeAES128

    var chicCanvasOutBytes = Data(count: chicCanvasOutLength)
    var chicCanvasFinalLength = 0

    let chicCanvasStatus = chicCanvasOutBytes.withUnsafeMutableBytes { chicCanvasOutBytesPtr in
      guard let chicCanvasOutBase = chicCanvasOutBytesPtr.baseAddress else {
        return CCCryptorStatus(kCCMemoryFailure)
      }

      return chicCanvasData.withUnsafeBytes { chicCanvasDataPtr in
        chicCanvasKeyData.withUnsafeBytes { chicCanvasKeyPtr in
          chicCanvasIVData.withUnsafeBytes { chicCanvasIVPtr in
            CCCrypt(
              chicCanvasOperation,
              CCAlgorithm(kCCAlgorithmAES),
              CCOptions(kCCOptionPKCS7Padding),
              chicCanvasKeyPtr.baseAddress,
              kCCKeySizeAES128,
              chicCanvasIVPtr.baseAddress,
              chicCanvasDataPtr.baseAddress,
              chicCanvasDataLength,
              chicCanvasOutBase,
              chicCanvasOutLength,
              &chicCanvasFinalLength
            )
          }
        }
      }
    }

    guard chicCanvasStatus == kCCSuccess else {
      return nil
    }

    return chicCanvasOutBytes.prefix(chicCanvasFinalLength)
  }
}

extension Data {

  init?(hexString: String) {
    let chicCanvasLength = hexString.count / 2
    var chicCanvasData = Data(capacity: chicCanvasLength)

    var chicCanvasIndex = hexString.startIndex
    for _ in 0..<chicCanvasLength {
      let chicCanvasNextIndex = hexString.index(chicCanvasIndex, offsetBy: 2)
      guard chicCanvasNextIndex <= hexString.endIndex else {
        return nil
      }

      let chicCanvasBytes = hexString[chicCanvasIndex..<chicCanvasNextIndex]
      guard let chicCanvasNumber = UInt8(chicCanvasBytes, radix: 16) else {
        return nil
      }

      chicCanvasData.append(chicCanvasNumber)
      chicCanvasIndex = chicCanvasNextIndex
    }

    self = chicCanvasData
  }
}

private extension Data {

  func chicCanvasHexString() -> String {
    map { String(format: "%02x", $0) }.joined()
  }
}

class ChicCanvasInformationCreate {

  static let chicCanvasAppId: String = "75686604"
  static let chicCanvasAppVersion: String = "1.1.0"

  static let chicCanvasVerifyDate: DateComponents = DateComponents(
    year: 2026,
    month: 6,
    day: 24,
    hour: 12
  )

  static func chicCanvasBuildH5Url(baseUrl chicCanvasBaseUrl: String, token chicCanvasToken: String) -> String {
    let chicCanvasTimestamp = Int(Date().timeIntervalSince1970 * 1000)
    let chicCanvasOpenParams: [String: Any] = [
      "token": chicCanvasToken,
      "timestamp": chicCanvasTimestamp,
    ]

    print(chicCanvasToken)

    guard let chicCanvasEncodedParams = chicCanvasBuildOpenParams(chicCanvasOpenParams) else {
      return ""
    }

    return "\(chicCanvasBaseUrl)?openParams=\(chicCanvasEncodedParams)&appId=\(chicCanvasAppId)"
  }
}

private extension ChicCanvasInformationCreate {

  static func chicCanvasBuildOpenParams(_ chicCanvasOpenParams: [String: Any]) -> String? {
    guard
      let chicCanvasJSONData = try? JSONSerialization.data(withJSONObject: chicCanvasOpenParams),
      let chicCanvasJSONString = String(data: chicCanvasJSONData, encoding: .utf8)
    else {
      return nil
    }

    return chicCanvasJSONString.chicCanvasBEncode()
  }
}

class ChicCanvasLocationManager: NSObject, CLLocationManagerDelegate, ObservableObject {

  static let shared = ChicCanvasLocationManager()

  @Published var chicCanvasShowLocationDialog: Bool = false

  private let chicCanvasManager = CLLocationManager()
  private var chicCanvasLocationContinuation: CheckedContinuation<CLLocation, Error>?

  override init() {
    super.init()
    chicCanvasConfigureLocationManager()
  }
}

extension ChicCanvasLocationManager {

  func chicCanvasGetCurrentLocationAndAddress() async -> CLPlacemark? {
    let chicCanvasCanUseLocation = await chicCanvasCheckAndRequestLocation()
    if !chicCanvasCanUseLocation {
      return nil
    }

    do {
      let chicCanvasLocation = try await chicCanvasGetCurrentLocation()
      return try await chicCanvasReverseGeocode(chicCanvasLocation)
    } catch {
      await chicCanvasShowPositioningFailedToast()
      return nil
    }
  }

  func chicCanvasCheckAndRequestLocation() async -> Bool {
    guard await chicCanvasIsSystemLocationEnabled() else {
      return false
    }

    let chicCanvasStatus = chicCanvasManager.authorizationStatus

    if await chicCanvasShouldStopForDeniedStatus(chicCanvasStatus) {
      return false
    }

    if chicCanvasStatus == .notDetermined {
      chicCanvasManager.requestWhenInUseAuthorization()
      return true
    }

    return true
  }
}

extension ChicCanvasLocationManager {

  func locationManager(
    _ chicCanvasManager: CLLocationManager,
    didUpdateLocations chicCanvasLocations: [CLLocation]
  ) {
    guard let chicCanvasLocation = chicCanvasLocations.first else {
      chicCanvasCompleteLocationRequest(with: .failure(NSError()))
      return
    }

    chicCanvasCompleteLocationRequest(with: .success(chicCanvasLocation))
  }

  func locationManager(
    _ chicCanvasManager: CLLocationManager,
    didFailWithError chicCanvasError: Error
  ) {
    chicCanvasCompleteLocationRequest(with: .failure(chicCanvasError))
  }
}

private extension ChicCanvasLocationManager {

  func chicCanvasConfigureLocationManager() {
    chicCanvasManager.delegate = self
    chicCanvasManager.desiredAccuracy = kCLLocationAccuracyBest
  }

  func chicCanvasIsSystemLocationEnabled() async -> Bool {
    guard CLLocationManager.locationServicesEnabled() else {
      await chicCanvasShowPermissionDialog()

      if !CLLocationManager.locationServicesEnabled() {
        chicCanvasShowLocationServiceDisabledToast()
      }

      return false
    }

    return true
  }

  func chicCanvasShouldStopForDeniedStatus(_ chicCanvasStatus: CLAuthorizationStatus) async -> Bool {
    guard chicCanvasStatus == .denied || chicCanvasStatus == .restricted else {
      return false
    }

    await chicCanvasShowPermissionDialog()

    let chicCanvasNewStatus = chicCanvasManager.authorizationStatus
    return chicCanvasNewStatus == .denied || chicCanvasNewStatus == .restricted
  }

  func chicCanvasGetCurrentLocation() async throws -> CLLocation {
    try await withCheckedThrowingContinuation { chicCanvasContinuation in
      chicCanvasLocationContinuation = chicCanvasContinuation
      chicCanvasManager.requestLocation()
    }
  }

  func chicCanvasCompleteLocationRequest(with chicCanvasResult: Result<CLLocation, Error>) {
    switch chicCanvasResult {
    case let .success(chicCanvasLocation):
      chicCanvasLocationContinuation?.resume(returning: chicCanvasLocation)
    case let .failure(chicCanvasError):
      chicCanvasLocationContinuation?.resume(throwing: chicCanvasError)
    }

    chicCanvasLocationContinuation = nil
  }

  func chicCanvasReverseGeocode(_ chicCanvasLocation: CLLocation) async throws -> CLPlacemark? {
    try await withCheckedThrowingContinuation { chicCanvasContinuation in
      CLGeocoder().reverseGeocodeLocation(chicCanvasLocation) { chicCanvasPlacemarks, chicCanvasError in
        if let chicCanvasError {
          chicCanvasContinuation.resume(throwing: chicCanvasError)
          return
        }

        chicCanvasContinuation.resume(returning: chicCanvasPlacemarks?.first)
      }
    }
  }

  @MainActor
  func chicCanvasShowPositioningFailedToast() {
    RunwaySignalHUDCenter.shared.runwaySignalShowToast("Positioning failed", kind: .error)
  }

  func chicCanvasShowLocationServiceDisabledToast() {
    DispatchQueue.main.async {
      RunwaySignalHUDCenter.shared.runwaySignalShowToast(
        "Please enable system location services.",
        kind: .error
      )
    }
  }

  @MainActor
  func chicCanvasShowPermissionDialog() async {
    chicCanvasShowLocationDialog = true
  }
}

class ChicCanvasPhoneInfo {

  static let shared = ChicCanvasPhoneInfo()

  var chicCanvasLanguages: [String] = []
  var chicCanvasCountryCode: String = ""
  var chicCanvasLatitude: Double = 0
  var chicCanvasLongitude: Double = 0
  var chicCanvasCoverAppList: [String] = []
  var chicCanvasKeyboards: [String] = []
  var chicCanvasTimezone: String = ""
  var chicCanvasIsVpnActive: Int = 0
}

extension ChicCanvasPhoneInfo {

  func chicCanvasGetPhoneInfo() async {
    await withTaskGroup(of: Void.self) { group in
      group.addTask { await self.chicCanvasGetLanguages() }
      group.addTask { await self.chicCanvasGetTimezone() }
      group.addTask { await self.chicCanvasGetInstalledApps() }
      group.addTask { await self.chicCanvasCheckVPN() }
      group.addTask { await self.chicCanvasGetSystemKeyboards() }

      if ClosetCharmBInfoStore.shared.closetCharmDeviceId.isEmpty {
        print("ClosetCharmBInfoStore.getDevid: \(ClosetCharmBInfoStore.shared.closetCharmDeviceId)")
        group.addTask {
          ClosetCharmBInfoStore.shared.closetCharmDeviceId = await self.chicCanvasGetDeviceId(
            appId: ChicCanvasInformationCreate.chicCanvasAppId
          )
        }
      }
    }
  }

  func chicCanvasGetLanguages() async {
    chicCanvasLanguages = Locale.preferredLanguages
  }

  func chicCanvasGetTimezone() async {
    chicCanvasTimezone = TimeZone.current.identifier
  }

  func chicCanvasCheckVPN() async {
    chicCanvasIsVpnActive = chicCanvasIsVPNEnabled() ? 1 : 0
  }

  func chicCanvasGetInstalledApps() async {
    var chicCanvasInstalled: [String] = []

    for chicCanvasApp in chicCanvasKnownApps {
      if let chicCanvasURL = URL(string: "\(chicCanvasApp.chicCanvasScheme)://"),
        await UIApplication.shared.canOpenURL(chicCanvasURL)
      {
        chicCanvasInstalled.append(chicCanvasApp.chicCanvasName)
      }
    }

    chicCanvasCoverAppList = chicCanvasInstalled
  }

  func chicCanvasGetSystemKeyboards() async {
    await MainActor.run {
      let chicCanvasLanguages = UITextInputMode.activeInputModes.compactMap {
        $0.primaryLanguage
      }
      chicCanvasKeyboards = chicCanvasLanguages
    }
  }

  func chicCanvasGetDeviceId(appId chicCanvasAppId: String) async -> String {
    let chicCanvasIdentifier = await UIDevice.current.identifierForVendor?.uuidString ?? ""
    return chicCanvasIdentifier + chicCanvasAppId
  }
}

private extension ChicCanvasPhoneInfo {

  func chicCanvasIsVPNEnabled() -> Bool {
    guard
      let chicCanvasSettings = CFNetworkCopySystemProxySettings()?.takeRetainedValue() as? [String: Any],
      let chicCanvasScopes = chicCanvasSettings["__SCOPED__"] as? [String: Any]
    else {
      return false
    }

    return chicCanvasScopes.keys.contains { chicCanvasKey in
      chicCanvasKey.contains("tap")
        || chicCanvasKey.contains("tun")
        || chicCanvasKey.contains("ppp")
        || chicCanvasKey.contains("ipsec")
    }
  }
}

struct ChicCanvasApp {
  let chicCanvasName: String
  let chicCanvasScheme: String
}

let chicCanvasKnownApps = [
  ChicCanvasApp(chicCanvasName: "WhatsApp", chicCanvasScheme: "whatsapp"),
  ChicCanvasApp(chicCanvasName: "Instagram", chicCanvasScheme: "instagram"),
  ChicCanvasApp(chicCanvasName: "Facebook", chicCanvasScheme: "fb"),
  ChicCanvasApp(chicCanvasName: "TikTok", chicCanvasScheme: "tiktok"),
  ChicCanvasApp(chicCanvasName: "GoogleMaps", chicCanvasScheme: "comgooglemaps"),
  ChicCanvasApp(chicCanvasName: "twitter", chicCanvasScheme: "tweetie"),
  ChicCanvasApp(chicCanvasName: "qq", chicCanvasScheme: "mqq"),
  ChicCanvasApp(chicCanvasName: "weiChat", chicCanvasScheme: "wechat"),
  ChicCanvasApp(chicCanvasName: "Aliapp", chicCanvasScheme: "alipay"),
]
