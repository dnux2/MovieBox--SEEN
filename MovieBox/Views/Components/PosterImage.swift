import SwiftUI

// Loads a poster with retries, and shows a film icon if it fails
struct PosterImage: View {
    let url: URL?

    @State private var image: UIImage?
    @State private var failed = false

    var body: some View {
        ZStack {
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else if url == nil || failed {
                // ما فيه رابط أو فشل التحميل
                Image(systemName: "film")
                    .foregroundStyle(.secondary)
            } else {
                ProgressView()
            }
        }
        // يشتغل كل ما تظهر الصورة، فلو فشلت قبل يعيد المحاولة
        .task(id: url) {
            await load()
        }
    }

    // Asks APIClient for the image data and turns it into a UIImage
    private func load() async {
        guard let url else { return }
        failed = false

        if let data = await ImageLoader.shared.loadImageData(from: url),
           let loaded = UIImage(data: data) {
            image = loaded
        } else if !Task.isCancelled {
            failed = true
        }
    }
}
