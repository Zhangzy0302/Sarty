import SwiftUI
import Combine

struct ClosetProfileUser: Codable, Identifiable, Equatable {

  let closetProfileUserId: String
  var closetProfileEmail: String
  var closetProfilePassword: String
  var closetProfileUserName: String
  var closetProfileAvatar: String
    var closetProfileAboutMe: String
  var closetProfileFollowing: [String]
  var closetProfileFans: [String]
  var closetProfileBlacklist: [String]
  var closetProfileWalletBalance: Int
    var closetProfileLikePosts: [String]
  var closetProfileIsDeleted: Int	
  var closetProfileIsGuest: Int

  // MARK: - Identifiable
  var id: String { closetProfileUserId }
    
    var isClosetProfileGuest: Bool {
        closetProfileIsGuest == 1
    }
    
    func toClosetProfileTargetUser() -> ClosetProfileTargetUser {
            return ClosetProfileTargetUser(
                userId: closetProfileUserId,
                email: closetProfileEmail,
                password: closetProfilePassword,
                avator: closetProfileAvatar,
                name: closetProfileUserName,
                about: closetProfileAboutMe.isEmpty ? "This user has no description. " : closetProfileAboutMe,
                coins: closetProfileWalletBalance,
                follow: closetProfileFollowing,
                fans: closetProfileFans,
                blockList: closetProfileBlacklist,
                postLikeIds: closetProfileLikePosts,
                isdelete: closetProfileIsDeleted,
                isguest: closetProfileIsGuest
            )
        }
    
    func convertUsers(_ users: [ClosetProfileUser]) -> [ClosetProfileTargetUser] {
        return users.map { $0.toClosetProfileTargetUser() }
    }
}

private enum ClosetProfileUserJsonPlainKeys {
    static let wardrobeShareUserIdKey = "userId"
    static let wardrobeShareEmailKey = "email"
    static let wardrobeSharePasswordKey = "password"
    static let wardrobeShareNameKey = "name"
    static let wardrobeShareAvatarKey = "avator"
    static let wardrobeShareAboutKey = "about"
    static let wardrobeShareCoinsKey = "coins"
    static let wardrobeShareIsDeletedKey = "isdelete"
    static let wardrobeShareIsGuestKey = "isguest"
    static let wardrobeShareFollowKey = "follow"
    static let wardrobeShareFansKey = "fans"
    static let wardrobeShareBlockListKey = "blockList"
    static let wardrobeSharePostLikeIdsKey = "postLikeIds"
}

extension ClosetProfileUser {

    private enum CodingKeys: String, CodingKey {
        case closetProfileUserId
        case closetProfileEmail
        case closetProfilePassword
        case closetProfileUserName
        case closetProfileAvatar
        case closetProfileAboutMe
        case closetProfileFollowing
        case closetProfileFans
        case closetProfileBlacklist
        case closetProfileWalletBalance
        case closetProfileLikePosts
        case closetProfileIsDeleted
        case closetProfileIsGuest
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.closetProfileUserId = try container.decode(String.self, forKey: .closetProfileUserId)
        self.closetProfileEmail = try container.decode(String.self, forKey: .closetProfileEmail)
        self.closetProfilePassword = try container.decode(String.self, forKey: .closetProfilePassword)
        self.closetProfileUserName = try container.decode(String.self, forKey: .closetProfileUserName)
        self.closetProfileAvatar = try container.decode(String.self, forKey: .closetProfileAvatar)
        self.closetProfileAboutMe = try container.decode(String.self, forKey: .closetProfileAboutMe)
        self.closetProfileFollowing = try container.decode([String].self, forKey: .closetProfileFollowing)
        self.closetProfileFans = try container.decode([String].self, forKey: .closetProfileFans)
        self.closetProfileBlacklist = try container.decode([String].self, forKey: .closetProfileBlacklist)
        self.closetProfileWalletBalance = try container.decode(Int.self, forKey: .closetProfileWalletBalance)
        self.closetProfileLikePosts = try container.decode([String].self, forKey: .closetProfileLikePosts)
        self.closetProfileIsDeleted = try container.decode(Int.self, forKey: .closetProfileIsDeleted)
        self.closetProfileIsGuest = try container.decodeIfPresent(Int.self, forKey: .closetProfileIsGuest)
            ?? (closetProfileEmail.isEmpty && closetProfilePassword.isEmpty ? 1 : 0)
    }

