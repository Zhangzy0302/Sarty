import SwiftUI
import Combine

enum RunwaySignalToastKind {
    case normal
    case error
    case success

    var runwaySignalBackground: Color {
        switch self {
        case .normal:
            LookbookShareColorStyle.styleCircleInk.opacity(0.94)
        case .error:
            Color(red: 0.94, green: 0.22, blue: 0.18).opacity(0.94)
        case .success:
            Color(red: 0.12, green: 0.58, blue: 0.34).opacity(0.94)
        }
    }

    var runwaySignalIconName: String {
        switch self {
        case .normal:
            "info.circle.fill"
        case .error:
            "xmark.circle.fill"
        case .success:
            "checkmark.circle.fill"
        }
    }
}

struct RunwaySignalToastPayload: Identifiable, Equatable {
    let id = UUID()
    let runwaySignalMessage: String
    let runwaySignalKind: RunwaySignalToastKind
}

struct RunwaySignalLoadingPayload: Equatable {
    let runwaySignalShowsMask: Bool
}

@MainActor
final class RunwaySignalHUDCenter: ObservableObject {
    static let shared = RunwaySignalHUDCenter()

    @Published private(set) var runwaySignalToast: RunwaySignalToastPayload?
    @Published private(set) var runwaySignalLoading: RunwaySignalLoadingPayload?

    private var runwaySignalToastDismissWorkItem: DispatchWorkItem?

    private init() {}

    func runwaySignalShowToast(
        _ message: String,
        kind: RunwaySignalToastKind = .normal
    ) {
        runwaySignalToastDismissWorkItem?.cancel()

        withAnimation(.easeInOut(duration: 0.18)) {
            runwaySignalToast = RunwaySignalToastPayload(
                runwaySignalMessage: message,
                runwaySignalKind: kind
            )
        }

        let runwaySignalWorkItem = DispatchWorkItem { [weak self] in
            Task { @MainActor in
                self?.runwaySignalHideToast()
            }
        }
        runwaySignalToastDismissWorkItem = runwaySignalWorkItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: runwaySignalWorkItem)
    }

    func runwaySignalHideToast() {
        runwaySignalToastDismissWorkItem?.cancel()
        runwaySignalToastDismissWorkItem = nil

        withAnimation(.easeInOut(duration: 0.16)) {
            runwaySignalToast = nil
        }
    }

    func runwaySignalShowLoading(showsMask: Bool = true) {
        withAnimation(.easeInOut(duration: 0.16)) {
            runwaySignalLoading = RunwaySignalLoadingPayload(runwaySignalShowsMask: showsMask)
        }
    }

    func runwaySignalHideLoading() {
        withAnimation(.easeInOut(duration: 0.16)) {
            runwaySignalLoading = nil
        }
    }
}

struct RunwaySignalHUDOverlayModifier: ViewModifier {
    @ObservedObject private var runwaySignalCenter = RunwaySignalHUDCenter.shared

    func body(content: Content) -> some View {
        ZStack {
            content

            if let runwaySignalLoading = runwaySignalCenter.runwaySignalLoading {
                RunwaySignalLoadingLayer(runwaySignalLoading: runwaySignalLoading)
                    .zIndex(20)
            }

            if let runwaySignalToast = runwaySignalCenter.runwaySignalToast {
                RunwaySignalToastLayer(runwaySignalToast: runwaySignalToast)
                    .zIndex(30)
            }
        }
    }
}

extension View {
    func runwaySignalHUDOverlay() -> some View {
        modifier(RunwaySignalHUDOverlayModifier())
    }
}

private struct RunwaySignalToastLayer: View {
    let runwaySignalToast: RunwaySignalToastPayload

    var body: some View {
        ZStack {
            Color.clear
                .contentShape(Rectangle())
                .ignoresSafeArea()
                .onTapGesture {
                    RunwaySignalHUDCenter.shared.runwaySignalHideToast()
                }

            VStack {
                Spacer()

                HStack(spacing: 8) {
                    Image(systemName: runwaySignalToast.runwaySignalKind.runwaySignalIconName)
                        .font(.system(size: 15, weight: .semibold))

                    Text(runwaySignalToast.runwaySignalMessage)
                        .font(.system(size: 14, weight: .semibold))
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(runwaySignalToast.runwaySignalKind.runwaySignalBackground)
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                .shadow(color: Color.black.opacity(0.14), radius: 18, y: 8)
                .padding(.horizontal, 28)
                .padding(.bottom, 56)
            }
        }
        .transition(.opacity.combined(with: .move(edge: .bottom)))
    }
}

private struct RunwaySignalLoadingLayer: View {
    let runwaySignalLoading: RunwaySignalLoadingPayload

    var body: some View {
        ZStack {
            Group {
                if runwaySignalLoading.runwaySignalShowsMask {
                    Color.black.opacity(0.18)
                } else {
                    Color.clear
                }
            }
            .contentShape(Rectangle())
            .ignoresSafeArea()

            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                .scaleEffect(1.18)
                .padding(22)
                .background(LookbookShareColorStyle.styleCircleInk.opacity(0.86))
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                .shadow(color: Color.black.opacity(0.18), radius: 18, y: 8)
        }
        .transition(.opacity)
    }
}
