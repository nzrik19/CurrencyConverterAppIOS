import Foundation
import Combine

// ViewModel - це серце нашої логіки в архітектурі MVVM.
@MainActor
class ExchangeRateViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var rates: [String: Double] = [:]
    @Published var lastUpdated: String = "Оновлення..."
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    // Властивості для конвертера
    @Published var amountToConvert: String = "100"
    @Published var fromCurrency: String = "USD"
    @Published var toCurrency: String = "UAH"
    
    // Властивість для базової валюти, що зберігається локально..
    @Published var baseCurrency: String {
        didSet {
            // Коли базова валюта змінюється, зберігаємо її та оновлюємо курси.
            UserSettings.shared.saveBaseCurrency(baseCurrency)
            fetchRates()
        }
    }
    
    // Масив доступних валют (для Picker'ів)
    let availableCurrencies = ["UAH", "USD", "EUR", "PLN", "GBP", "CHF", "JPY", "CAD", "AUD", "CNY"]
    
    // MARK: - Computed Properties
    
    // Обчислювана властивість для результату конвертації.
    var convertedAmount: Double {
        // --- ВИПРАВЛЕННЯ: Обробка коми ---
        // Замінюємо коми на крапки, щоб коректно конвертувати в Double
        // незалежно від регіональних налаштувань клавіатури.
        let amountString = amountToConvert.replacingOccurrences(of: ",", with: ".")
        
        guard let amount = Double(amountString), // Використовуємо очищений рядок
              let fromRate = rates[fromCurrency], // Курс відносно базової валюти
              let toRate = rates[toCurrency],
              fromRate > 0 // Запобігаємо діленню на нуль
        else {
            return 0.0
        }
        
        // Формула конвертації через базову валюту (наприклад, UAH)
        // (Сума / Курс_From) * Курс_To
        let amountInBase = amount / fromRate
        return amountInBase * toRate
    }
    
    // MARK: - Initializer
    
    init() {
        // При створенні ViewModel завантажуємо базову валюту та курси.
        self.baseCurrency = UserSettings.shared.loadBaseCurrency()
        fetchRates()
    }
    
    // MARK: - Public Methods
    
    // Функція для завантаження даних з мережі.
    func fetchRates() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let response = try await NetworkManager.shared.fetchRates(for: baseCurrency)
                self.rates = response.conversion_rates
                self.lastUpdated = formatUpdateTime(response.time_last_update_utc)
            } catch {
                self.errorMessage = "Помилка завантаження даних: \(error.localizedDescription)"
            }
            self.isLoading = false
        }
    }
    
    // Функція для обміну валют місцями в конвертері.
    func swapCurrencies() {
        let temp = fromCurrency
        fromCurrency = toCurrency
        toCurrency = temp
    }
    
    // MARK: - Private Methods
    
    // Форматування дати останнього оновлення.
    private func formatUpdateTime(_ dateString: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss Z"
        if let date = dateFormatter.date(from: dateString) {
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .short
            return "Останнє оновлення: \(dateFormatter.string(from: date))"
        }
        return "Не вдалося отримати час"
    }
}

