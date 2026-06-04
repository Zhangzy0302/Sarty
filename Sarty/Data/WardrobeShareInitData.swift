import Foundation
import SwiftUI

private enum WardrobeShareCipherVault {
  static let wardrobeShareAssetBaseURL =
    "https://huanniuchat.oss-accelerate.aliyuncs.com/Sarty2026/"
}

private func wardrobeShareAssetURL(_ path: String) -> String {
    WardrobeShareCipherVault.wardrobeShareAssetBaseURL + path
}

final class WardrobeShareStorageManager {

  static let shared = WardrobeShareStorageManager()
  private init() {}

  private let storage = UserDefaults.standard

  // MARK: - Keys
  private enum Keys {
    static let closetProfileUsers: String = "closetProfileUsers"
    static let lookbookPostWorks: String = "lookbookPostWorks"
    static let socialThreadComments: String = "socialThreadComments"
    static let closetChatRooms: String = "closetChatRooms"
    static let closetChatMessages: String = "closetChatMessages"
    static let wardrobeShareCurrentUserId: String = "wardrobeShareCurrentUserId"
  }
}

extension WardrobeShareStorageManager {

  func initializeAllDefaults() {
    initializeUsersIfNeeded()
    initializeWorksIfNeeded()
    initializeCommentsIfNeeded()
    initializeChatRoomsIfNeeded()
    initializeMessagesIfNeeded()
  }

}

//User CRUD & 登录态
extension WardrobeShareStorageManager {

  private func initializeUsersIfNeeded() {
    guard storage.data(forKey: Keys.closetProfileUsers) == nil else { return }

    let users: [ClosetProfileUser] = [
      ClosetProfileUser(
        closetProfileUserId: "closet_user_0",
        closetProfileEmail: "sarty@gmail.com",
        closetProfilePassword: "123456",
        closetProfileUserName: "Knox",
        closetProfileAvatar:
          wardrobeShareAssetURL("SART_AVA_0.png"),
        closetProfileAboutMe: "Dress well, live well.",
        closetProfileFollowing: ["closet_user_4", "closet_user_5"],
        closetProfileFans: ["closet_user_4", "closet_user_5"],
        closetProfileBlacklist: [],
        closetProfileWalletBalance: 0,
        closetProfileLikePosts: [],
        closetProfileIsDeleted: 0,
        closetProfileIsGuest: 0
      ),
      ClosetProfileUser(
        closetProfileUserId: "closet_user_1",
        closetProfileEmail: "asdc3beasd@gmail.com",
        closetProfilePassword: "5hdfbaff3",
        closetProfileUserName: "Moore",
        closetProfileAvatar:
          wardrobeShareAssetURL("SART_AVA_1.png"),
        closetProfileAboutMe: "Basic pieces, extraordinary matching.",
        closetProfileFollowing: [],
        closetProfileFans: ["closet_user_2"],
        closetProfileBlacklist: [],
        closetProfileWalletBalance: 0,
        closetProfileLikePosts: [],
        closetProfileIsDeleted: 0,
        closetProfileIsGuest: 0
      ),
      ClosetProfileUser(
        closetProfileUserId: "closet_user_2",
        closetProfileEmail: "assfbrab@gmail.com",
        closetProfilePassword: "4627535",
        closetProfileUserName: "Carlos",
        closetProfileAvatar:
          wardrobeShareAssetURL("SART_AVA_2.png"),
        closetProfileAboutMe: "Simple wear, great texture.",
        closetProfileFollowing: ["closet_user_1"],
        closetProfileFans: [],
        closetProfileBlacklist: [],
        closetProfileWalletBalance: 0,
        closetProfileLikePosts: [],
        closetProfileIsDeleted: 0,
        closetProfileIsGuest: 0
      ),
      ClosetProfileUser(
        closetProfileUserId: "closet_user_3",
        closetProfileEmail: "brtwf452t2@gmail.com",
        closetProfilePassword: "78986278",
        closetProfileUserName: "Patti",
        closetProfileAvatar:
          wardrobeShareAssetURL("SART_AVA_3.png"),
        closetProfileAboutMe: "Style has no limits. ",
        closetProfileFollowing: [],
        closetProfileFans: [],
        closetProfileBlacklist: [],
        closetProfileWalletBalance: 0,
        closetProfileLikePosts: [],
        closetProfileIsDeleted: 0,
        closetProfileIsGuest: 0
      ),
      ClosetProfileUser(
        closetProfileUserId: "closet_user_4",
        closetProfileEmail: "nsVShjtd@gmail.com",
        closetProfilePassword: "hmrj4gfs4us",
        closetProfileUserName: "Icey",
        closetProfileAvatar:
          wardrobeShareAssetURL("SART_AVA_4.png"),
        closetProfileAboutMe: "Dress up for a better mood. ",
        closetProfileFollowing: ["closet_user_0"],
        closetProfileFans: ["closet_user_0"],
        closetProfileBlacklist: [],
        closetProfileWalletBalance: 0,
        closetProfileLikePosts: [],
        closetProfileIsDeleted: 0,
        closetProfileIsGuest: 0
      ),
      ClosetProfileUser(
        closetProfileUserId: "closet_user_5",
        closetProfileEmail: "bdvsvnnhkuew@gmail.com",
        closetProfilePassword: "bd4h7eag",
        closetProfileUserName: "Shelley",
        closetProfileAvatar:
          wardrobeShareAssetURL("SART_AVA_5.png"),
        closetProfileAboutMe: "Share daily outfits, find beauty in ordinary life.",
        closetProfileFollowing: ["closet_user_0"],
        closetProfileFans: ["closet_user_0"],
        closetProfileBlacklist: [],
        closetProfileWalletBalance: 0,
        closetProfileLikePosts: [],
        closetProfileIsDeleted: 0,
        closetProfileIsGuest: 0
      ),
    ]

    save(users, forKey: Keys.closetProfileUsers)
  }

