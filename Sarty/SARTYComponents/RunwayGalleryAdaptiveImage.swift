import SwiftUI
import UIKit

struct RunwayGalleryAdaptiveImage<RunwayGalleryPlaceholder: View>: View {
    let runwayGallerySource: String
    var runwayGalleryContentMode: ContentMode
    let runwayGalleryPlaceholder: () -> RunwayGalleryPlaceholder

    init(
        _ runwayGallerySource: String,
        runwayGalleryContentMode: ContentMode = .fill,
        @ViewBuilder runwayGalleryPlaceholder: @escaping () -> RunwayGalleryPlaceholder
    ) {
        self.runwayGallerySource = runwayGallerySource
        self.runwayGalleryContentMode = runwayGalleryContentMode
        self.runwayGalleryPlaceholder = runwayGalleryPlaceholder
    }

    var body: some View {
        Group {
            switch runwayGallerySourceKind {
            case .network(let runwayGalleryURL):
                AsyncImage(url: runwayGalleryURL) { runwayGalleryPhase in
                    switch runwayGalleryPhase {
                    case .success(let runwayGalleryImage):
                        runwayGalleryStyledImage(runwayGalleryImage)
                    default:
                        runwayGalleryPlaceholder()
                    }
                }

            case .file(let runwayGalleryPath):
                if let runwayGalleryImage = UIImage(contentsOfFile: runwayGalleryPath) {
                    runwayGalleryStyledImage(Image(uiImage: runwayGalleryImage))
                } else {
                    runwayGalleryPlaceholder()
                }

            case .asset(let runwayGalleryName):
                runwayGalleryStyledImage(Image(runwayGalleryName))

            case .empty:
                runwayGalleryPlaceholder()
            }
        }
    }

    private var runwayGallerySourceKind: RunwayGalleryImageSourceKind {
        let runwayGalleryTrimmedSource = runwayGallerySource.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !runwayGalleryTrimmedSource.isEmpty else { return .empty }

        if let runwayGalleryURL = URL(string: runwayGalleryTrimmedSource),
           let runwayGalleryScheme = runwayGalleryURL.scheme?.lowercased() {
            if runwayGalleryScheme == "http" || runwayGalleryScheme == "https" {
                return .network(runwayGalleryURL)
            }

            if runwayGalleryScheme == "file" {
                return .file(runwayGalleryURL.path)
            }
        }

        let runwayGalleryExpandedPath = (runwayGalleryTrimmedSource as NSString).expandingTildeInPath
        if runwayGalleryExpandedPath.hasPrefix("/") {
            return .file(runwayGalleryExpandedPath)
        }

        return .asset(runwayGalleryTrimmedSource)
    }

    private func runwayGalleryStyledImage(_ runwayGalleryImage: Image) -> some View {
        runwayGalleryImage
            .resizable()
            .aspectRatio(contentMode: runwayGalleryContentMode)
    }
}

extension RunwayGalleryAdaptiveImage where RunwayGalleryPlaceholder == Color {
    init(
        _ runwayGallerySource: String,
        runwayGalleryContentMode: ContentMode = .fill
    ) {
        self.init(
            runwayGallerySource,
            runwayGalleryContentMode: runwayGalleryContentMode,
            runwayGalleryPlaceholder: {
                LookbookShareColorStyle.lookbookSoftCanvas
            }
        )
    }
}

private enum RunwayGalleryImageSourceKind {
    case network(URL)
    case file(String)
    case asset(String)
    case empty
}
