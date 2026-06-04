
import SwiftUI

struct ThreadTalkMessagePage: View {
    let threadTalkChatRouteAction: (String) -> Void
    @StateObject private var threadTalkChatViewModel = ClosetChatViewModel()
    @State private var threadTalkCurrentUserId = ""

    init(threadTalkChatRouteAction: @escaping (String) -> Void = { _ in }) {
        self.threadTalkChatRouteAction = threadTalkChatRouteAction
    }

    var body: some View {
        ZStack(alignment: .top) {
            CatwalkKitTopGlow()

            VStack(alignment: .leading, spacing: 14) {
                Text("Message")
                    .font(.system(size: 25, weight: .heavy))
                    .foregroundStyle(LookbookShareColorStyle.styleCircleInk)
                    .padding(.top, 10)

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 10) {
                        ForEach(threadTalkChatViewModel.myChatRooms) { threadTalkRoom in
                            Button {
                                threadTalkMarkUnreadAsReadIfNeeded(threadTalkRoom)
                                threadTalkChatRouteAction(threadTalkRoom.closetChatRoomId)
                            } label: {
                                ThreadTalkChatRow(
                                    threadTalkRoom: threadTalkRoom,
                                    threadTalkUser: threadTalkChatViewModel.getClosetChatUserInfo(chatRoomId: threadTalkRoom.closetChatRoomId),
                                    threadTalkCurrentUserId: threadTalkCurrentUserId
                                )
                            }
                            .buttonStyle(.plain)
                        }

                        if threadTalkChatViewModel.myChatRooms.isEmpty {
                            CatwalkKitEmptyState(catwalkKitTitle: "No messages yet.")
                        }
                    }
                    .padding(.bottom, 112)
                }
            }
            .padding(.horizontal, 20)
        }
        .onAppear {
            threadTalkRefreshChatRooms()
        }
    }

    private func threadTalkRefreshChatRooms() {
        threadTalkCurrentUserId = WardrobeShareStorageManager.shared.wardrobeShareGetCurrentUserId()
        threadTalkChatViewModel.myChatRooms = threadTalkChatViewModel.getMyClosetChatRoomsNotBlock()
            .sorted { $0.closetChatLastSendTime > $1.closetChatLastSendTime }
    }

    private func threadTalkMarkUnreadAsReadIfNeeded(_ threadTalkRoom: ClosetChatRoom) {
        guard threadTalkRoom.closetChatUnreadCount > 0,
              threadTalkRoom.closetChatLastSendUser != threadTalkCurrentUserId else {
            return
        }

        WardrobeShareStorageManager.shared.wardrobeShareUpdateChatRoom(roomId: threadTalkRoom.closetChatRoomId) { threadTalkStoredRoom in
            var threadTalkReadRoom = threadTalkStoredRoom
            threadTalkReadRoom.closetChatUnreadCount = 0
            return threadTalkReadRoom
        }

        threadTalkRefreshChatRooms()
    }
}

private struct ThreadTalkChatRow: View {
    let threadTalkRoom: ClosetChatRoom
    let threadTalkUser: ClosetProfileUser?
    let threadTalkCurrentUserId: String

    private var threadTalkName: String {
        CatwalkKitProfileText.displayName(threadTalkUser)
    }

    private var threadTalkInitials: String {
        CatwalkKitProfileText.initials(threadTalkName)
    }

    private var threadTalkLastMessage: String {
        let threadTalkMessage = threadTalkRoom.closetChatLastSendMsg.trimmingCharacters(in: .whitespacesAndNewlines)
        return threadTalkMessage.isEmpty ? "Start a stylish chat." : threadTalkMessage
    }

    private var threadTalkTimeText: String {
        ThreadTalkTimeFormatter.threadTalkFormat(threadTalkRoom.closetChatLastSendTime)
    }

    private var threadTalkGradient: [Color] {
        CatwalkKitPalette.pick(seed: threadTalkUser?.closetProfileUserId ?? threadTalkRoom.closetChatRoomId)
    }

    private var threadTalkShouldShowUnreadBadge: Bool {
        threadTalkRoom.closetChatUnreadCount > 0
        && threadTalkRoom.closetChatLastSendUser != threadTalkCurrentUserId
    }

    var body: some View {
        HStack(spacing: 13) {
            CatwalkKitRemoteAvatar(
                catwalkKitAvatarURL: threadTalkUser?.closetProfileAvatar ?? "",
                catwalkKitInitials: threadTalkInitials,
                catwalkKitDiameter: 52,
                catwalkKitGradient: threadTalkGradient
            )

            VStack(alignment: .leading, spacing: 3) {
                Text(threadTalkName)
                    .font(.system(size: 16, weight: .heavy))
                    .foregroundStyle(LookbookShareColorStyle.styleCircleInk)
                    .lineLimit(1)

                Text(threadTalkLastMessage)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(Color.black.opacity(0.35))
                    .lineLimit(1)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 8) {
                Text(threadTalkTimeText)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Color.black.opacity(0.45))
                    .lineLimit(1)

                if threadTalkShouldShowUnreadBadge {
                    Text("\(threadTalkRoom.closetChatUnreadCount)")
                        .font(.system(size: 10, weight: .heavy))
                        .foregroundStyle(.white)
                        .frame(width: 19, height: 19)
                        .background(Color(red: 1.0, green: 0.34, blue: 0.25))
                        .clipShape(Circle())
                }
            }
        }
        .padding(.horizontal, 13)
        .frame(height: 66)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

private enum ThreadTalkTimeFormatter {
    static func threadTalkFormat(_ threadTalkDate: Date) -> String {
        let threadTalkFormatter = DateFormatter()
        threadTalkFormatter.locale = Locale(identifier: "en_US_POSIX")

        if Calendar.current.isDateInToday(threadTalkDate) {
            threadTalkFormatter.dateFormat = "h:mm a"
        } else {
            threadTalkFormatter.dateFormat = "MMM d"
        }

        return threadTalkFormatter.string(from: threadTalkDate)
    }
}