  func wardrobeShareGetUsers() -> [ClosetProfileUser] {
    load([ClosetProfileUser].self, forKey: Keys.closetProfileUsers, default: [])
  }

  func wardrobeShareSaveUsers(_ users: [ClosetProfileUser]) {
    save(users, forKey: Keys.closetProfileUsers)
  }

  func wardrobeShareGetUserById(userId: String) -> ClosetProfileUser? {
    let allUsers = wardrobeShareGetUsers()
    // 查找第一个 userId 匹配的用户
    return allUsers.first { $0.closetProfileUserId == userId }
  }

  func wardrobeShareUpdateUser(
    uid: String,
    update: (ClosetProfileUser) -> ClosetProfileUser
  ) {
    var users = wardrobeShareGetUsers()
    guard let index = users.firstIndex(where: { $0.closetProfileUserId == uid }) else { return }
    users[index] = update(users[index])
    wardrobeShareSaveUsers(users)
  }

  // add user
  func wardrobeShareAddUser(user: ClosetProfileUser) {
    var users: [ClosetProfileUser] = wardrobeShareGetUsers()
    users.append(user)
    wardrobeShareSaveUsers(users)
  }

  // MARK: Login State
  func wardrobeShareSetCurrentUserId(_ uid: String) {
    storage.set(uid, forKey: Keys.wardrobeShareCurrentUserId)
  }

  func wardrobeShareGetCurrentUserId() -> String {
    return storage.object(forKey: Keys.wardrobeShareCurrentUserId) as? String ?? ""
  }
    
    func isCurrentLoginUserGuestClosetProfile() -> Bool {
        let currentUserId = wardrobeShareGetCurrentUserId()
        guard !currentUserId.isEmpty,
              let currentUser = wardrobeShareGetUserById(userId: currentUserId) else {
            return false
        }
        
        return currentUser.isClosetProfileGuest
    }
    
    func wardrobeShareMarkCurrentUserDeleted() {
        let currentUserId = wardrobeShareGetCurrentUserId()
        
        wardrobeShareUpdateUser(uid: currentUserId) { user in
            var updated = user
            updated.closetProfileIsDeleted = 1
            return updated
        }
    }

}

//work
extension WardrobeShareStorageManager {

