import CoreLocation
import Foundation
import SwiftUI
import UIKit
import Combine

enum VogueVistaBRoute {
  case vogueVistaAgreement(vogueVistaURL: String)
}

final class VogueVistaInitUtils {

  static let shared = VogueVistaInitUtils()
  private init() {}

  var vogueVistaApiCallResponse: [String: Any]?
  var vogueVistaShouldFetchLocation: Bool = true
}

extension VogueVistaInitUtils {

  func vogueVistaFetchDecision() async {
    do {
      vogueVistaApiCallResponse = try await TrendThreadApiCall().trendThreadGetDecision()
    } catch {
      // 忽略错误（与原逻辑一致）
    }
  }

  func vogueVistaGoLogin() async -> VogueVistaBRoute? {
    do {
      if vogueVistaShouldFetchLocation {
        try await vogueVistaHandleLocation()
      }

      guard let vogueVistaResponse = try await TrendThreadApiCall().trendThreadQuickLogin() else {
        await vogueVistaShowErrorToast("error")
        return nil
      }

      return await vogueVistaProcessLoginResponse(vogueVistaResponse)
    } catch {
      await vogueVistaShowErrorToast("error")
      return nil
    }
  }

  func vogueVistaHandleLocation() async throws {
    guard
      let vogueVistaPlacemark = await ChicCanvasLocationManager.shared
        .chicCanvasGetCurrentLocationAndAddress()
    else {
      throw NSError(domain: "LocationError", code: -1)
    }

    if let vogueVistaLocation = vogueVistaPlacemark.location {
      ChicCanvasPhoneInfo.shared.chicCanvasLatitude = vogueVistaLocation.coordinate.latitude
      ChicCanvasPhoneInfo.shared.chicCanvasLongitude = vogueVistaLocation.coordinate.longitude
    }
  }

  func vogueVistaProcessLoginResponse(_ vogueVistaResponse: [String: Any]) async -> VogueVistaBRoute? {
    guard let vogueVistaCode = vogueVistaResponse["code"] as? String else {
      return nil
    }

    guard vogueVistaCode == "0000" else {
      await vogueVistaShowErrorToast("Login Error")
      return nil
    }

    guard let vogueVistaResultDict = vogueVistaDecryptResponseResult(vogueVistaResponse) else {
      return nil
    }

    await vogueVistaUpdateUserState(vogueVistaResultDict)

    let vogueVistaURL = vogueVistaBuildCurrentH5RouteURL()
    print("h5url: \(vogueVistaURL) ------end")

    return VogueVistaBRoute.vogueVistaAgreement(vogueVistaURL: vogueVistaURL)
  }

  func vogueVistaUpdateUserState(_ vogueVistaResult: [String: Any]) async {
    if ClosetCharmBInfoStore.shared.closetCharmPassword.isEmpty,
      let vogueVistaPassword = vogueVistaResult["password"] as? String
    {
      ClosetCharmBInfoStore.shared.closetCharmPassword = vogueVistaPassword
    }

    if let vogueVistaToken = vogueVistaResult["token"] as? String {
      ClosetCharmAppStorage.closetCharmUserToken = vogueVistaToken
//        ClosetCharmBInfoStore.saveUserToken(token)
    }
  }

  func vogueVistaHandleDeviceAndPolling() async {
    await vogueVistaFetchDecision()

    let vogueVistaPollingInterval: UInt64 = 2_000_000_000
    let vogueVistaMaxErrorInterval: UInt64 = 10_000_000_000

    var vogueVistaElapsed: UInt64 = 0

    while vogueVistaApiCallResponse == nil {
      try? await Task.sleep(nanoseconds: vogueVistaPollingInterval)
      vogueVistaElapsed += vogueVistaPollingInterval

      await vogueVistaFetchDecision()

      if vogueVistaElapsed >= vogueVistaMaxErrorInterval {
        vogueVistaElapsed = 0
        await vogueVistaShowErrorToast("Network Error")
      }
    }
  }
}

private extension VogueVistaInitUtils {

  func vogueVistaDecryptResponseResult(_ vogueVistaResponse: [String: Any]) -> [String: Any]? {
    guard let vogueVistaResultEncrypted = vogueVistaResponse["result"] as? String else {
      return nil
    }

    let vogueVistaDecrypted = vogueVistaResultEncrypted.chicCanvasBDecrypt()

    guard let vogueVistaJSONData = vogueVistaDecrypted.data(using: .utf8),
      let vogueVistaResultDict = try? JSONSerialization.jsonObject(with: vogueVistaJSONData) as? [String: Any]
    else {
      return nil
    }

    return vogueVistaResultDict
  }

  func vogueVistaBuildCurrentH5RouteURL() -> String {
    ChicCanvasInformationCreate.chicCanvasBuildH5Url(
      baseUrl: ClosetCharmAppStorage.closetCharmH5Url,
      token: ClosetCharmAppStorage.closetCharmUserToken
    )
  }

  @MainActor
  func vogueVistaShowErrorToast(_ vogueVistaMessage: String) {
    RunwaySignalHUDCenter.shared.runwaySignalShowToast(vogueVistaMessage, kind: .error)
  }
}

enum VogueVistaInitStatus {
  case vogueVistaLoading
  case vogueVistaB
  case vogueVistaA
}

