import Foundation

class NetworkManager {

static let shared = NetworkManager()
private init() {}

private let baseURL = "https://v6.exchangerate-api.com/v6/"
private let apiKey = "9c9c6b691ab45ef6201410dc"

// 1. Завантаження курсів
func fetchRates(for baseCurrency: String) async throws -> APIResponse {
    guard apiKey != "YOUR_API_KEY" else {
        throw NetworkError.apiKeyMissing
    }
    
    let urlString = "\(baseURL)\(apiKey)/latest/\(baseCurrency)"
    
    guard let url = URL(string: urlString) else {
        throw NetworkError.invalidURL
    }
    
    let (data, response) = try await URLSession.shared.data(from: url)
    
    guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
        // Спробуємо декодувати помилку, якщо вона є
        if let errorResponse = try? JSONDecoder().decode(APIErrorResponse.self, from: data) {
            throw NetworkError.apiError(errorResponse.errorType)
        }
        throw NetworkError.serverError
    }
    
    do {
        let decoder = JSONDecoder()
        return try decoder.decode(APIResponse.self, from: data)
    } catch {
        throw NetworkError.decodingError(error)
    }
}

// 2. НОВА ФУНКЦІЯ: Завантаження назв валют
func fetchCurrencyNames() async throws -> APICodesResponse {
    guard apiKey != "YOUR_API_KEY" else {
        throw NetworkError.apiKeyMissing
    }
    
    let urlString = "\(baseURL)\(apiKey)/codes"
    
    guard let url = URL(string: urlString) else {
        throw NetworkError.invalidURL
    }
    
    let (data, response) = try await URLSession.shared.data(from: url)
    
    guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
        if let errorResponse = try? JSONDecoder().decode(APIErrorResponse.self, from: data) {
            throw NetworkError.apiError(errorResponse.errorType)
        }
        throw NetworkError.serverError
    }
    
    do {
        let decoder = JSONDecoder()
        return try decoder.decode(APICodesResponse.self, from: data)
    } catch {
        throw NetworkError.decodingError(error)
    }
}


}

// Покращена обробка помилок
struct APIErrorResponse: Codable {
let result: String
let errorType: String

enum CodingKeys: String, CodingKey {
    case result
    case errorType = "error-type"
}


}

enum NetworkError: Error, LocalizedError {
case apiKeyMissing
case invalidURL
case serverError
case decodingError(Error)
case apiError(String) // Специфічна помилка від API

var errorDescription: String? {
    switch self {
    case .apiKeyMissing:
        return "Будь ласка, вставте ваш API ключ у файл NetworkManager.swift"
    case .invalidURL:
        return "Неправильна URL адреса."
    case .serverError:
        return "Помилка на сервері."
    case .decodingError(let error):
        return "Помилка декодування даних: \(error.localizedDescription)"
    case .apiError(let type):
        // Повертаємо зрозуміліший текст помилки
        switch type {
        case "invalid-key":
            return "Невірний API ключ."
        case "inactive-account":
            return "Акаунт неактивний."
        case "unsupported-code":
            return "Код валюти не підтримується."
        default:
            return "Помилка API: \(type)"
        }
    }
}


}