  private func initializeWorksIfNeeded() {
    guard storage.data(forKey: Keys.lookbookPostWorks) == nil else { return }

    let lookbookPostWorks: [LookbookPostVideo] = [
      LookbookPostVideo(
        lookbookPostWorkId: "lookbook_post_0",
        lookbookPostCreatorId: "closet_user_1",
        lookbookPostType: 1,
        lookbookPostTextContent:
          "Daily men’s style",
        lookbookPostTitleType: 1,
        lookbookPostVideoUrl:
          wardrobeShareAssetURL("SART_VD_1.mp4"),
        lookbookPostPic:
          [wardrobeShareAssetURL("SART_VD_COV_1.png")],
        lookbookPostLikeCount: 864,
        lookbookPostCommentCount: 2),
      LookbookPostVideo(
        lookbookPostWorkId: "lookbook_post_1",
        lookbookPostCreatorId: "closet_user_2",
        lookbookPostType: 1,
        lookbookPostTextContent:
          "Classic clean fit, never goes wrong.",
        lookbookPostTitleType: 2,
        lookbookPostVideoUrl:
          wardrobeShareAssetURL("SART_VD_2.mp4"),
        lookbookPostPic:
          [wardrobeShareAssetURL("SART_VD_COV_2.png")],
        lookbookPostLikeCount: 2312,
        lookbookPostCommentCount: 1),
      LookbookPostVideo(
        lookbookPostWorkId: "lookbook_post_2",
        lookbookPostCreatorId: "closet_user_0",
        lookbookPostType: 1,
        lookbookPostTextContent: "Casual look for everyday wear.",
        lookbookPostTitleType: 0,
        lookbookPostVideoUrl:
          wardrobeShareAssetURL("SART_VD_0.mp4"),
        lookbookPostPic:
          [wardrobeShareAssetURL("SART_VD_COV_0.png")],
        lookbookPostLikeCount: 634,
        lookbookPostCommentCount: 1),
      LookbookPostVideo(
        lookbookPostWorkId: "lookbook_post_3",
        lookbookPostCreatorId: "closet_user_3",
        lookbookPostType: 1,
        lookbookPostTextContent: "Style has no rules.",
        lookbookPostTitleType: 1,
        lookbookPostVideoUrl:
          wardrobeShareAssetURL("SART_VD_3.mp4"),
        lookbookPostPic:
          [wardrobeShareAssetURL("SART_VD_COV_3.png")],
        lookbookPostLikeCount: 2624,
        lookbookPostCommentCount: 1),
      LookbookPostVideo(
        lookbookPostWorkId: "lookbook_post_4",
        lookbookPostCreatorId: "closet_user_4",
        lookbookPostType: 1,
        lookbookPostTextContent: "Copy my look if you like. ",
        lookbookPostTitleType: 2,
        lookbookPostVideoUrl:
          wardrobeShareAssetURL("SART_VD_4.mp4"),
        lookbookPostPic:
          [wardrobeShareAssetURL("SART_VD_COV_4.png")],
        lookbookPostLikeCount: 1647,
        lookbookPostCommentCount: 0),
      LookbookPostVideo(
        lookbookPostWorkId: "lookbook_post_5",
        lookbookPostCreatorId: "closet_user_5",
        lookbookPostType: 1,
        lookbookPostTextContent: "Basic pieces can also create amazing looks.",
        lookbookPostTitleType: 2,
        lookbookPostVideoUrl:
          wardrobeShareAssetURL("SART_VD_5.mp4"),
        lookbookPostPic:
          [wardrobeShareAssetURL("SART_VD_COV_5.png")],
        lookbookPostLikeCount: 2564,
        lookbookPostCommentCount: 0),
      //image
      LookbookPostVideo(
        lookbookPostWorkId: "lookbook_post_6",
        lookbookPostCreatorId: "closet_user_2",
        lookbookPostType: 0,
        lookbookPostTextContent: "Minimalist outfit vibe.",
        lookbookPostTitleType: 0,
        lookbookPostVideoUrl:
          "",
        lookbookPostPic:
          [wardrobeShareAssetURL("SART_IMG_0.jpg"),
          wardrobeShareAssetURL("SART_IMG_1.jpg")],
        lookbookPostLikeCount: 786,
        lookbookPostCommentCount: 0),
      LookbookPostVideo(
        lookbookPostWorkId: "lookbook_post_7",
        lookbookPostCreatorId: "closet_user_2",
        lookbookPostType: 0,
        lookbookPostTextContent: "Comfort meets style. ",
        lookbookPostTitleType: 0,
        lookbookPostVideoUrl:
          "",
        lookbookPostPic:
            [wardrobeShareAssetURL("SART_IMG_2.jpg"),
            wardrobeShareAssetURL("SART_IMG_3.jpg"),
            wardrobeShareAssetURL("SART_IMG_4.jpg")],
        lookbookPostLikeCount: 186,
        lookbookPostCommentCount: 1),
      LookbookPostVideo(
        lookbookPostWorkId: "lookbook_post_8",
        lookbookPostCreatorId: "closet_user_1",
        lookbookPostType: 0,
        lookbookPostTextContent: "Today's outfit.",
        lookbookPostTitleType: 1,
        lookbookPostVideoUrl:
          "",
        lookbookPostPic:
            [wardrobeShareAssetURL("SART_IMG_5.jpg"),
            wardrobeShareAssetURL("SART_IMG_6.jpg"),
            wardrobeShareAssetURL("SART_IMG_7.jpg")],
        lookbookPostLikeCount: 734,
        lookbookPostCommentCount: 2),
      LookbookPostVideo(
        lookbookPostWorkId: "lookbook_post_9",
        lookbookPostCreatorId: "closet_user_0",
        lookbookPostType: 0,
        lookbookPostTextContent: "Keep it simple but stylish in daily wear.",
        lookbookPostTitleType: 0,
        lookbookPostVideoUrl:
          "",
        lookbookPostPic:
            [wardrobeShareAssetURL("SART_IMG_8.png"),
            wardrobeShareAssetURL("SART_IMG_9.jpg"),
             wardrobeShareAssetURL("SART_IMG_10.jpg")],
        lookbookPostLikeCount: 322,
        lookbookPostCommentCount: 0),
      
    ]
    save(lookbookPostWorks, forKey: Keys.lookbookPostWorks)
  }

