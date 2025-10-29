import Foundation

// Клас для обробки мережевих запитів.
// Використання Singleton патерну, щоб мати один екземпляр на весь додаток..
class NetworkManager {
    
    static let shared = NetworkManager()
    private init() {}
    
    private let baseURL = "https://v6.exchangerate-api.com/v6/"
    // Ваш API ключ, який ви надали
    private let apiKey = "9c9c6b691ab45ef6201410dc"

    // Використання async/await для сучасного асинхронного коду.
    func fetchRates(for baseCurrency: String) async throws -> APIResponse {
        
        // --- ВИПРАВЛЕННЯ: Перевірка на оригіaнальну заглушку "YOUR_API_KEY" ---
        // Ця перевірка тепер пройде успішно, оскільки ваш ключ не "YOUR_API_KEY".
        guard apiKey != "YOUR_API_KEY" else {
            throw NetworkError.apiKeyMissing
        }
        
        let urlString = "\(baseURL)\(apiKey)/latest/\(baseCurrency)"
        
        guard let url = URL(string: urlString) else {
            throw NetworkError.invalidURL
        }
        
        // Робимо запит і отримуємо дані та відповідь.
        let (data, response) = try await URLSession.shared.data(from: url)
        
        // Перевіряємо, чи відповідь є успішною (статус код 200).
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            // Якщо сюди приходить помилка, перевірте правильність ключа на сайті API
            throw NetworkError.serverError
        }
        
        // Декодуємо отримані дані в нашу модель APIResponse.
        do {
            let decoder = JSONDecoder()
            return try decoder.decode(APIResponse.self, from: data)
        } catch {
            throw NetworkError.decodingError(error)
        }
    }
}

// Перелік можливих помилок мережі для кращої обробки.
enum NetworkError: Error, LocalizedError {
    case apiKeyMissing
    case invalidURL
    case serverError
    case decodingError(Error)
    
    var errorDescription: String? {
        switch self {
        case .apiKeyMissing:
            return "Будь ласка, вставте ваш API ключ у файл NetworkManager.swift"
        case .invalidURL:
            return "Неправильна URL адреса."
        case .serverError:
            // Ця помилка може також виникати, якщо ваш API ключ недійсний або акаунт заблоковано.
            return "Помилка на сервері (або невірний API ключ)."
        case .decodingError(let error):
            return "Помилка декодування даних: \(error.localizedDescription)"
        }
    }
}