    init(json: [String: Any]) {

        self.closetProfileUserId = "\(json[ClosetProfileUserJsonPlainKeys.wardrobeShareUserIdKey] ?? "")"
        self.closetProfileEmail = json[ClosetProfileUserJsonPlainKeys.wardrobeShareEmailKey] as? String ?? ""
        self.closetProfilePassword = "\(json[ClosetProfileUserJsonPlainKeys.wardrobeSharePasswordKey] ?? "")"
        self.closetProfileUserName = json[ClosetProfileUserJsonPlainKeys.wardrobeShareNameKey] as? String ?? ""
        self.closetProfileAvatar = json[ClosetProfileUserJsonPlainKeys.wardrobeShareAvatarKey] as? String ?? ""
        self.closetProfileAboutMe = json[ClosetProfileUserJsonPlainKeys.wardrobeShareAboutKey] as? String ?? ""
        self.closetProfileWalletBalance = json[ClosetProfileUserJsonPlainKeys.wardrobeShareCoinsKey] as? Int ?? 0
        self.closetProfileIsDeleted = json[ClosetProfileUserJsonPlainKeys.wardrobeShareIsDeletedKey] as? Int ?? 0
        self.closetProfileIsGuest = json[ClosetProfileUserJsonPlainKeys.wardrobeShareIsGuestKey] as? Int
            ?? (closetProfileEmail.isEmpty && closetProfilePassword.isEmpty ? 1 : 0)

        // 数组转换（兼容 __NSArrayM）
        self.closetProfileFollowing = (json[ClosetProfileUserJsonPlainKeys.wardrobeShareFollowKey] as? [Any])?.map { "\($0)" } ?? []
        self.closetProfileFans = (json[ClosetProfileUserJsonPlainKeys.wardrobeShareFansKey] as? [Any])?.map { "\($0)" } ?? []
        self.closetProfileBlacklist = (json[ClosetProfileUserJsonPlainKeys.wardrobeShareBlockListKey] as? [Any])?.map { "\($0)" } ?? []
        self.closetProfileLikePosts = (json[ClosetProfileUserJsonPlainKeys.wardrobeSharePostLikeIdsKey] as? [Any])?.map { "\($0)" } ?? []
    }
    
    static func fromJsonArray(_ array: [[String: Any]]) -> [ClosetProfileUser] {
            return array.map { ClosetProfileUser(json: $0) }
        }
}

struct ClosetProfileTargetUser: Codable {
    var userId: String
    var email: String
    var password: String
    var avator: String
    var name: String
    var about: String
    var coins: Int
    var follow: [String]
    var fans: [String]
    var blockList: [String]
    var postLikeIds: [String]
    var isdelete: Int
    var isguest: Int
}


@MainActor
final class ClosetProfileUserViewModel: ObservableObject {

  @Published var users: [ClosetProfileUser] = []
  @Published var currentUser: ClosetProfileUser?
  @Published var userInfo: ClosetProfileUser?
    @Published var currentUserID: String = ""

  private let storage = WardrobeShareStorageManager.shared

  func getClosetProfileUserInfoByUid(uid: String) {
    userInfo = storage.wardrobeShareGetUserById(userId: uid)
  }

  func returnClosetProfileUserInfoById(userId: String) -> ClosetProfileUser? {
    storage.wardrobeShareGetUserById(userId: userId)
  }

  func loadLoginClosetProfileUser() {
    users = storage.wardrobeShareGetUsers()

    let uid: String = storage.wardrobeShareGetCurrentUserId()
      currentUserID = uid
    currentUser = users.first { $0.closetProfileUserId == uid }
  }
    
    func isCurrentLoginUserGuestClosetProfile() -> Bool {
        if let currentUser {
            return currentUser.isClosetProfileGuest
        }
        
        let uid = storage.wardrobeShareGetCurrentUserId()
        guard !uid.isEmpty,
              let loginUser = storage.wardrobeShareGetUserById(userId: uid) else {
            return false
        }
        
        return loginUser.isClosetProfileGuest
    }