  func wardrobeShareGetWorks() -> [LookbookPostVideo] {
    load([LookbookPostVideo].self, forKey: Keys.lookbookPostWorks, default: [])
  }
    
    func wardrobeShareSaveWorks(_ works: [LookbookPostVideo]) {
        save(works, forKey: Keys.lookbookPostWorks)
    }

  func wardrobeShareGetWorksNotBlock() -> [LookbookPostVideo] {
    let allWorks = wardrobeShareGetWorks()
    let currentUserInfo = wardrobeShareGetUserById(userId: wardrobeShareGetCurrentUserId())

    // 用 $0 指代遍历的每个 work 元素
    return allWorks.filter {
      guard let blacklist = currentUserInfo?.closetProfileBlacklist else { return true }
      return !blacklist.contains($0.lookbookPostCreatorId)
    }
  }

  func wardrobeShareGetWorkDetailById(workId: String) -> LookbookPostVideo? {
    let allWorks = wardrobeShareGetWorks()
    guard
      let workDetail = allWorks.first(where: {
        $0.lookbookPostWorkId == workId
      })
    else {
      return nil
    }

    return workDetail
  }

  func wardrobeShareAddWork(_ work: LookbookPostVideo) {
    var lookbookPostWorks = wardrobeShareGetWorks()
    lookbookPostWorks.insert(work, at: 0)
    save(lookbookPostWorks, forKey: Keys.lookbookPostWorks)
  }

  func wardrobeShareUpdateWork(_ work: LookbookPostVideo) {
    var lookbookPostWorks = wardrobeShareGetWorks()
    guard
      let index = lookbookPostWorks.firstIndex(where: {
        $0.lookbookPostWorkId == work.lookbookPostWorkId
      })
    else {
      return
    }

    lookbookPostWorks[index] = work
    save(lookbookPostWorks, forKey: Keys.lookbookPostWorks)
  }
    
    // like + 1
    func wardrobeShareIncreaseLikeCount(workId: String) {
        var lookbookPostWorks = wardrobeShareGetWorks()
        
        guard let index = lookbookPostWorks.firstIndex(where: {
            $0.lookbookPostWorkId == workId
        }) else {
            return
        }
        
        lookbookPostWorks[index].lookbookPostLikeCount += 1
        
        save(lookbookPostWorks, forKey: Keys.lookbookPostWorks)
    }
    
    // like - 1
    func wardrobeShareDecreaseLikeCount(workId: String) {
        var lookbookPostWorks = wardrobeShareGetWorks()
        
        guard let index = lookbookPostWorks.firstIndex(where: {
            $0.lookbookPostWorkId == workId
        }) else {
            return
        }
        
        if lookbookPostWorks[index].lookbookPostLikeCount > 0 {
            lookbookPostWorks[index].lookbookPostLikeCount -= 1
        }
        
        save(lookbookPostWorks, forKey: Keys.lookbookPostWorks)
    }

