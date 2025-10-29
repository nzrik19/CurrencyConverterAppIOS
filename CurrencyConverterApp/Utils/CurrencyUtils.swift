import Foundation

// Допоміжна структура для роботи з валютами
struct CurrencyUtils {
    
    /**
     Перетворює код валюти (ISO 4217) на емодзі прапора.
     Наприклад, "UAH" -> "UA" -> 🇺🇦
     */
    static func flag(for currencyCode: String) -> String {
        // Спеціальний випадок для Євро, оскільки "EU" не є кодом країни
        if currencyCode == "EUR" {
            return "🇪🇺"
        }
        
        // Беремо перші дві літери коду валюти (зазвичай це код країни ISO 3166-1)
        let countryCode = String(currencyCode.prefix(2))
        
        // Конвертуємо код країни (напр., "UA") в емодзі прапора (напр., "🇺🇦")
        let base: UInt32 = 127397 // U+1F1E6 (Regional Indicator A) - U+0041 (Latin A)
        
        var flag = ""
        for scalar in countryCode.uppercased().unicodeScalars {
            // Переконуємось, що це латинська літера (A-Z)
            if scalar.value >= 0x0041 && scalar.value <= 0x005A {
                if let regionalScalar = UnicodeScalar(base + scalar.value) {
                    flag.append(String(regionalScalar))
                }
            }
        }
        
        // Повертаємо прапор, або 💰 як запасний варіант, якщо щось пішло не так
        return flag.unicodeScalars.count == 2 ? flag : "💰"
    }
}

