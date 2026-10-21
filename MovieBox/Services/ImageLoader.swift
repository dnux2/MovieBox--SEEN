import Foundation

// Loads poster images: memory first, then disk, then the network
final class ImageLoader {
    static let shared = ImageLoader()

    private let session: URLSession
    // Fast cache, lost when the app is closed
    private let memoryCache = NSCache<NSURL, NSData>()
    // Folder on the disk where the images are saved
    private let folder: URL

    init(session: URLSession = .shared) {
        self.session = session

        let caches = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        folder = caches.appendingPathComponent("Posters", isDirectory: true)
        try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
    }

    func loadImageData(from url: URL) async -> Data? {
        // 1) الذاكرة: الأسرع
        if let cached = memoryCache.object(forKey: url as NSURL) {
            return cached as Data
        }

        // 2) القرص: تبقى بعد قفل التطبيق
        let file = fileURL(for: url)
        if let data = try? Data(contentsOf: file) {
            memoryCache.setObject(data as NSData, forKey: url as NSURL)
            return data
        }

        // 3) الشبكة: 3 محاولات
        for _ in 1...3 {
            if Task.isCancelled { return nil }
            do {
                let (data, response) = try await session.data(from: url)
                // نحفظ بس لو الرد ناجح، عشان ما نحفظ صفحة خطأ على أنها صورة
                if let http = response as? HTTPURLResponse, http.statusCode == 200 {
                    memoryCache.setObject(data as NSData, forKey: url as NSURL)
                    try? data.write(to: file)
                    return data
                }
            } catch {
                // نعيد المحاولة
            }
            try? await Task.sleep(for: .milliseconds(500))
        }
        return nil
    }

    // Turns the image link into a file name inside our folder
    private func fileURL(for url: URL) -> URL {
        let name = url.path.replacingOccurrences(of: "/", with: "_")
        return folder.appendingPathComponent(name)
    }
}