  // 登录
  func loginByEmailAndPasswordClosetProfile(email: String, password: String) -> ClosetProfileUser? {
    let users = storage.wardrobeShareGetUsers()
    guard
      let matchUser = users.first(where: {
        $0.closetProfileEmail == email && $0.closetProfilePassword == password && $0.closetProfileIsDeleted == 0
      })
    else {
      return nil
    }

    // 记录登录态
    storage.wardrobeShareSetCurrentUserId(matchUser.closetProfileUserId)
      currentUserID = matchUser.closetProfileUserId
    loadLoginClosetProfileUser()
    return matchUser
  }

  // 游客登录
    func visitorLoginClosetProfile() {
        
        let users = storage.wardrobeShareGetUsers()
        
        // ✅ 1. 查找已有游客（isguest = 1 + 未删除）
        if let existVisitor = users.first(where: {
            $0.closetProfileIsGuest == 1 &&
            $0.closetProfileIsDeleted == 0
        }) {
            print(existVisitor)
//            print("✅ 使用已有游客:", existVisitor.closetProfileUserId)
            
            storage.wardrobeShareSetCurrentUserId(existVisitor.closetProfileUserId)
            loadLoginClosetProfileUser()
            return
        }
        
        // ❌ 2. 没有游客 → 创建新游客
        let newId = "\(Int(Date().timeIntervalSince1970))" // ✅ 推荐用时间戳避免重复
        
        let newUser = ClosetProfileUser(
            closetProfileUserId: newId,
            closetProfileEmail: "",
            closetProfilePassword: "",
            closetProfileUserName: "Visitor_\(newId)",
            closetProfileAvatar: "http://huanniuchat.oss-accelerate.aliyuncs.com/Sarty2026/SART_DEFAULT_AVA.png",
            closetProfileAboutMe: "",
            closetProfileFollowing: [],
            closetProfileFans: [],
            closetProfileBlacklist: [],
            closetProfileWalletBalance: 0,
            closetProfileLikePosts: [],
            closetProfileIsDeleted: 0,
            closetProfileIsGuest: 1
        )
        
        print("🆕 创建新游客:", newId)
        
        storage.wardrobeShareAddUser(user: newUser)
        storage.wardrobeShareSetCurrentUserId(newUser.closetProfileUserId)
        
        loadLoginClosetProfileUser()
    }

  // 删除账号
  func deleteAccountClosetProfile() {
      storage.wardrobeShareRemoveCurrentUserAllWorks()
      storage.wardrobeShareRemoveCurrentUserChatRooms()
      storage.wardrobeShareRemoveCurrentUserAllComments()
      // ✅ 1. 标记删除
      storage.wardrobeShareUpdateUser(uid: storage.wardrobeShareGetCurrentUserId()) { user in
          var newUser = user
          newUser.closetProfileIsDeleted = 1
          return newUser
      }
    storage.wardrobeShareSetCurrentUserId("")
      currentUserID = ""
    loadLoginClosetProfileUser()
  }

  // 注册
  func registerClosetProfile(email: String, password: String) -> ClosetProfileUser? {
    let users = storage.wardrobeShareGetUsers()
    guard
      users.first(where: { $0.closetProfileEmail == email }) == nil
    else {
      return nil
    }

    let newUser: ClosetProfileUser = ClosetProfileUser(
      closetProfileUserId: "\(users.count)",
      closetProfileEmail: email,
      closetProfilePassword: password,
      closetProfileUserName: "User_" + String(users.count),
      closetProfileAvatar: "http://huanniuchat.oss-accelerate.aliyuncs.com/Sarty2026/SART_DEFAULT_AVA.png",
      closetProfileAboutMe: "",
      closetProfileFollowing: [],
      closetProfileFans: [],
      closetProfileBlacklist: [],
      closetProfileWalletBalance: 0,
      closetProfileLikePosts: [],
      closetProfileIsDeleted: 0,
      closetProfileIsGuest: 0
    )

    storage.wardrobeShareAddUser(user: newUser)
    storage.wardrobeShareSetCurrentUserId(newUser.closetProfileUserId)
    loadLoginClosetProfileUser()
    return newUser
  }

