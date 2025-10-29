import Foundation

// Ця структура відповідає JSON-відповіді від ExchangeRate-API..
// Вона використовує протокол Codable для легкого декодування.
struct APIResponse: Codable {
    let result: String
    let time_last_update_utc: String // Дата/час у форматі UTC
    let base_code: String // Базова валюта, яку ми запитували
    let conversion_rates: [String: Double] // Словник курсів
}

