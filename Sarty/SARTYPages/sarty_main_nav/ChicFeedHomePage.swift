
import SwiftUI

struct ChicFeedHomePage: View {
    let chicFeedPostRouteAction: () -> Void
    let chicFeedAssistantRouteAction: () -> Void
    let chicFeedPostDetailRouteAction: (String) -> Void
    let chicFeedMoreUserAction: (String, @escaping () -> Void) -> Void
    @StateObject private var chicFeedPostViewModel = LookbookPostVideoViewModel()
    @StateObject private var chicFeedUserViewModel = ClosetProfileUserViewModel()

    init(
        chicFeedPostRouteAction: @escaping () -> Void = {},
        chicFeedAssistantRouteAction: @escaping () -> Void = {},
        chicFeedPostDetailRouteAction: @escaping (String) -> Void = { _ in },
        chicFeedMoreUserAction: @escaping (String, @escaping () -> Void) -> Void = { _, _ in }
    ) {
        self.chicFeedPostRouteAction = chicFeedPostRouteAction
        self.chicFeedAssistantRouteAction = chicFeedAssistantRouteAction
        self.chicFeedPostDetailRouteAction = chicFeedPostDetailRouteAction
        self.chicFeedMoreUserAction = chicFeedMoreUserAction
    }

    var body: some View {
        ZStack(alignment: .top) {
            CatwalkKitTopGlow()

            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Sarty")
                        .font(.system(size: 29, weight: .black, design: .rounded))
                        .foregroundStyle(LookbookShareColorStyle.styleCircleInk)
                        .padding(.top, 10)
                        .padding(.horizontal, 22)

                    ChicFeedPostNowBanner(chicFeedPostRouteAction: chicFeedPostRouteAction)
                        .padding(.horizontal, 22)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(alignment: .top, spacing: 16) {
                            ForEach(chicFeedPostViewModel.allNotBlockWorks) { chicFeedPost in
                                ChicFeedPostCard(
                                    chicFeedPost: chicFeedPost,
                                    chicFeedCreator: chicFeedPostViewModel.getUserByCreatorId(creatorId: chicFeedPost.lookbookPostCreatorId),
                                    chicFeedCurrentUserId: chicFeedUserViewModel.currentUserID,
                                    chicFeedIsLiked: chicFeedUserViewModel.currentUser?.closetProfileLikePosts.contains(chicFeedPost.lookbookPostWorkId) == true,
                                    chicFeedIsFollowing: chicFeedUserViewModel.currentUser?.closetProfileFollowing.contains(chicFeedPost.lookbookPostCreatorId) == true,
                                    chicFeedPostDetailRouteAction: chicFeedPostDetailRouteAction,
                                    chicFeedLikeToggleAction: {
                                        chicFeedToggleLikePost(chicFeedPost.lookbookPostWorkId)
                                    },
                                    chicFeedFollowToggleAction: {
                                        chicFeedToggleFollowUser(chicFeedPost.lookbookPostCreatorId)
                                    },
                                    chicFeedMoreAction: {
                                        chicFeedMoreUserAction(chicFeedPost.lookbookPostCreatorId) {
                                            chicFeedShieldUser(chicFeedPost.lookbookPostCreatorId)
                                        }
                                    }
                                )
                                    .frame(width: 288)
                            }
                        }
                        .padding(.horizontal, 22)
                    }

                    ChicFeedAssistantBanner(chicFeedAssistantRouteAction: chicFeedAssistantRouteAction)
                        .padding(.horizontal, 22)
                        .padding(.bottom, 112)
                }
            }
        }
        .onAppear {
            chicFeedRefreshPostState()
        }
    }

    private func chicFeedRefreshPostState() {
        chicFeedUserViewModel.loadLoginClosetProfileUser()
        chicFeedPostViewModel.allNotBlockWorks = chicFeedPostViewModel.getAllNotBlockLookbookPostWorksByType(type: 0)
    }

    private func chicFeedToggleLikePost(_ postId: String) {
        chicFeedUserViewModel.loadLoginClosetProfileUser()
        guard chicFeedUserViewModel.currentUser != nil else { return }
        chicFeedUserViewModel.toggleVideoIsLiked(postId)
        chicFeedRefreshPostState()
    }

    private func chicFeedToggleFollowUser(_ userId: String) {
        chicFeedUserViewModel.loadLoginClosetProfileUser()
        guard chicFeedUserViewModel.currentUser != nil else { return }
        chicFeedUserViewModel.toggleUserIsFollowed(followUserId: userId)
        chicFeedRefreshPostState()
    }

    private func chicFeedShieldUser(_ userId: String) {
        chicFeedUserViewModel.closetProfileBlockUser(blockUserId: userId)
        chicFeedRefreshPostState()
        RunwaySignalHUDCenter.shared.runwaySignalShowToast("Shielded successfully", kind: .success)
    }
}

private struct ChicFeedPostNowBanner: View {
    let chicFeedPostRouteAction: () -> Void

    var body: some View {
        ZStack(alignment: .trailing) {
            Image("SARTY_post_bg")
                .resizable()
                .scaledToFill()
                .frame(height: 82)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

            Image("SARTY_post_decoration")
                .resizable()
                .scaledToFit()
                .frame(width: 96, height: 96)
                .offset(x: -8, y: -6)

            HStack {
                VStack(alignment: .leading, spacing: 9) {
                    Text("High-quality post")
                        .font(.system(size: 20, weight: .heavy))
                        .foregroundStyle(.white)
                        .lineLimit(1)

                    Button {
                        chicFeedPostRouteAction()
                    } label: {
                        Text("+ Post now")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(.black)
                            .padding(.horizontal, 18)
                            .frame(height: 36)
                            .background(LookbookShareColorStyle.runwayGlowYellow)
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }

                Spacer()
            }
            .padding(.leading, 16)
        }
    }
}

private struct ChicFeedPostCard: View {
    private let streetStyleCoverWidth: CGFloat = 264
    private let streetStyleCoverHeight: CGFloat = 300
    let chicFeedPost: LookbookPostVideo
    let chicFeedCreator: ClosetProfileUser?
    let chicFeedCurrentUserId: String
    let chicFeedIsLiked: Bool
    let chicFeedIsFollowing: Bool
    let chicFeedPostDetailRouteAction: (String) -> Void
    let chicFeedLikeToggleAction: () -> Void
    let chicFeedFollowToggleAction: () -> Void
    let chicFeedMoreAction: () -> Void