    //删除
    func wardrobeShareRemoveCurrentUserAllWorks() {
        let currentUserId = wardrobeShareGetCurrentUserId()
        
        guard !currentUserId.isEmpty else { return }
        
        let allWorks = wardrobeShareGetWorks()
        
        // 过滤掉当前用户的作品
        let filteredWorks = allWorks.filter {
            $0.lookbookPostCreatorId != currentUserId
        }
        
        save(filteredWorks, forKey: Keys.lookbookPostWorks)
    }
}

//Comment
extension WardrobeShareStorageManager {

  private func initializeCommentsIfNeeded() {
    guard storage.data(forKey: Keys.socialThreadComments) == nil else { return }
      
      let socialThreadCommentList: [SocialThreadComment] = [
        SocialThreadComment(
            socialThreadCommentId: "thread_comment_0",
            socialThreadCommentWorkId: "lookbook_post_0",
            socialThreadCommentUserId: "closet_user_2",
            socialThreadCommentText: "Super relaxed vibe! "),
        SocialThreadComment(
            socialThreadCommentId: "thread_comment_1",
            socialThreadCommentWorkId: "lookbook_post_1",
            socialThreadCommentUserId: "closet_user_5",
            socialThreadCommentText: "Easy and fashionable. "),
        SocialThreadComment(
            socialThreadCommentId: "thread_comment_2",
            socialThreadCommentWorkId: "lookbook_post_2",
            socialThreadCommentUserId: "closet_user_3",
            socialThreadCommentText: "Comfort ranks first."),
        SocialThreadComment(
            socialThreadCommentId: "thread_comment_3",
            socialThreadCommentWorkId: "lookbook_post_3",
            socialThreadCommentUserId: "closet_user_2",
            socialThreadCommentText: "Super cool look!"),
        SocialThreadComment(
            socialThreadCommentId: "thread_comment_4",
            socialThreadCommentWorkId: "lookbook_post_1",
            socialThreadCommentUserId: "closet_user_2",
            socialThreadCommentText: "Love it"),
        SocialThreadComment(
            socialThreadCommentId: "thread_comment_5",
            socialThreadCommentWorkId: "lookbook_post_6",
            socialThreadCommentUserId: "closet_user_4",
            socialThreadCommentText: "Dressing well is also a way to love life. "),
        SocialThreadComment(
            socialThreadCommentId: "thread_comment_6",
            socialThreadCommentWorkId: "lookbook_post_7",
            socialThreadCommentUserId: "closet_user_3",
            socialThreadCommentText: "Looks great! "),
        SocialThreadComment(
            socialThreadCommentId: "thread_comment_7",
            socialThreadCommentWorkId: "lookbook_post_7",
            socialThreadCommentUserId: "closet_user_2",
            socialThreadCommentText: "This style suits you so well."),
        SocialThreadComment(
            socialThreadCommentId: "thread_comment_8",
            socialThreadCommentWorkId: "lookbook_post_8",
            socialThreadCommentUserId: "closet_user_1",
            socialThreadCommentText: "Ordinary clothes become special here."),
      ]
    save(socialThreadCommentList, forKey: Keys.socialThreadComments)
  }
    
    func wardrobeShareSaveComments(_ commentsList: [SocialThreadComment]) {
        save(commentsList, forKey: Keys.socialThreadComments)
    }

  func wardrobeShareGetComments(for workId: String) -> [SocialThreadComment] {
    load([SocialThreadComment].self, forKey: Keys.socialThreadComments, default: [])
      .filter { $0.socialThreadCommentWorkId == workId }
  }

  // 获取所有评论
  func wardrobeShareGetAllComments() -> [SocialThreadComment] {
    load([SocialThreadComment].self, forKey: Keys.socialThreadComments, default: [])
  }

  func wardrobeShareAddComment(_ comment: SocialThreadComment) {
    var socialThreadComments = load(
      [SocialThreadComment].self, forKey: Keys.socialThreadComments, default: [])
    socialThreadComments.append(comment)
    save(socialThreadComments, forKey: Keys.socialThreadComments)
  }
    
    func wardrobeShareRemoveCurrentUserAllComments() {
        let currentUserId = wardrobeShareGetCurrentUserId()
        
        guard !currentUserId.isEmpty else { return }
        
        let allComments = wardrobeShareGetAllComments()
        
        // 过滤掉当前用户的评论
        let filteredComments = allComments.filter {
            $0.socialThreadCommentUserId != currentUserId
        }
        
        save(filteredComments, forKey: Keys.socialThreadComments)
    }
}

