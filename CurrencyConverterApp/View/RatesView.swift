import SwiftUI

struct RatesView: View {
    @EnvironmentObject var viewModel: ExchangeRateViewModel
    @State private var searchText = ""

    private var filteredRates: [String] {
        let allSortedKeys = viewModel.rates.keys.sorted()
        if searchText.isEmpty { return allSortedKeys }
        
        let lowercasedQuery = searchText.lowercased()
        return allSortedKeys.filter { currencyCode in
            let codeMatch = currencyCode.lowercased().contains(lowercasedQuery)
            let nameMatch = (viewModel.currencyNames[currencyCode] ?? "").lowercased().contains(lowercasedQuery)
            return codeMatch || nameMatch
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) { // Головний контейнер
                
                // --- Список Валют (Займає весь вільний простір) ---
                List {
                    // --- Секція Пошуку ---
                    Section {
                        HStack(spacing: 12) {
                            HStack {
                                Image(systemName: "magnifyingglass")
                                    .foregroundColor(.gray)
                                
                                TextField("Пошук", text: $searchText)
                                    .textFieldStyle(.plain)
                                
                                if !searchText.isEmpty {
                                    Button(action: { searchText = "" }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(.gray)
                                    }
                                }
                            }
                            .padding(.vertical, 10)
                            .padding(.horizontal, 12)
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                        }
                    }
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets(top: 10, leading: 16, bottom: 10, trailing: 16))

                    // --- Секція Завантаження/Помилок ---
                    if viewModel.isLoading && viewModel.rates.isEmpty {
                        HStack {
                            Spacer()
                            ProgressView("Завантаження...")
                            Spacer()
                        }
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                    }
                    else if let errorMessage = viewModel.errorMessage, viewModel.rates.isEmpty {
                        VStack {
                            Text("⚠️").font(.largeTitle)
                            Text(errorMessage).foregroundColor(.red)
                            Button("Спробувати знову") { viewModel.fetchRates() }
                                .buttonStyle(.bordered)
                        }
                        .frame(maxWidth: .infinity)
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                    }
                    // --- Основний Список Валют ---
                    else {
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
                }
                .listStyle(.plain)
                .refreshable {
                    viewModel.fetchRates()
                }
                
                // --- ВИПРАВЛЕННЯ: Дата оновлення закріплена ЗНИЗУ ---
                // Вона знаходиться ПІД списком, тому її видно завжди
                if !viewModel.rates.isEmpty {
                    VStack {
                        Divider() // Тонка лінія відділення
                        Text(viewModel.lastUpdated)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.top, 8)
                            .padding(.bottom, 8)
                    }
                    .background(Color(.systemBackground)) // Фон
                }
            }
            .navigationTitle("Курси Валют")
            .toolbar {
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
