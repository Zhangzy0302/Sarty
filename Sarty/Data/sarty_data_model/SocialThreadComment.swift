import SwiftUI
import Combine

struct SocialThreadComment: Codable, Equatable {

  let socialThreadCommentId: String
    let socialThreadCommentWorkId: String
    let socialThreadCommentUserId: String
    let socialThreadCommentText: String
    
    func toSocialThreadTargetComment() -> SocialThreadTargetComment {
            return SocialThreadTargetComment(
                commentId: socialThreadCommentId,
                dynamicId: socialThreadCommentWorkId,
                userId: socialThreadCommentUserId,
                content: socialThreadCommentText
            )
        }
}

private enum SocialThreadCommentJsonPlainKeys {
    static let wardrobeShareCommentIdKey = "commentId"
    static let wardrobeShareDynamicIdKey = "dynamicId"
    static let wardrobeShareUserIdKey = "userId"
    static let wardrobeShareContentKey = "content"
}

extension SocialThreadComment {

    init(json: [String: Any]) {

        self.socialThreadCommentId = "\(json[SocialThreadCommentJsonPlainKeys.wardrobeShareCommentIdKey] ?? "")"
        self.socialThreadCommentWorkId = "\(json[SocialThreadCommentJsonPlainKeys.wardrobeShareDynamicIdKey] ?? "")"
        self.socialThreadCommentUserId = "\(json[SocialThreadCommentJsonPlainKeys.wardrobeShareUserIdKey] ?? "")"
        self.socialThreadCommentText = json[SocialThreadCommentJsonPlainKeys.wardrobeShareContentKey] as? String ?? ""
    }
    
    static func fromJsonArray(_ array: [[String: Any]]) -> [SocialThreadComment] {
        return array.map { SocialThreadComment(json: $0) }
    }
}

struct SocialThreadTargetComment: Codable {
    let commentId: String
    let dynamicId: String
    let userId: String
    let content: String
}