    private var runwayMomentIsMyPost: Bool {
        chicFeedPost.lookbookPostCreatorId == chicFeedCurrentUserId
    }

    private var runwayMomentCreatorName: String {
        CatwalkKitProfileText.displayName(chicFeedCreator)
    }

    private var runwayMomentCreatorInitials: String {
        CatwalkKitProfileText.initials(runwayMomentCreatorName)
    }

    private var runwayMomentGradient: [Color] {
        CatwalkKitPalette.pick(seed: chicFeedPost.lookbookPostCreatorId)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                CatwalkKitRemoteAvatar(
                    catwalkKitAvatarURL: chicFeedCreator?.closetProfileAvatar ?? "",
                    catwalkKitInitials: runwayMomentCreatorInitials,
                    catwalkKitDiameter: 42,
                    catwalkKitGradient: runwayMomentGradient
                )

                VStack(alignment: .leading, spacing: 1) {
                    Text(runwayMomentCreatorName)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(LookbookShareColorStyle.styleCircleInk)
                    
                }

                Spacer()

                if !runwayMomentIsMyPost {
                    Button {
                        chicFeedFollowToggleAction()
                    } label: {
                        Text(chicFeedIsFollowing ? "Following" : "Follow")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(chicFeedIsFollowing ? .white : .black)
                            .lineLimit(1)
                            .minimumScaleFactor(0.78)
                            .frame(width: 82, height: 40)
                            .background(
                                chicFeedIsFollowing
                                ? LookbookShareColorStyle.styleCircleInk
                                : LookbookShareColorStyle.runwayGlowYellow
                            )
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }

            Button {
                chicFeedPostDetailRouteAction(chicFeedPost.lookbookPostWorkId)
            } label: {
                CatwalkKitRemotePhotoTile(
                    catwalkKitSource: chicFeedPost.lookbookPostPic.first ?? "",
                    catwalkKitGradient: runwayMomentGradient
                )
                .frame(width: streetStyleCoverWidth, height: streetStyleCoverHeight)
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
            .buttonStyle(.plain)

            HStack(spacing: 14) {
                Button {
                    chicFeedLikeToggleAction()
                } label: {
                    CatwalkKitMetricPill(
                        catwalkKitIconName: chicFeedIsLiked ? "SARTY_like" : "SARTY_like_no",
                        catwalkKitTitle: "\(chicFeedPost.lookbookPostLikeCount)"
                    )
                }
                .buttonStyle(.plain)

                CatwalkKitMetricPill(
                    catwalkKitSystemName: "bubble.left.fill",
                    catwalkKitTitle: "\(chicFeedPost.lookbookPostCommentCount)",
                    catwalkKitTint: Color(red: 0.05, green: 0.31, blue: 1.0)
                )
                Spacer()
                if !runwayMomentIsMyPost {
                    CatwalkKitMoreDot(catwalkKitAction: chicFeedMoreAction)
                }
            }
        }
        .padding(12)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .shadow(color: Color.black.opacity(0.04), radius: 12, y: 6)
    }
}

private struct ChicFeedAssistantBanner: View {
    let chicFeedAssistantRouteAction: () -> Void

    var body: some View {
        ZStack(alignment: .topLeading){
            HStack{
                Spacer()
                Image("SARTY_AI_logo")
                    .resizable()
                    .frame(width: 102, height: 94)
                    .opacity(0.2)
                    .offset(x: 7, y: -34)
            }
            VStack{
                Spacer()
                HStack(spacing: 0) {
                    Image("SARTY_ai_robot")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 72, height: 72)
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color(red: 235/255, green: 248/255, blue: 241/255))
                        ).padding(.trailing, 12)

                    VStack(alignment: .leading, spacing: 1) {
                        Text("Your Clothing")
                            .font(.system(size: 20, weight: .regular))
                        Text("Assistant")
                            .font(.system(size: 20, weight: .heavy))
                    }
                    .foregroundStyle(LookbookShareColorStyle.styleCircleInk)

                    Spacer()
                    
                    VStack{
                        Spacer()
                        HStack(spacing: 7) {
                            Text("Try it")
                            Image(systemName: "chevron.right.circle.fill")
                        }
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 12)
                        .frame(height: 32)
                        .background(LookbookShareColorStyle.styleCircleInk)
                        .clipShape(Capsule())
                    }
                    
                }
                .padding(.horizontal, 12)
                Spacer()
            }
            
            
            Text("Sarty AI")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 88, height: 20)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(
                            LinearGradient(colors: [
                                Color(red: 33/255, green: 92/255, blue: 1),
                                Color(red: 33/255, green: 92/255, blue: 1).opacity(0)
                            ], startPoint: .leading, endPoint: .trailing)
                        )
                ).padding(8)
            Image("SARTY_AI_logo")
                .resizable()
                .frame(width: 24, height: 21)
                .padding(.top, 7)
            
        }
        
        .frame(height: 96)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .contentShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .onTapGesture {
            chicFeedAssistantRouteAction()
        }
    }
}

#Preview {
    ChicFeedHomePage()
}
