
import Foundation
import Security

// MARK: - Key 定义
enum ClosetCharmSecureKey {
    case closetCharmDeviceId, closetCharmPassword

    var closetCharmKey: String {
        switch self {
        case .closetCharmDeviceId: return "closetCharmDeviceId5"
        case .closetCharmPassword: return "closetCharmPassword"
        }
    }
}

final class ClosetCharmBInfoStore {

    static let shared = ClosetCharmBInfoStore()
    private init() {}

    private func closetCharmSaveSecureValue(_ value: String, for key: ClosetCharmSecureKey) -> Bool {
        guard let data = value.data(using: .utf8) else { return false }
        closetCharmDeleteSecureValue(key) // 先删除旧值

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key.closetCharmKey,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
        ]

        return SecItemAdd(query as CFDictionary, nil) == errSecSuccess
    }

    private func closetCharmReadSecureValue(_ key: ClosetCharmSecureKey) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key.closetCharmKey,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var data: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &data)
        guard
            status == errSecSuccess,
            let resultData = data as? Data,
            let value = String(data: resultData, encoding: .utf8)
        else { return nil }
        return value
    }

    private func closetCharmDeleteSecureValue(_ key: ClosetCharmSecureKey) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key.closetCharmKey
        ]
        SecItemDelete(query as CFDictionary)
    }

    // MARK: - 直接属性访问
    var closetCharmDeviceId: String {
        get { closetCharmReadSecureValue(.closetCharmDeviceId) ?? "" }
        set { closetCharmSaveSecureValue(newValue, for: .closetCharmDeviceId) }
    }

    var closetCharmPassword: String {
        get { closetCharmReadSecureValue(.closetCharmPassword) ?? "" }
        set { closetCharmSaveSecureValue(newValue, for: .closetCharmPassword) }
    }
}

// 卸载后不持久
enum ClosetCharmAppStorageKey {
  static let closetCharmIsB = "closetCharmIsB"
  static let closetCharmPushToken = "closetCharmPushToken"
  static let closetCharmH5Url = "closetCharmH5Url"
    static let closetCharmUserToken = "closetCharmUserToken"
}

final class ClosetCharmAppStorage {

  private static let closetCharmDefaults = UserDefaults.standard

  static var closetCharmIsB: Bool {
    get { closetCharmDefaults.bool(forKey: ClosetCharmAppStorageKey.closetCharmIsB) }
    set { closetCharmDefaults.set(newValue, forKey: ClosetCharmAppStorageKey.closetCharmIsB) }
  }
    
    static var closetCharmUserToken: String {
      get { closetCharmDefaults.string(forKey: ClosetCharmAppStorageKey.closetCharmUserToken) ?? ""}
      set { closetCharmDefaults.set(newValue, forKey: ClosetCharmAppStorageKey.closetCharmUserToken) }
    }

  static var closetCharmPushToken: String {
    get { closetCharmDefaults.string(forKey: ClosetCharmAppStorageKey.closetCharmPushToken) ?? "" }
    set { closetCharmDefaults.set(newValue, forKey: ClosetCharmAppStorageKey.closetCharmPushToken) }
  }

  static var closetCharmH5Url: String {
    get { closetCharmDefaults.string(forKey: ClosetCharmAppStorageKey.closetCharmH5Url) ?? "" }
    set { closetCharmDefaults.set(newValue, forKey: ClosetCharmAppStorageKey.closetCharmH5Url) }
  }
}

var closetCharmUsersOrderCode: String = ""
