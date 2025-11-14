import Foundation

// Допоміжний клас для роботи з валютами.
// Ми видалили звідси "довідник", оскільки він тепер приходить з API.
class CurrencyUtils {

// Функція для отримання Емодзі-прапору за кодом валюти
static func flag(for currencyCode: String) -> String {
    // Базове зміщення для Емодзі-літер
    let base: UInt32 = 127397
    
    // Переконуємося, що код має 2 літери (напр., "UA" з "UAH")
    let countryCode = String(currencyCode.prefix(2))
    
    // Перевіряємо, чи код складається з 2-х латинських літер
    guard countryCode.count == 2 &&
          countryCode.unicodeScalars.allSatisfy({ $0.value >= 65 && $0.value <= 90 }) else {
        return "🏳️" // Повертаємо білий прапор, якщо код невірний
    }

    // Перетворюємо літери коду (напр., 'U' та 'A') в Емодзі
    var flagString = ""
    for scalar in countryCode.unicodeScalars {
        if let regionalScalar = UnicodeScalar(base + scalar.value) {
            flagString.unicodeScalars.append(regionalScalar)
        }
    }
    return flagString
}


}
