import SwiftUI

struct CatwalkKitTopGlow: View {
    var body: some View {
        LinearGradient(
            stops: [
                .init(color: LookbookShareColorStyle.runwayGlowYellow, location: 0),
                .init(color: Color(red: 1.0, green: 0.91, blue: 0.56), location: 0.28),
                .init(color: LookbookShareColorStyle.lookbookSoftCanvas, location: 0.62)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .frame(height: 360)
        .ignoresSafeArea()
    }
}

struct CatwalkKitAvatar: View {
    let catwalkKitInitials: String
    let catwalkKitDiameter: CGFloat
    let catwalkKitGradient: [Color]

    var body: some View {
        ZStack {
            LinearGradient(colors: catwalkKitGradient, startPoint: .topLeading, endPoint: .bottomTrailing)

            Text(catwalkKitInitials)
                .font(.system(size: catwalkKitDiameter * 0.34, weight: .heavy))
                .foregroundStyle(.white)
        }
        .frame(width: catwalkKitDiameter, height: catwalkKitDiameter)
        .clipShape(Circle())
    }
}

struct CatwalkKitRemoteAvatar: View {
    let catwalkKitAvatarURL: String
    let catwalkKitInitials: String
    let catwalkKitDiameter: CGFloat
    let catwalkKitGradient: [Color]

    var body: some View {
        RunwayGalleryAdaptiveImage(
            catwalkKitAvatarURL,
            runwayGalleryContentMode: .fill,
            runwayGalleryPlaceholder: {
                CatwalkKitAvatar(
                    catwalkKitInitials: catwalkKitInitials,
                    catwalkKitDiameter: catwalkKitDiameter,
                    catwalkKitGradient: catwalkKitGradient
                )
            }
        )
        .frame(width: catwalkKitDiameter, height: catwalkKitDiameter)
        .clipShape(Circle())
    }
}

struct CatwalkKitPhotoTile: View {
    let catwalkKitGradient: [Color]
    var catwalkKitCornerRadius: CGFloat = 12
    var catwalkKitOverlaySymbol: String?

    var body: some View {
        ZStack {
            LinearGradient(colors: catwalkKitGradient, startPoint: .topLeading, endPoint: .bottomTrailing)

            Circle()
                .fill(Color.white.opacity(0.22))
                .frame(width: 92, height: 92)
                .offset(x: 70, y: -72)

            Circle()
                .fill(Color.white.opacity(0.12))
                .frame(width: 120, height: 120)
                .offset(x: -78, y: 82)

            if let catwalkKitOverlaySymbol {
                Image(systemName: catwalkKitOverlaySymbol)
                    .font(.system(size: 30, weight: .heavy))
                    .foregroundStyle(.white.opacity(0.92))
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: catwalkKitCornerRadius, style: .continuous))
    }
}

struct CatwalkKitRemotePhotoTile: View {
    let catwalkKitSource: String
    let catwalkKitGradient: [Color]
    var catwalkKitCornerRadius: CGFloat = 12

    var body: some View {
        ZStack {
            CatwalkKitPhotoTile(
                catwalkKitGradient: catwalkKitGradient,
                catwalkKitCornerRadius: catwalkKitCornerRadius
            )

            RunwayGalleryAdaptiveImage(
                catwalkKitSource,
                runwayGalleryContentMode: .fill,
                runwayGalleryPlaceholder: {
                    Color.clear
                }
            )
        }
        .clipped()
        .clipShape(RoundedRectangle(cornerRadius: catwalkKitCornerRadius, style: .continuous))
    }
}

struct CatwalkKitMetricPill: View {
    var catwalkKitIconName: String?
    var catwalkKitSystemName: String?
    let catwalkKitTitle: String
    var catwalkKitTint = Color(red: 1.0, green: 0.29, blue: 0.38)

    var body: some View {
        HStack(spacing: 6) {
            if let catwalkKitIconName {
                Image(catwalkKitIconName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
            } else if let catwalkKitSystemName {
                Image(systemName: catwalkKitSystemName)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(catwalkKitTint)
            }

            Text(catwalkKitTitle)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.black.opacity(0.45))
        }
        .padding(.horizontal, 12)
        .frame(height: 34)
        .background(Color.black.opacity(0.035))
        .clipShape(Capsule())
    }
}

struct CatwalkKitEmptyState: View {
    let catwalkKitTitle: String
    var catwalkKitTopPadding: CGFloat = 42
    var catwalkKitVerticalPadding: CGFloat = 0

    var body: some View {
        Text(catwalkKitTitle)
            .font(.system(size: 14, weight: .semibold))
            .foregroundStyle(LookbookShareColorStyle.styleCircleInk.opacity(0.48))
            .frame(maxWidth: .infinity)
            .padding(.top, catwalkKitTopPadding)
            .padding(.vertical, catwalkKitVerticalPadding)
    }
}

enum CatwalkKitProfileText {
    static func displayName(_ catwalkKitUser: ClosetProfileUser?, fallback: String = "Sarty") -> String {
        let catwalkKitName = catwalkKitUser?.closetProfileUserName.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return catwalkKitName.isEmpty ? fallback : catwalkKitName
    }

    static func initials(_ catwalkKitName: String) -> String {
        String(catwalkKitName.prefix(1)).uppercased()
    }
}

enum CatwalkKitPalette {
    static let catwalkKitWarmUserPalettes: [[Color]] = [
        [Color(red: 0.10, green: 0.61, blue: 0.72), Color(red: 0.94, green: 0.72, blue: 0.50)],
        [Color(red: 0.72, green: 0.42, blue: 0.38), Color(red: 0.24, green: 0.18, blue: 0.16)],
        [Color(red: 0.91, green: 0.76, blue: 0.55), Color(red: 0.48, green: 0.36, blue: 0.26)],
        [Color(red: 0.82, green: 0.45, blue: 0.50), Color(red: 0.32, green: 0.18, blue: 0.23)]
    ]

    static let catwalkKitPostPalettes: [[Color]] = [
        [Color(red: 0.42, green: 0.37, blue: 0.95), Color(red: 0.72, green: 0.18, blue: 0.86)],
        [Color(red: 0.88, green: 0.60, blue: 0.45), Color(red: 0.35, green: 0.25, blue: 0.22)],
        [Color(red: 0.12, green: 0.60, blue: 0.72), Color(red: 0.94, green: 0.72, blue: 0.50)],
        [Color(red: 0.82, green: 0.45, blue: 0.50), Color(red: 0.32, green: 0.18, blue: 0.23)]
    ]

    static func pick(seed: String, from catwalkKitPalettes: [[Color]] = catwalkKitWarmUserPalettes) -> [Color] {
        guard !catwalkKitPalettes.isEmpty else {
            return [LookbookShareColorStyle.runwayGlowYellow, LookbookShareColorStyle.styleCircleInk]
        }

        return catwalkKitPalettes[abs(seed.hashValue) % catwalkKitPalettes.count]
    }
}

enum CatwalkKitNumberFormatter {
    static func compact(_ catwalkKitValue: Int) -> String {
        if catwalkKitValue >= 1_000 {
            return String(format: "%.1fK", Double(catwalkKitValue) / 1_000)
        }

        return "\(catwalkKitValue)"
    }
}

struct CatwalkKitMoreDot: View {
    var catwalkKitForeground = Color.black.opacity(0.35)
    var catwalkKitBackground = Color.black.opacity(0.035)
    var catwalkKitAction: () -> Void = {}

    var body: some View {
        Button {
            catwalkKitAction()
        } label: {
            Image(systemName: "ellipsis")
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(catwalkKitForeground)
                .frame(width: 38, height: 34)
                .background(catwalkKitBackground)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}
