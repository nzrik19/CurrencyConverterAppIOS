import Foundation

class UserSettings {
    
    static let shared = UserSettings()
    private let defaults = UserDefaults.standard
    
    private let baseCurrencyKey = "baseCurrency"
    private let favoriteCurrenciesKey = "favoriteCurrencies"
    
    private init() {}
    
    // --- Базова валюта ---
    func saveBaseCurrency(_ code: String) {
        defaults.set(code, forKey: baseCurrencyKey)
    }
    
    func loadBaseCurrency() -> String {
        return defaults.string(forKey: baseCurrencyKey) ?? "UAH"
    }
    
    // --- Улюблені валюти ---
    func saveFavorites(_ codes: [String]) {
        defaults.set(codes, forKey: favoriteCurrenciesKey)
    }
    
    func loadFavorites() -> [String] {
        // ВИПРАВЛЕННЯ: Повертаємо порожній список за замовчуванням
        return defaults.stringArray(forKey: favoriteCurrenciesKey) ?? []
    }
}