  // 登出
  func logoutClosetProfile() {
    storage.wardrobeShareSetCurrentUserId("")
    loadLoginClosetProfileUser()
  }

  // 切换拉黑状态
  func toggleUserIsBlocked(blockUserId: String) {
    storage.wardrobeShareUpdateUser(uid: currentUser!.closetProfileUserId) { user in
      var newUser: ClosetProfileUser = user
      if newUser.closetProfileBlacklist.contains(blockUserId) {
        newUser.closetProfileBlacklist.removeAll { $0 == blockUserId }
      } else {
        newUser.closetProfileBlacklist.append(blockUserId)
      }

      return newUser
    }

    loadLoginClosetProfileUser()
  }

  // 拉黑用户
  func closetProfileBlockUser(blockUserId: String) {
    loadLoginClosetProfileUser()
    guard let currentUser, currentUser.closetProfileUserId != blockUserId else { return }

    storage.wardrobeShareUpdateUser(uid: currentUser.closetProfileUserId) { user in
      var newUser: ClosetProfileUser = user
      if !newUser.closetProfileBlacklist.contains(blockUserId) {
        newUser.closetProfileBlacklist.append(blockUserId)
      }
      return newUser
    }

    loadLoginClosetProfileUser()
  }

  // 切换是否喜欢视频作品
  func toggleVideoIsLiked(_ videoId: String) {
    storage.wardrobeShareUpdateUser(uid: currentUser!.closetProfileUserId) { user in
      var newUser: ClosetProfileUser = user
      if newUser.closetProfileLikePosts.contains(videoId) {
        newUser.closetProfileLikePosts.removeAll { $0 == videoId }
          storage.wardrobeShareDecreaseLikeCount(workId: videoId)
      } else {
        newUser.closetProfileLikePosts.append(videoId)
          storage.wardrobeShareIncreaseLikeCount(workId: videoId)
      }
      return newUser
    }
    loadLoginClosetProfileUser()
  }

  func toggleUserIsFollowed(followUserId: String) {
    loadLoginClosetProfileUser()
    guard let currentUser,
          currentUser.closetProfileUserId != followUserId else {
      return
    }

    let isFollowing = currentUser.closetProfileFollowing.contains(followUserId)

    storage.wardrobeShareUpdateUser(uid: currentUser.closetProfileUserId) { user in
      var newUser = user
      if isFollowing {
        newUser.closetProfileFollowing.removeAll { $0 == followUserId }
      } else if !newUser.closetProfileFollowing.contains(followUserId) {
        newUser.closetProfileFollowing.append(followUserId)
      }
      return newUser
    }

    storage.wardrobeShareUpdateUser(uid: followUserId) { user in
      var newUser = user
      if isFollowing {
        newUser.closetProfileFans.removeAll { $0 == currentUser.closetProfileUserId }
      } else if !newUser.closetProfileFans.contains(currentUser.closetProfileUserId) {
        newUser.closetProfileFans.append(currentUser.closetProfileUserId)
      }
      return newUser
    }

    loadLoginClosetProfileUser()
  }


  // 更新用户钻石数
  func increaseUserDiamond(diamond: Int) {
    storage.wardrobeShareUpdateUser(uid: currentUser!.closetProfileUserId) { user in
      var newUser: ClosetProfileUser = user
      newUser.closetProfileWalletBalance = newUser.closetProfileWalletBalance + diamond
      return newUser
    }

    loadLoginClosetProfileUser()
  }
    
    // 获取所有未拉黑的用户
    func getAllNotBlockClosetProfileUsers() -> [ClosetProfileUser] {
        let users = storage.wardrobeShareGetUsers()
        if let closetProfileMyInfo = currentUser {
            let allClosetProfileUsers = users.filter{
                !closetProfileMyInfo.closetProfileBlacklist.contains($0.closetProfileUserId)
            }
            
            return allClosetProfileUsers
        }
        return []
    }
}
