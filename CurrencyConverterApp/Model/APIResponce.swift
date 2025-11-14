import Foundation

// Модель для /v6/YOUR-KEY/latest/USD
struct APIResponse: Codable {
let result: String
let timeLastUpdateUTC: String
let baseCode: String

// --- ВИПРАВЛЕННЯ: Ця властивість була відсутня ---
let conversionRates: [String: Double]
// ----------------------------------------------

// Кастомні ключі для декодування
enum CodingKeys: String, CodingKey {
    case result
    case timeLastUpdateUTC = "time_last_update_utc"
    case baseCode = "base_code"
    case conversionRates = "conversion_rates" // Додаємо ключ
}


}
