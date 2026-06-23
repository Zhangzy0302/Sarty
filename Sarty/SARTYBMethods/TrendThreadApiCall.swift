import AdjustSdk
import Alamofire
import Foundation
import StoreKit

final class TrendThreadApiCall {

  private enum trendThreadEndpoint {
    static let trendThreadPay = "/opi/v1/veAXcjyjDShjbsp"
    static let trendThreadDecision = "/opi/v1/dvqsfegAsdaakfbo"
    static let trendThreadQuickLogin = "/opi/v1/tdLKJHkjhajl"
    static let trendThreadLoadingTime = "/opi/v1/hfjkhsk/esdakjt"
  }

  private let trendThreadBaseURL = "https://opi.s03vifz3.link"

  private lazy var trendThreadSession: Session = {
    let trendThreadConfiguration = URLSessionConfiguration.default
    trendThreadConfiguration.headers = .default
    return Session(configuration: trendThreadConfiguration)
  }()
}

extension TrendThreadApiCall {

  func trendThreadPayCall(
    purchaseID: String,
    serverVerificationData: String,
    orderCode: String
  ) async throws -> Bool {
    let trendThreadBody = try trendThreadPayBody(
      purchaseID: purchaseID,
      serverVerificationData: serverVerificationData,
      orderCode: orderCode
    )
    print("payload: \(trendThreadBody)")

    let trendThreadData = try await trendThreadRequest(
      path: trendThreadEndpoint.trendThreadPay,
      body: trendThreadBody
    )
    print("pay code: \(trendThreadData?["code"] ?? "null")")

    return trendThreadData?["code"] as? String == "0000"
  }

  func trendThreadGetDecision() async throws -> [String: Any]? {
    try await trendThreadRequest(
      path: trendThreadEndpoint.trendThreadDecision,
      body: trendThreadDecisionBody()
    )
  }

  func trendThreadQuickLogin() async throws -> [String: Any]? {
    try await trendThreadRequest(
      path: trendThreadEndpoint.trendThreadQuickLogin,
      body: await trendThreadQuickLoginBody()
    )
  }

  func trendThreadLoadingTimeRecord(_ loadingTime: Int) async throws -> [String: Any]? {
    try await trendThreadRequest(
      path: trendThreadEndpoint.trendThreadLoadingTime,
      body: trendThreadLoadingTimeBody(loadingTime)
    )
  }
}

private extension TrendThreadApiCall {

  var trendThreadHeaders: HTTPHeaders {
    [
      "Content-Type": "application/json",
      "appVersion": ChicCanvasInformationCreate.chicCanvasAppVersion,
      "deviceNo": ClosetCharmBInfoStore.shared.closetCharmDeviceId,
      "pushToken": ClosetCharmAppStorage.closetCharmPushToken,
      "loginToken": ClosetCharmAppStorage.closetCharmUserToken,
      "appId": ChicCanvasInformationCreate.chicCanvasAppId,
    ]
  }

  func trendThreadPayBody(
    purchaseID: String,
    serverVerificationData: String,
    orderCode: String
  ) throws -> [String: Any] {
    [
      "hDGagrfgsect": purchaseID,
      "jjhghhhmrvp": serverVerificationData,
      "Nsecvhec": try trendThreadJSONString(["orderCode": orderCode]),
    ]
  }

  func trendThreadDecisionBody() -> [String: Any] {
    let trendThreadPhoneInfo = ChicCanvasPhoneInfo.shared

    return [
      "mevbdSSVBTsvsd": 1,
      "mhrAWWVhgkbtn": trendThreadPhoneInfo.chicCanvasIsVpnActive,
      "coqkHUGiuhkwde": trendThreadPhoneInfo.chicCanvasLanguages,
      "nbwsthQIUUXbkas": trendThreadPhoneInfo.chicCanvasCoverAppList,
      "gbOhcbkavbsjt": trendThreadPhoneInfo.chicCanvasTimezone,
      "hnytkJgbywavbk": trendThreadPhoneInfo.chicCanvasKeyboards,
      "debug": 1,
    ]
  }

  func trendThreadQuickLoginBody() async -> [String: Any] {
    let trendThreadPhoneInfo = ChicCanvasPhoneInfo.shared
    let trendThreadAdjustID = await Adjust.adid()

    var trendThreadBody: [String: Any] = [
      "vkjlciLUHlaefa": trendThreadAdjustID ?? "",
      "hnejuKucuabbrd": ClosetCharmBInfoStore.shared.closetCharmPassword,
      "bnKUHgqobhn": ClosetCharmBInfoStore.shared.closetCharmDeviceId,
      "jbkljhKjhehlkkv": [
        "countryCode": trendThreadPhoneInfo.chicCanvasCountryCode,
        "latitude": trendThreadPhoneInfo.chicCanvasLatitude,
        "longitude": trendThreadPhoneInfo.chicCanvasLongitude,
      ],
    ]

    if !ClosetCharmBInfoStore.shared.closetCharmPassword.isEmpty {
      trendThreadBody["ngMghkwkjgbed"] = ClosetCharmBInfoStore.shared.closetCharmPassword
    }

    return trendThreadBody
  }

  func trendThreadLoadingTimeBody(_ loadingTime: Int) -> [String: Any] {
    [
      "jjLKJhoouoeho": "\(loadingTime)"
    ]
  }
}

private extension TrendThreadApiCall {

  func trendThreadRequest(
    path: String,
    body: [String: Any]
  ) async throws -> [String: Any]? {
    let trendThreadEncryptedString = try trendThreadEncryptedBody(from: body)
    let trendThreadResponse = try await trendThreadPost(
      path: path,
      encryptedBody: trendThreadEncryptedString
    )

    return try trendThreadParseResponse(trendThreadResponse)
  }

  func trendThreadPost(path: String, encryptedBody: String) async throws -> Data {
    try await trendThreadSession.request(
      trendThreadBaseURL + path,
      method: .post,
      parameters: nil,
      encoding: TrendThreadRawStringEncoding(string: encryptedBody),
      headers: trendThreadHeaders
    )
    .serializingData()
    .value
  }

  func trendThreadEncryptedBody(from body: [String: Any]) throws -> String {
    let trendThreadJSONString = try trendThreadJSONString(body)
    return trendThreadJSONString.chicCanvasBEncode()
  }

  func trendThreadParseResponse(_ data: Data) throws -> [String: Any]? {
    let trendThreadObject = try JSONSerialization.jsonObject(with: data)

    if let trendThreadDict = trendThreadObject as? [String: Any] {
      return trendThreadDict
    }

    if let trendThreadString = trendThreadObject as? String {
      return try trendThreadParseJSONString(trendThreadString)
    }

    return nil
  }

  func trendThreadParseJSONString(_ trendThreadString: String) throws -> [String: Any]? {
    guard let trendThreadData = trendThreadString.data(using: .utf8) else {
      return nil
    }

    return try JSONSerialization.jsonObject(with: trendThreadData) as? [String: Any]
  }

  func trendThreadJSONString(_ dict: [String: Any]) throws -> String {
    let trendThreadData = try JSONSerialization.data(withJSONObject: dict)
    return String(data: trendThreadData, encoding: .utf8) ?? ""
  }
}

struct TrendThreadRawStringEncoding: ParameterEncoding {

  let string: String

  func encode(
    _ urlRequest: URLRequestConvertible,
    with parameters: Parameters?
  ) throws -> URLRequest {
    var trendThreadRequest = try urlRequest.asURLRequest()
    trendThreadRequest.httpBody = string.data(using: .utf8)
    return trendThreadRequest
  }
}