//ChatRoom & Message
extension WardrobeShareStorageManager {

  private func initializeChatRoomsIfNeeded() {
    guard storage.data(forKey: Keys.closetChatRooms) == nil else { return }
    save([ClosetChatRoom](), forKey: Keys.closetChatRooms)
  }
    
    func wardrobeShareSaveChatRooms(_ chatRooms: [ClosetChatRoom]) {
        save(chatRooms, forKey: Keys.closetChatRooms)
    }
    
    func wardrobeShareSaveChatMessageList(_ msgList: [ClosetChatMessage]) {
        save(msgList, forKey: Keys.closetChatMessages)
    }

  func wardrobeShareGetChatRooms() -> [ClosetChatRoom] {
    load([ClosetChatRoom].self, forKey: Keys.closetChatRooms, default: [])
  }

  // 创建聊天室
  func wardrobeShareCreateChatRoom(chatUsersId: [String]) -> ClosetChatRoom {
    var closetChatRooms: [ClosetChatRoom] = wardrobeShareGetChatRooms()
    let newRoom: ClosetChatRoom = ClosetChatRoom(
      closetChatRoomId: "\(closetChatRooms.count)",
      closetChatUsers: chatUsersId,
      closetChatLastSendMsg: "",
      closetChatLastSendTime: Date(),
      closetChatLastSendUser: wardrobeShareGetCurrentUserId(),
      closetChatUnreadCount: 0
    )
    closetChatRooms.append(newRoom)
    save(closetChatRooms, forKey: Keys.closetChatRooms)

    return newRoom
  }
  // 更新聊天室
  func wardrobeShareUpdateChatRoom(roomId: String, update: (ClosetChatRoom) -> ClosetChatRoom) {
    var closetChatRooms: [ClosetChatRoom] = wardrobeShareGetChatRooms()
    guard let index = closetChatRooms.firstIndex(where: { $0.closetChatRoomId == roomId })
    else {
      return
    }
    closetChatRooms[index] = update(closetChatRooms[index])
    save(closetChatRooms, forKey: Keys.closetChatRooms)
  }
    
    func wardrobeShareRemoveCurrentUserChatRooms() {
        let currentUserId = wardrobeShareGetCurrentUserId()
        
        guard !currentUserId.isEmpty else { return }
        
        let allRooms = wardrobeShareGetChatRooms()
        
        // 过滤掉包含当前用户的聊天室
        let filteredRooms = allRooms.filter {
            !$0.closetChatUsers.contains(currentUserId)
        }
        
        save(filteredRooms, forKey: Keys.closetChatRooms)
    }

    // message
  private func initializeMessagesIfNeeded() {
    guard storage.data(forKey: Keys.closetChatMessages) == nil else { return }
    save([ClosetChatMessage](), forKey: Keys.closetChatMessages)
  }
    
    func wardrobeShareGetAllMessages() -> [ClosetChatMessage] {
      return load([ClosetChatMessage].self, forKey: Keys.closetChatMessages, default: [])
    }

  func wardrobeShareGetMessages(roomId: String) -> [ClosetChatMessage] {
    return load([ClosetChatMessage].self, forKey: Keys.closetChatMessages, default: [])
      .filter { $0.closetChatRoomId == roomId }
  }
    

  func wardrobeShareAddMessage(_ msg: ClosetChatMessage) {
    var closetChatMessages = load(
      [ClosetChatMessage].self, forKey: Keys.closetChatMessages, default: [])
    closetChatMessages.append(msg)
    save(closetChatMessages, forKey: Keys.closetChatMessages)
  }
}

//底层通用存取（核心）
extension WardrobeShareStorageManager {

  fileprivate func save<T: Codable>(_ value: T, forKey key: String) {
    if let data = try? JSONEncoder().encode(value) {
      storage.set(data, forKey: key)
    }
  }

  fileprivate func load<T: Codable>(
    _ type: T.Type,
    forKey key: String,
    default defaultValue: T
  ) -> T {
    guard
      let data = storage.data(forKey: key),
      let value = try? JSONDecoder().decode(type, from: data)
    else {
      return defaultValue
    }
    return value
  }
}
