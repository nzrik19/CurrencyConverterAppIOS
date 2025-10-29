import Foundation

// Клас-обгортка для роботи з UserDefaults.
// Це робить код чистішим і дозволяє легко змінювати спосіб зберігання..
class UserSettings {
    
    static let shared = UserSettings()
    private let defaults = UserDefaults.standard
    private let baseCurrencyKey = "baseCurrency" // Ключ для збереження

    private init() {}
    
    // Зберігаємо обрану базову валюту.
    func saveBaseCurrency(_ currency: String) {
        defaults.set(currency, forKey: baseCurrencyKey)
    }
    
    // Завантажуємо збережену валюту. Якщо нічого не збережено, повертаємо UAH.
    func loadBaseCurrency() -> String {
        return defaults.string(forKey: baseCurrencyKey) ?? "UAH"
    }
}

