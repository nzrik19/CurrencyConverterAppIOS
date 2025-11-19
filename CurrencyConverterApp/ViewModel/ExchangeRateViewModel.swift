import Foundation
import Combine

@MainActor
class ExchangeRateViewModel: ObservableObject {
    
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var lastUpdated: String = "Оновлення..."

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
    
    var availableCurrencies: [String] {
        rates.keys.sorted()
    }

    var convertedAmount: Double {
        let normalizedAmount = amountToConvert.replacingOccurrences(of: ",", with: ".")
        guard let amount = Double(normalizedAmount) else { return 0.0 }
        guard let fromRate = rates[fromCurrency], let toRate = rates[toCurrency] else { return 0.0 }
        guard fromRate > 0 else { return 0.0 }
        return amount * (toRate / fromRate)
    }

    // --- ЛОГІКА ДАТИ ---
    private func formatUpdateDate(_ rawDate: String) -> String {
        // Форматер для читання дати з API (формат RFC 1123: "Fri, 14 Nov 2025 00:00:01 +0000")
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "E, d MMM yyyy HH:mm:ss Z"
        inputFormatter.locale = Locale(identifier: "en_US_POSIX") // Важливо для англійських назв (Fri, Nov)

        // Форматер для виводу українською
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "d MMMM yyyy, HH:mm" // Напр: 14 листопада 2025, 14:00
        outputFormatter.locale = Locale(identifier: "uk_UA")

        if let date = inputFormatter.date(from: rawDate) {
            return "Останнє оновлення: \(outputFormatter.string(from: date))"
        }
        
        // Якщо формат не підійшов, повертаємо як є
        return "Останнє оновлення: \(rawDate)"
    }
    // ------------------

    init() {
        self.baseCurrency = UserSettings.shared.loadBaseCurrency()
        Task {
            async let fetchRatesTask: () = fetchRates()
            async let fetchNamesTask: () = fetchCurrencyNames()
            _ = await (fetchRatesTask, fetchNamesTask)
        }
    }

    func fetchRates() {
        if rates.isEmpty { isLoading = true }
        errorMessage = nil
        
        Task {
            do {
                let response = try await NetworkManager.shared.fetchRates(for: baseCurrency)
                
                self.rates = response.conversionRates
                // ВИКОРИСТОВУЄМО ФОРМАТУВАННЯ ТУТ:
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
