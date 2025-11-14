import Foundation
import Combine

@MainActor
class ExchangeRateViewModel: ObservableObject {

@Published var isLoading = false
@Published var errorMessage: String?
@Published var lastUpdated: String = "Оновлення..."

@Published var baseCurrency: String = "UAH" {
    didSet {
        // --- ВИПРАВЛЕННЯ 1: Прибрано 'code:' ---
        UserSettings.shared.saveBaseCurrency(baseCurrency)
        // ------------------------------------
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
    
    guard let amount = Double(normalizedAmount) else {
        return 0.0
    }
    
    guard let fromRate = rates[fromCurrency],
          let toRate = rates[toCurrency]
    else {
        return 0.0
    }
    
    guard fromRate > 0 else {
        return 0.0
    }
    
    return amount * (toRate / fromRate)
}

init() {
    self.baseCurrency = UserSettings.shared.loadBaseCurrency()
    
    Task {
        async let fetchRatesTask: () = fetchRates()
        async let fetchNamesTask: () = fetchCurrencyNames()
        
        _ = await (fetchRatesTask, fetchNamesTask)
    }
}

func fetchRates() {
    if rates.isEmpty {
        isLoading = true
    }
    errorMessage = nil
    
    Task {
        do {
            let response = try await NetworkManager.shared.fetchRates(for: baseCurrency)
            
            // --- ВИПРАВЛЕННЯ 2: (тут потрібен APIResponse_Fix.txt) ---
            self.rates = response.conversionRates
            // ----------------------------------------------------
            
            self.lastUpdated = "Останнє оновлення: \(response.timeLastUpdateUTC)"
            self.errorMessage = nil
            
            if !self.rates.keys.contains(self.fromCurrency) {
                self.fromCurrency = "USD"
            }
            if !self.rates.keys.contains(self.toCurrency) {
                self.toCurrency = self.baseCurrency
            }
            
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
                    let code = codePair[0]
                    let name = codePair[1]
                    dict[code] = name
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
