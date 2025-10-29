import SwiftUI

struct RatesView: View {
    // Отримуємо доступ до ViewModel з "середовища".
    @EnvironmentObject var viewModel: ExchangeRateViewModel

    var body: some View {
        NavigationView {
            VStack {
                // --- ОНОВЛЕНА ЛОГІКА ДЛЯ ПЛАВНОСТІ ---

                // 1. Показуємо індикатор ТІЛЬКИ при першому запуску (коли список порожній)
                if viewModel.isLoading && viewModel.rates.isEmpty {
                    ProgressView("Завантаження курсів...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                
                // 2. Показуємо помилку ТІЛЬКИ при першому запуску (якщо список порожній)
                else if let errorMessage = viewModel.errorMessage, viewModel.rates.isEmpty {
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
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                
                // 3. В УСІХ ІНШИХ ВИПАДКАХ (включаючи refresh, коли дані вже є) - показуємо список
                else {
                    List {
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
                    .refreshable {
                        // .refreshable має свій індикатор,
                        // тому ми просто викликаємо fetchRates()
                        viewModel.fetchRates()
                    }
                    
                    // Якщо під час оновлення (коли дані вже є) виникла помилка
                    if let errorMessage = viewModel.errorMessage, !viewModel.rates.isEmpty {
                        Text("Помилка оновлення") // Можна показати коротке пов-ня
                            .font(.caption)
                            .foregroundColor(.red)
                            .padding(.bottom)
                    } else {
                        // Відображення дати останнього оновлення.
                        Text(viewModel.lastUpdated)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.bottom)
                    }
                }
            }
            // Додаємо анімацію на всю VStack.
            // Це зробить плавний перехід від ProgressView до List при першому запуску.
            .animation(.default, value: viewModel.isLoading)
            .navigationTitle("Курси Валют")
            .toolbar {
                // Кнопка вибору базової валюти (компактна, через Menu)
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
        // Виправлення для iPad
        .navigationViewStyle(.stack)
    }
}


struct RatesView_Previews: PreviewProvider {
    static var previews: some View {
        RatesView()
            .environmentObject(ExchangeRateViewModel())
    }
}

