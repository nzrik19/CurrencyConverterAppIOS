import SwiftUI

struct RatesView: View {
    // Отримуємо доступ до ViewModel з "середовища".
    @EnvironmentObject var viewModel: ExchangeRateViewModel
    
    // --- ПОШУК: Стейт для тексту пошуку ---
    @State private var searchText = ""
    // --- ПОШУK: Стейт для відображення/ховання поля пошуку ---
    @State private var isSearching = false

    // --- ПОШУК: Фільтруємо список валют на основі searchText ---
    private var filteredRates: [String] {
        if searchText.isEmpty {
            // Якщо пошук порожній, повертаємо всі ключі, відсортовані за алфавітом
            return viewModel.rates.keys.sorted()
        } else {
            // Інакше, фільтруємо ключі
            return viewModel.rates.keys.filter { currencyCode in
                // Пошук без врахування регістру
                currencyCode.lowercased().contains(searchText.lowercased())
            }.sorted() // і сортуємо результат
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                
                // --- ПОШУК: Поле пошуку, яке з'являється/зникає ---
                if isSearching {
                    HStack {
                        TextField("Пошук за кодом (USD, UAH)", text: $searchText)
                            .textFieldStyle(.roundedBorder)
                            .padding(.horizontal)
                        
                        Button("Скасувати") {
                            withAnimation {
                                isSearching = false
                            }
                            searchText = "" // Очищуємо пошук
                        }
                        .padding(.trailing)
                    }
                    .padding(.top, 8)
                    // Анімація появи/зникнення
                    .transition(.move(edge: .top).combined(with: .opacity))
                }
                
                // --- Кінець блоку пошуку ---
                
                if viewModel.isLoading && viewModel.rates.isEmpty {
                    ProgressView("Завантаження курсів...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
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
                else {
                    List {
                        // --- ПОШУК: Використовуємо 'filteredRates' замість 'viewModel.rates.keys.sorted()' ---
                        ForEach(filteredRates, id: \.self) { currency in
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
                        viewModel.fetchRates()
                    }
                    
                    if let errorMessage = viewModel.errorMessage, !viewModel.rates.isEmpty {
                        Text("Помилка оновлення: \(errorMessage)")
                            .font(.caption)
                            .foregroundColor(.red)
                            .padding(.bottom)
                            .onTapGesture { // Дозволяємо "зникати" помилці
                                viewModel.errorMessage = nil
                            }
                    } else {
                        Text(viewModel.lastUpdated)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.bottom)
                    }
                }
            }
            // Анімація для Vstack, щоб список плавно "з'їжджав"
            .animation(.default, value: isSearching)
            .navigationTitle("Курси Валют")
            .toolbar {
                // --- ПОШУК: Нова кнопка "лупи" ---
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        withAnimation {
                            isSearching.toggle() // Перемикаємо стан
                        }
                        searchText = "" // Завжди очищуємо при натисканні
                    } label: {
                        Image(systemName: "magnifyingglass")
                    }
                }
                
                // Існуюча кнопка вибору валюти
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
        .navigationViewStyle(.stack)
    }
}


struct RatesView_Previews: PreviewProvider {
    static var previews: some View {
        RatesView()
            .environmentObject(ExchangeRateViewModel())
    }
}