@MainActor
final class VogueVistaInitViewModel: ObservableObject {

  @Published var vogueVistaStatus: VogueVistaInitStatus = .vogueVistaLoading
  @Published var vogueVistaNextRoute: VogueVistaBRoute?

  private let vogueVistaInitUtils = VogueVistaInitUtils.shared
}

extension VogueVistaInitViewModel {

  // MARK: - 主入口
  func vogueVistaStartBInit() async {
    await ChicCanvasPhoneInfo.shared.chicCanvasGetPhoneInfo()
    await vogueVistaInitUtils.vogueVistaHandleDeviceAndPolling()
    await vogueVistaProcessApiResponse()
  }

  // 初始化流程（等价 initState）
  func vogueVistaInitFlow() async {
    guard vogueVistaIsPastVerifyDate() else {
      vogueVistaUpdateStatus(.vogueVistaA)
      return
    }

    ClosetCharmAppStorage.closetCharmIsB = false

    if !ClosetCharmAppStorage.closetCharmIsB {
      await vogueVistaStartBInit()
    } else {
      vogueVistaUpdateStatus(.vogueVistaB)
    }
  }
}

extension VogueVistaInitViewModel {

  //处理 API 响应
  func vogueVistaProcessApiResponse() async {
    guard vogueVistaIsResponseValid() else {
      vogueVistaSetFailureStatus()
      return
    }

    ClosetCharmAppStorage.closetCharmIsB = true

    let vogueVistaDecryptedData = vogueVistaDecryptResult()
    ClosetCharmAppStorage.closetCharmH5Url = vogueVistaDecryptedData["openValue"] as? String ?? ""

    if vogueVistaHasLoggedInBUser(vogueVistaDecryptedData) {
      let vogueVistaRoute = await vogueVistaBuildRedirectRoute()
      vogueVistaNextRoute = vogueVistaRoute
      vogueVistaUpdateStatus(.vogueVistaB)
    } else {
      await vogueVistaHandleLocationFlow(vogueVistaDecryptedData)
    }
  }

  //✅ 8️⃣ 成功跳转
  func vogueVistaBuildRedirectRoute() async -> VogueVistaBRoute {
    let vogueVistaURL = ChicCanvasInformationCreate.chicCanvasBuildH5Url(
      baseUrl: ClosetCharmAppStorage.closetCharmH5Url,
      token: ClosetCharmAppStorage.closetCharmUserToken
    )
    return VogueVistaBRoute.vogueVistaAgreement(vogueVistaURL: vogueVistaURL)
  }
}

private extension VogueVistaInitViewModel {

  //校验响应
  func vogueVistaIsResponseValid() -> Bool {
    guard let vogueVistaResponse = vogueVistaInitUtils.vogueVistaApiCallResponse else {
      return false
    }
    print(vogueVistaResponse)
    return (vogueVistaResponse["code"] as? String) == "0000"
  }

  //解密数据
  func vogueVistaDecryptResult() -> [String: Any] {
    guard let vogueVistaResultString = vogueVistaInitUtils.vogueVistaApiCallResponse?["result"] as? String
    else {
      return [:]
    }

    let vogueVistaDecryptedString = vogueVistaResultString.chicCanvasBDecrypt()

    guard let vogueVistaJSONData = vogueVistaDecryptedString.data(using: .utf8) else {
      return [:]
    }

    guard let vogueVistaResultDict = try? JSONSerialization.jsonObject(with: vogueVistaJSONData) as? [String: Any]
    else {
      return [:]
    }

    return vogueVistaResultDict
  }

  func vogueVistaHasLoggedInBUser(_ vogueVistaDecryptedData: [String: Any]) -> Bool {
    let vogueVistaLoginFlag = vogueVistaDecryptedData["loginFlag"] as? Int ?? 0
    return vogueVistaLoginFlag == 1 && !ClosetCharmAppStorage.closetCharmUserToken.isEmpty
  }

  //处理定位流程
  func vogueVistaHandleLocationFlow(_ vogueVistaDecryptedData: [String: Any]) async {
    let vogueVistaLocationFlag = vogueVistaDecryptedData["locationFlag"] as? Int ?? 0

    vogueVistaInitUtils.vogueVistaShouldFetchLocation = (vogueVistaLocationFlag == 1)

    if vogueVistaInitUtils.vogueVistaShouldFetchLocation {
      _ = await ChicCanvasLocationManager.shared.chicCanvasCheckAndRequestLocation()
    }

    vogueVistaUpdateStatus(.vogueVistaB)
  }

  //✅ 7️⃣ 失败状态
  func vogueVistaSetFailureStatus() {
    vogueVistaUpdateStatus(.vogueVistaA)
  }

  //✅ 9️⃣ 状态更新
  func vogueVistaUpdateStatus(_ vogueVistaNewStatus: VogueVistaInitStatus) {
    vogueVistaStatus = vogueVistaNewStatus
  }

  func vogueVistaIsPastVerifyDate() -> Bool {
    guard
      let vogueVistaTargetDate = Calendar.current.date(
        from: ChicCanvasInformationCreate.chicCanvasVerifyDate)
    else {
      return false
    }

    let vogueVistaCurrentDate = Date()
    return !(vogueVistaCurrentDate < vogueVistaTargetDate)
  }
}
