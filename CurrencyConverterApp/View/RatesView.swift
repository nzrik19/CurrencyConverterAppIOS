import SwiftUI

struct RatesView: View {
    // Отримуємо доступ до ViewModel з "середовища".
    @EnvironmentObject var viewModel: ExchangeRateViewModel

    var body: some View {
        NavigationView {
            VStack {
                // Показуємо індикатор завантаження.
                if viewModel.isLoading && viewModel.rates.isEmpty { // Показуємо тільки при першому завантаженні
                    ProgressView("Завантаження курсів...")
                }
                // Показуємо повідомлення про помилку.
                else if let errorMessage = viewModel.errorMessage {
                    VStack {
                        Text("⚠️")
                            .font(.largeTitle)
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .padding()
                        Button("Спробувати знову") {
                            viewModel.fetchRates()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
                // Показуємо список курсів.
                else {
                    List {
                                            // Сортуємо валюти за алфавітом для зручності.
                                            ForEach(viewModel.rates.keys.sorted(), id: \.self) { currency in
                                                if let rate = viewModel.rates[currency] {
                                                    CurrencyRow(
                                                        currencyCode: currency,
                                                        rate: rate,
                                                        baseCurrency: viewModel.baseCurrency
                                                    )
                                                }
                                            }
                                        }
                    // --- ДОДАНО PULL-TO-REFRESH ---
                    // Додаємо можливість оновлення списку потягуванням
                    .refreshable {
                        viewModel.fetchRates()
                    }
                }
                
                // Відображення дати останнього оновлення.
                Text(viewModel.lastUpdated)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.bottom)
            }
            .navigationTitle("Курси Валют")
            .toolbar {
                // Кнопка вибору базової валюти
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Picker("Базова валюта", selection: $viewModel.baseCurrency) {
                            ForEach(viewModel.availableCurrencies, id: \.self) { currency in
                                Text("\(CurrencyUtils.flag(for: currency)) \(currency)")
                                    .tag(currency)
                            }
                        }
                        .pickerStyle(.inline)
                        
                    } label: {
                        Text("\(CurrencyUtils.flag(for: viewModel.baseCurrency)) \(viewModel.baseCurrency)")
                            .font(.subheadline)
                            .foregroundColor(.accentColor)
                    }
                }
            }
        }
    }
}


struct RatesView_Previews: PreviewProvider {
    static var previews: some View {
        RatesView()
            .environmentObject(ExchangeRateViewModel())
    }
}

