import SwiftUI
import Combine

struct ClosetChatRoom: Codable, Identifiable, Equatable {

  let closetChatRoomId: String
  var closetChatUsers: [String]
  var closetChatLastSendMsg: String
  var closetChatLastSendTime: Date
    var closetChatLastSendUser: String
  var closetChatUnreadCount: Int

  var id: String { closetChatRoomId }
    
    func toClosetChatTargetRoom() -> ClosetChatTargetRoom {
        return ClosetChatTargetRoom(
            chatId: closetChatRoomId,
            chatUserIds: closetChatUsers,
            lastSendContent: closetChatLastSendMsg,
            lastSendTime: closetChatLastSendTime.toJSString(),
            unreadMsgCount: closetChatUnreadCount,
            lastSendUserId: closetChatLastSendUser
        )
    }
}

private enum ClosetChatRoomJsonPlainKeys {
    static let wardrobeShareChatIdKey = "chatId"
    static let wardrobeShareLastSendContentKey = "lastSendContent"
    static let wardrobeShareLastSendUserIdKey = "lastSendUserId"
    static let wardrobeShareUnreadMsgCountKey = "unreadMsgCount"
    static let wardrobeShareChatUserIdsKey = "chatUserIds"
    static let wardrobeShareLastSendTimeKey = "lastSendTime"
}

private enum ClosetChatMessageJsonPlainKeys {
    static let wardrobeShareMessageIdKey = "msgId"
    static let wardrobeShareChatIdKey = "chatId"
    static let wardrobeShareUserIdKey = "userId"
    static let wardrobeShareSendContentKey = "sendContent"
    static let wardrobeShareSendPicUrlKey = "sendPicUrl"
    static let wardrobeShareSendTimeKey = "sendTime"
}

extension ClosetChatRoom {

    init(json: [String: Any]) {

        self.closetChatRoomId = "\(json[ClosetChatRoomJsonPlainKeys.wardrobeShareChatIdKey] ?? "")"
        self.closetChatLastSendMsg = json[ClosetChatRoomJsonPlainKeys.wardrobeShareLastSendContentKey] as? String ?? ""
        self.closetChatLastSendUser = "\(json[ClosetChatRoomJsonPlainKeys.wardrobeShareLastSendUserIdKey] ?? "")"
        self.closetChatUnreadCount = json[ClosetChatRoomJsonPlainKeys.wardrobeShareUnreadMsgCountKey] as? Int ?? 0

        // 👇 用户数组
        self.closetChatUsers = (json[ClosetChatRoomJsonPlainKeys.wardrobeShareChatUserIdsKey] as? [Any])?
            .map { "\($0)" } ?? []

        // 👇 时间转换（String → Date）
        let timeStr = json[ClosetChatRoomJsonPlainKeys.wardrobeShareLastSendTimeKey] as? String ?? ""
        self.closetChatLastSendTime = Date.fromJSString(timeStr)
    }
    
    static func fromJsonArray(_ array: [[String: Any]]) -> [ClosetChatRoom] {
            array.map { ClosetChatRoom(json: $0) }
        }
}

struct ClosetChatTargetRoom: Codable {
    let chatId: String
    let chatUserIds: [String]
    let lastSendContent: String
    let lastSendTime: String
    let unreadMsgCount: Int
    let lastSendUserId: String
}

struct ClosetChatMessage: Codable, Identifiable, Equatable {

  let closetChatMsgId: String

  var closetChatRoomId: String
  var closetChatSendUserId: String
  var closetChatTextMsg: String
  var closetChatImageMsg: String
  var closetChatDate: Date
    
    var id: String { closetChatMsgId }
    
    func toClosetChatTargetMessage() -> ClosetChatTargetMessage {
        return ClosetChatTargetMessage(
            msgId: closetChatMsgId,
            chatId: closetChatRoomId,
            userId: closetChatSendUserId,
            sendContent: closetChatTextMsg,
            sendPicUrl: closetChatImageMsg,
            sendTime: closetChatDate.toJSString()
        )
    }
}

extension ClosetChatMessage {

    init(json: [String: Any]) {

        self.closetChatMsgId = "\(json[ClosetChatMessageJsonPlainKeys.wardrobeShareMessageIdKey] ?? "")"
        self.closetChatRoomId = "\(json[ClosetChatMessageJsonPlainKeys.wardrobeShareChatIdKey] ?? "")"
        self.closetChatSendUserId = "\(json[ClosetChatMessageJsonPlainKeys.wardrobeShareUserIdKey] ?? "")"

        self.closetChatTextMsg = json[ClosetChatMessageJsonPlainKeys.wardrobeShareSendContentKey] as? String ?? ""
        self.closetChatImageMsg = json[ClosetChatMessageJsonPlainKeys.wardrobeShareSendPicUrlKey] as? String ?? ""

        // 👇 时间
        let timeStr = json[ClosetChatMessageJsonPlainKeys.wardrobeShareSendTimeKey] as? String ?? ""
        self.closetChatDate = Date.fromJSString(timeStr)
    }
    
    static func fromJsonArray(_ array: [[String: Any]]) -> [ClosetChatMessage] {
            array.map { ClosetChatMessage(json: $0) }
        }
}

struct ClosetChatTargetMessage: Codable {
    let msgId: String
    let chatId: String
    let userId: String
    let sendContent: String
    let sendPicUrl: String
    let sendTime: String
}

extension Date {
    
    func toJSString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.string(from: self)
    }
    
    static func fromJSString(_ str: String) -> Date {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            formatter.locale = Locale(identifier: "en_US_POSIX")
            return formatter.date(from: str) ?? Date()
        }
}

@MainActor
final class ClosetChatViewModel: ObservableObject {

  @Published var myChatRooms: [ClosetChatRoom] = []
  @Published var chatMessageList: [ClosetChatMessage] = []

  private let storage = WardrobeShareStorageManager.shared

  func getClosetChatUserId(chatRoomId: String) -> String? {
    guard
      let chatRoomInfo = storage.wardrobeShareGetChatRooms().first(where: {
        $0.closetChatRoomId == chatRoomId
      })
    else {
      return nil
    }
    guard
      let chatUserId = chatRoomInfo.closetChatUsers.first(where: {
        $0 != storage.wardrobeShareGetCurrentUserId()
      })
    else {
      return nil
    }

    return chatUserId
  }

  func getMyClosetChatRoomsNotBlock() -> [ClosetChatRoom] {
    let closetChatAllRooms = storage.wardrobeShareGetChatRooms()
    let loginUserId = storage.wardrobeShareGetCurrentUserId()
    guard let myInfo = storage.wardrobeShareGetUserById(userId: loginUserId) else {
      return []
    }

    let myClosetChatRooms = closetChatAllRooms.filter {
      let closetChatOtherUserIds = $0.closetChatUsers.filter { $0 != loginUserId }
      return $0.closetChatUsers.contains(loginUserId)
        && !closetChatOtherUserIds.isEmpty
        && closetChatOtherUserIds.allSatisfy { !myInfo.closetProfileBlacklist.contains($0) }
    }
      
      return myClosetChatRooms
  }

  // 获取聊天用户信息
  func getClosetChatUserInfo(chatRoomId: String) -> ClosetProfileUser? {
    guard let chatUserId = getClosetChatUserId(chatRoomId: chatRoomId) else {
      return nil
    }
    return storage.wardrobeShareGetUserById(userId: chatUserId)
  }

}
