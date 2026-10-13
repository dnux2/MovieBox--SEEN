import Foundation

// هذا الكلاس الوحيد اللي يكلم URLSession في التطبيق كله
// كل الشاشات تمر من هنا، ما أكرر الكود في كل مكان

// why Class لان نوعه refrence type كل النسخ تاشر على كائن  واحد
// الstruct نوعه value type فكل نسخه تسويلها نسخه
// why final لانه نسخه نهائيه مابي اسوي لها وراثه

final class APIClient {
    //why static لو ناديتها مايحتاج اسوي اوبجكت
    static let shared = APIClient()
    private let baseURL = "https://api.themoviedb.org/3"
    private let session: URLSession
    private let decoder: JSONDecoder
// why not private لسهوله الاختبار
    init(session: URLSession = .shared) {
        self.session = session

        let decoder = JSONDecoder()
        // يحوّل poster_path اللي جاي من السيرفر إلى posterPath عندي
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        self.decoder = decoder
    }

    // دالة وحدة تجيب أي نوع بيانات، الـ T معناها أي Model أبيه
    func get<T: Decodable>(
        _ path: String,
        queryItems: [URLQueryItem] = []
    ) async throws -> T {
        //الخطوه الاولى ابني الرابط
        guard var components = URLComponents(string: baseURL + path) else {
            throw APIError.invalidURL
        }
        if !queryItems.isEmpty {
            components.queryItems = queryItems
        }
        guard let url = components.url else {
            throw APIError.invalidURL
        }

        // الخطوه الثانيه أجهّز الطلب وأحط التوكن في الهيدر
        var request = URLRequest(url: url)
        request.setValue("Bearer \(Config.tmdbToken)", forHTTPHeaderField: "Authorization")
        //accept tell ser we want JSON
        request.setValue("application/json", forHTTPHeaderField: "accept")

        // أرسل الطلب وأنتظر الرد
        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(for: request)
        } catch let error as URLError where error.code == .notConnectedToInternet
                    || error.code == .networkConnectionLost {
            // ما فيه نت، أرجع خطأ خاص عشان أعرض له رسالة مفهومة
            throw APIError.noConnection
        }

        // أتأكد إن الرد HTTP، وإن الكود بين 200 و299 يعني نجح
        guard let http = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        guard (200...299).contains(http.statusCode) else {
            throw APIError.serverError(http.statusCode)
        }

        // آخر خطوة أحوّل الـ JSON إلى Model
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw APIError.decodingFailed
        }
    }

    // تحميل بيانات الصورة (البوستر)، ولو فشل يعيد المحاولة 3 مرات
    func loadImageData(from url: URL) async -> Data? {
        // لو الصورة نزلت قبل، نرجعها على طول بدون طلب جديد
        if let cached = Self.imageCache.object(forKey: url as NSURL) {
            return cached as Data
        }

        for _ in 1...3 {
            if Task.isCancelled { return nil }
            do {
                let (data, _) = try await session.data(from: url)
                Self.imageCache.setObject(data as NSData, forKey: url as NSURL)
                return data
            } catch {
                // مؤقت للتشخيص، أشيله بعدين
                //print("Image failed:", url.lastPathComponent, error)
            }
            // ننتظر شوي قبل المحاولة الجاية
            try? await Task.sleep(for: .milliseconds(500))
        }
        return nil
    }
}
