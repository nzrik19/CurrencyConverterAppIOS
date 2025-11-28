import Foundation
import Combine

@MainActor
class ExchangeRateViewModel: ObservableObject {
    
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var lastUpdated: String = "Оновлення..."

    // --- Улюблені Валюти ---
    @Published var favoriteCurrencies: Set<String> = [] {
        didSet {
            // Зберігаємо при кожній зміні (перетворюємо Set в Array)
            UserSettings.shared.saveFavorites(Array(favoriteCurrencies))
        }
    }
    
    // Режим "Тільки улюблені" (Вмикається кнопкою зліва зверху)
    @Published var isFavoritesOnlyMode: Bool = false

    @Published var baseCurrency: String = "UAH" {
        didSet {
            UserSettings.shared.saveBaseCurrency(baseCurrency)
            fetchRates()
        }
    }
    @Published var rates: [String: Double] = [:]
    @Published var currencyNames: [String: String] = [:]

    @Published var amountToConvert: String = "1"
    @Published var fromCurrency: String = "USD"
    @Published var toCurrency: String = "UAH"
    
    // --- Обчислювана властивість: Доступні валюти ---
    // Це впливає на ВСІ пікери (в конвертері і на головному)
    var availableCurrencies: [String] {
        let allCurrencies = rates.keys.sorted()
        
        if isFavoritesOnlyMode {
            // Якщо режим увімкнено, повертаємо тільки улюблені, які є в списку курсів
            return allCurrencies.filter { favoriteCurrencies.contains($0) }
        } else {
            // Інакше повертаємо всі
            return allCurrencies
        }
    }

    var convertedAmount: Double {
        let normalizedAmount = amountToConvert.replacingOccurrences(of: ",", with: ".")
        guard let amount = Double(normalizedAmount) else { return 0.0 }
        
        guard let fromRate = rates[fromCurrency],
              let toRate = rates[toCurrency]
        else { return 0.0 }
        
        guard fromRate > 0 else { return 0.0 }
        
        return amount * (toRate / fromRate)
    }

    // --- Логіка дати ---
    private func formatUpdateDate(_ rawDate: String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "E, d MMM yyyy HH:mm:ss Z"
        inputFormatter.locale = Locale(identifier: "en_US_POSIX")

        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "d MMMM yyyy, HH:mm"
        outputFormatter.locale = Locale(identifier: "uk_UA")

        if let date = inputFormatter.date(from: rawDate) {
            return "Останнє оновлення: \(outputFormatter.string(from: date))"
        }
        return "Останнє оновлення: \(rawDate)"
    }

    init() {
        self.baseCurrency = UserSettings.shared.loadBaseCurrency()
        // Завантажуємо улюблені зі сховища
        self.favoriteCurrencies = Set(UserSettings.shared.loadFavorites())
        
        Task {
            async let fetchRatesTask: () = fetchRates()
            async let fetchNamesTask: () = fetchCurrencyNames()
            _ = await (fetchRatesTask, fetchNamesTask)
        }
    }
    
    // Функція для перемикання улюбленого статусу
    func toggleFavorite(_ currency: String) {
        if favoriteCurrencies.contains(currency) {
            favoriteCurrencies.remove(currency)
        } else {
            favoriteCurrencies.insert(currency)
        }
    }
    
    // Перевірка, чи є валюта улюбленою
    func isFavorite(_ currency: String) -> Bool {
        return favoriteCurrencies.contains(currency)
    }

    func fetchRates() {
        if rates.isEmpty { isLoading = true }
        errorMessage = nil
        
        Task {
            do {
                let response = try await NetworkManager.shared.fetchRates(for: baseCurrency)
                self.rates = response.conversionRates
                self.lastUpdated = formatUpdateDate(response.timeLastUpdateUTC)
                self.errorMessage = nil
                
                if !self.rates.keys.contains(self.fromCurrency) { self.fromCurrency = "USD" }
                if !self.rates.keys.contains(self.toCurrency) { self.toCurrency = self.baseCurrency }
                
            } catch {
                self.errorMessage = error.localizedDescription
            }
            self.isLoading = false
        }
    }
    
    func fetchCurrencyNames() {
        Task {
            do {
                let response = try await NetworkManager.shared.fetchCurrencyNames()
                let namesDict = response.supportedCodes.reduce(into: [String: String]()) { dict, codePair in
                    if codePair.count == 2 {
                        dict[codePair[0]] = codePair[1]
                    }
                }
                self.currencyNames = namesDict
            } catch {
                print("Failed to fetch currency names: \(error.localizedDescription)")
            }
        }
    }

    func swapCurrencies() {
        let temp = fromCurrency
        fromCurrency = toCurrency
        toCurrency = temp
    }
}
