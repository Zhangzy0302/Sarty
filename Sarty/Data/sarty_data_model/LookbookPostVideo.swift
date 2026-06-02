import SwiftUI
import Combine

struct LookbookPostVideo: Codable, Identifiable, Equatable {

  let lookbookPostWorkId: String
  var lookbookPostCreatorId: String
    var lookbookPostType: Int
  var lookbookPostTextContent: String
    var lookbookPostTitleType: Int
  var lookbookPostVideoUrl: String
  var lookbookPostPic: [String]
  var lookbookPostLikeCount: Int
    var lookbookPostCommentCount: Int

  var id: String { lookbookPostWorkId }
    
    func toLookbookPostTargetItem() -> LookbookPostTargetItem {
            return LookbookPostTargetItem(
                dynamicId: lookbookPostWorkId,
                userId: lookbookPostCreatorId,
                dynamicType: lookbookPostType,
                dynamicDesc: lookbookPostTextContent,
                dynamicTitleType: lookbookPostTitleType,
                dynamicPic: lookbookPostPic,
                dynamicVideo: lookbookPostVideoUrl,
                dynamicLikeCount: lookbookPostLikeCount,
                dynamicCommentCount: lookbookPostCommentCount
            )
        }
}

private enum LookbookPostVideoJsonPlainKeys {
    static let wardrobeShareDynamicIdKey = "dynamicId"
    static let wardrobeShareUserIdKey = "userId"
    static let wardrobeShareDynamicTypeKey = "dynamicType"
    static let wardrobeShareDynamicDescKey = "dynamicDesc"
    static let wardrobeShareDynamicTitleTypeKey = "dynamicTitleType"
    static let wardrobeShareDynamicVideoKey = "dynamicVideo"
    static let wardrobeShareDynamicLikeCountKey = "dynamicLikeCount"
    static let wardrobeShareDynamicCommentCountKey = "dynamicCommentCount"
    static let wardrobeShareDynamicPicKey = "dynamicPic"
}

extension LookbookPostVideo {

    init(json: [String: Any]) {

        self.lookbookPostWorkId = "\(json[LookbookPostVideoJsonPlainKeys.wardrobeShareDynamicIdKey] ?? "")"
        self.lookbookPostCreatorId = "\(json[LookbookPostVideoJsonPlainKeys.wardrobeShareUserIdKey] ?? "")"
        self.lookbookPostType = json[LookbookPostVideoJsonPlainKeys.wardrobeShareDynamicTypeKey] as? Int ?? 0
        self.lookbookPostTextContent = json[LookbookPostVideoJsonPlainKeys.wardrobeShareDynamicDescKey] as? String ?? ""
        self.lookbookPostTitleType = json[LookbookPostVideoJsonPlainKeys.wardrobeShareDynamicTitleTypeKey] as? Int ?? 0
        self.lookbookPostVideoUrl = json[LookbookPostVideoJsonPlainKeys.wardrobeShareDynamicVideoKey] as? String ?? ""
        self.lookbookPostLikeCount = json[LookbookPostVideoJsonPlainKeys.wardrobeShareDynamicLikeCountKey] as? Int ?? 0
        self.lookbookPostCommentCount = json[LookbookPostVideoJsonPlainKeys.wardrobeShareDynamicCommentCountKey] as? Int ?? 0

        // 👇 图片数组（兼容 __NSArrayM）
        self.lookbookPostPic = (json[LookbookPostVideoJsonPlainKeys.wardrobeShareDynamicPicKey] as? [Any])?.map { "\($0)" } ?? []
    }
    
    static func fromJsonArray(_ array: [[String: Any]]) -> [LookbookPostVideo] {
            return array.map { LookbookPostVideo(json: $0) }
        }
}

struct LookbookPostTargetItem: Codable {
    let dynamicId: String
    let userId: String
    let dynamicType: Int
    let dynamicDesc: String
    let dynamicTitleType: Int
    let dynamicPic: [String]
    let dynamicVideo: String
    let dynamicLikeCount: Int
    let dynamicCommentCount: Int
}

@MainActor
final class LookbookPostVideoViewModel: ObservableObject {

  @Published var allWorks: [LookbookPostVideo] = []
  @Published var allNotBlockWorks: [LookbookPostVideo] = []
//  @Published var userWorks: [LookbookPostVideo] = []
  @Published var myFollowingUserWorks: [LookbookPostVideo] = []

  private let storage = WardrobeShareStorageManager.shared

  func getAllLookbookPostWorks() {
    allWorks = storage.wardrobeShareGetWorks()
  }

  func getAllNotBlockLookbookPostWorks() {
    let allWorks: [LookbookPostVideo] = storage.wardrobeShareGetWorks()
    if let lookbookPostMyInfo = storage.wardrobeShareGetUserById(userId: storage.wardrobeShareGetCurrentUserId()) {
      allNotBlockWorks = allWorks.filter {
        !lookbookPostMyInfo.closetProfileBlacklist.contains($0.lookbookPostCreatorId)
      }
    }

  }
    
    // get by type
    func getAllNotBlockLookbookPostWorksByType(type: Int) -> [LookbookPostVideo] {
      let allWorks: [LookbookPostVideo] = storage.wardrobeShareGetWorks()
      if let lookbookPostMyInfo = storage.wardrobeShareGetUserById(userId: storage.wardrobeShareGetCurrentUserId()) {
        return allWorks.filter {
          !lookbookPostMyInfo.closetProfileBlacklist.contains($0.lookbookPostCreatorId)
            && $0.lookbookPostType == type
        }
      }else {
          return []
      }

    }
    
    // get my works
    func getMyLookbookPostWorks() -> [LookbookPostVideo] {
      let allWorks: [LookbookPostVideo] = storage.wardrobeShareGetWorks()
        return allWorks.filter {
            $0.lookbookPostCreatorId == storage.wardrobeShareGetCurrentUserId()
        }

    }


    func getLookbookPostWorksByUserIdAndType(userId: String, type: Int) -> [LookbookPostVideo] {
    let allPostWorks: [LookbookPostVideo] = storage.wardrobeShareGetWorks()
    return allPostWorks.filter {
        $0.lookbookPostCreatorId == userId && $0.lookbookPostType == type
    }
  }

  func getMyFollowingLookbookPostWorks() {
    let currentUserId = storage.wardrobeShareGetCurrentUserId()
    guard let currentUserInfo: ClosetProfileUser = storage.wardrobeShareGetUserById(userId: currentUserId)
    else {
      return
    }
    let allPostWorks: [LookbookPostVideo] = storage.wardrobeShareGetWorks()
    let myFollowingWorks: [LookbookPostVideo] = allPostWorks.filter {
      currentUserInfo.closetProfileFollowing.contains($0.lookbookPostCreatorId)
        && !currentUserInfo.closetProfileBlacklist.contains($0.lookbookPostCreatorId)
    }
    myFollowingUserWorks = myFollowingWorks
  }

  func getUserByCreatorId(creatorId: String) -> ClosetProfileUser? {
    return storage.wardrobeShareGetUserById(userId: creatorId)
  }

}
