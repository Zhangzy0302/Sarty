
import SwiftUI

struct ReelRadarDiscoverPage: View {
    private let reelRadarColumns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    let reelRadarPublishRouteAction: () -> Void
    let reelRadarVideoDetailRouteAction: (String) -> Void
    let reelRadarMoreUserAction: (String, @escaping () -> Void) -> Void
    @StateObject private var reelRadarPostViewModel = LookbookPostVideoViewModel()
    @StateObject private var reelRadarUserViewModel = ClosetProfileUserViewModel()

    init(
        reelRadarPublishRouteAction: @escaping () -> Void = {},
        reelRadarVideoDetailRouteAction: @escaping (String) -> Void = { _ in },
        reelRadarMoreUserAction: @escaping (String, @escaping () -> Void) -> Void = { _, _ in }
    ) {
        self.reelRadarPublishRouteAction = reelRadarPublishRouteAction
        self.reelRadarVideoDetailRouteAction = reelRadarVideoDetailRouteAction
        self.reelRadarMoreUserAction = reelRadarMoreUserAction
    }

    var body: some View {
        ZStack(alignment: .top) {
            CatwalkKitTopGlow()

            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .center) {
                    VStack(alignment: .leading, spacing: 3) {
                        Text("Discover")
                            .font(.system(size: 26, weight: .heavy))
                            .foregroundStyle(LookbookShareColorStyle.styleCircleInk)

                        Text("Searching for inspiration")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(LookbookShareColorStyle.styleCircleInk.opacity(0.52))
                    }

                    Spacer()

                    Button {
                        reelRadarPublishRouteAction()
                    } label: {
                        Image("SARTY_post_video_btn")
                            .resizable()
                            .frame(width: 68, height: 40)
                            .background(LookbookShareColorStyle.styleCircleInk)
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
                .padding(.top, 10)
                
                ScrollView(.vertical, showsIndicators: false) {
                    LazyVGrid(columns: reelRadarColumns, spacing: 12) {
                        ForEach(reelRadarPostViewModel.allNotBlockWorks) { reelRadarPost in
                            ReelRadarVideoCard(
                                reelRadarPost: reelRadarPost,
                                reelRadarCreator: reelRadarPostViewModel.getUserByCreatorId(creatorId: reelRadarPost.lookbookPostCreatorId),
                                reelRadarIsLiked: reelRadarUserViewModel.currentUser?.closetProfileLikePosts.contains(reelRadarPost.lookbookPostWorkId) == true,
                                reelRadarMoreAction: {
                                    reelRadarMoreUserAction(reelRadarPost.lookbookPostCreatorId) {
                                        reelRadarShieldUser(reelRadarPost.lookbookPostCreatorId)
                                    }
                                }
                            )
                            .contentShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                            .onTapGesture {
                                reelRadarVideoDetailRouteAction(reelRadarPost.lookbookPostWorkId)
                            }
                        }
                    }
                    .padding(.bottom, 112)
                }
                
            }
            .padding(.horizontal, 20)
        }
        .onAppear {
            reelRadarRefreshPostState()
        }
    }

    private func reelRadarRefreshPostState() {
        reelRadarUserViewModel.loadLoginClosetProfileUser()
        reelRadarPostViewModel.allNotBlockWorks = reelRadarPostViewModel.getAllNotBlockLookbookPostWorksByType(type: 1)
    }

    private func reelRadarShieldUser(_ userId: String) {
        reelRadarUserViewModel.closetProfileBlockUser(blockUserId: userId)
        reelRadarRefreshPostState()
        RunwaySignalHUDCenter.shared.runwaySignalShowToast("Shielded successfully", kind: .success)
    }
}

private struct ReelRadarVideoCard: View {
    private let reelRadarCoverHeight: CGFloat = 188
    let reelRadarPost: LookbookPostVideo
    let reelRadarCreator: ClosetProfileUser?
    let reelRadarIsLiked: Bool
    let reelRadarMoreAction: () -> Void

    private var reelRadarCreatorName: String {
        CatwalkKitProfileText.displayName(reelRadarCreator)
    }

    private var reelRadarCreatorInitials: String {
        CatwalkKitProfileText.initials(reelRadarCreatorName)
    }

    private var reelRadarGradient: [Color] {
        CatwalkKitPalette.pick(seed: reelRadarPost.lookbookPostCreatorId)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 9) {
            GeometryReader { reelRadarCoverProxy in
                ZStack(alignment: .top) {
                    CatwalkKitRemotePhotoTile(
                        catwalkKitSource: reelRadarPost.lookbookPostPic.first ?? "",
                        catwalkKitGradient: reelRadarGradient,
                        catwalkKitCornerRadius: 13
                    )
                    .frame(
                        width: reelRadarCoverProxy.size.width,
                        height: reelRadarCoverHeight
                    )

                    HStack {
                        HStack(spacing: 5) {
                            Image(reelRadarIsLiked ? "SARTY_like" : "SARTY_like_no")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 18, height: 18)
                            Text("\(reelRadarPost.lookbookPostLikeCount)")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(.white)
                        }

                        Spacer()

                        Button {
                            reelRadarMoreAction()
                        } label: {
                            ZStack {
                                Color.clear
                                Image(systemName: "ellipsis")
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundStyle(.white)
                                    .frame(width: 30, height: 30)
                            }
                            .frame(width: 44, height: 44)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(10)
                }
            }
            .frame(height: reelRadarCoverHeight)
            .clipShape(RoundedRectangle(cornerRadius: 13, style: .continuous))
            .clipped()

            HStack(spacing: 7) {
                CatwalkKitRemoteAvatar(
                    catwalkKitAvatarURL: reelRadarCreator?.closetProfileAvatar ?? "",
                    catwalkKitInitials: reelRadarCreatorInitials,
                    catwalkKitDiameter: 24,
                    catwalkKitGradient: reelRadarGradient
                )

                Text(reelRadarCreatorName)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(LookbookShareColorStyle.styleCircleInk)
                    .lineLimit(1)
            }
            .padding(.horizontal, 6)
            .padding(.bottom, 8)
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay{
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Image("SARTY_icon_play")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 44, height: 44)
                        .padding(.trailing, 8)
                        .padding(.bottom, 22)
                }
            }
        }
    }
}
