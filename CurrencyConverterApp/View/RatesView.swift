import SwiftUI

struct RatesView: View {
    @EnvironmentObject var viewModel: ExchangeRateViewModel
    @State private var searchText = ""
    @FocusState private var isSearchFocused: Bool

    private var filteredRates: [String] {
        // Отримуємо список (або всі, або тільки улюблені - залежить від ViewModel)
        let sourceCurrencies = viewModel.availableCurrencies
        
        if searchText.isEmpty { return sourceCurrencies }
        
        let lowercasedQuery = searchText.lowercased()
        return sourceCurrencies.filter { currencyCode in
            let codeMatch = currencyCode.lowercased().contains(lowercasedQuery)
            let nameMatch = (viewModel.currencyNames[currencyCode] ?? "").lowercased().contains(lowercasedQuery)
            return codeMatch || nameMatch
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                
                // --- Панель пошуку ---
                VStack {
                    HStack(spacing: 12) {
                        HStack(spacing: 8) {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.gray)
                            
                            TextField("Пошук", text: $searchText)
                                .textFieldStyle(.plain)
                                .focused($isSearchFocused)
                        }
                        .padding(.vertical, 10)
                        .padding(.horizontal, 12)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        
                        if !searchText.isEmpty || isSearchFocused {
                            Button("Скасувати") {
                                withAnimation {
                                    searchText = ""
                                    isSearchFocused = false
                                }
                            }
                            .foregroundColor(.accentColor)
                            .transition(.move(edge: .trailing).combined(with: .opacity))
                        }
                    }
                    .animation(.default, value: searchText.isEmpty)
                    .animation(.default, value: isSearchFocused)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color(.systemBackground))
                
                // --- Список ---
                List {
                    if viewModel.isLoading && viewModel.rates.isEmpty {
                        HStack { Spacer(); ProgressView("Завантаження..."); Spacer() }
                            .listRowBackground(Color.clear).listRowSeparator(.hidden)
                    }
                    else if let errorMessage = viewModel.errorMessage, viewModel.rates.isEmpty {
                        VStack {
                            Text("⚠️").font(.largeTitle)
                            Text(errorMessage).foregroundColor(.red)
                            Button("Спробувати знову") { viewModel.fetchRates() }.buttonStyle(.bordered)
                        }
                        .frame(maxWidth: .infinity)
                        .listRowBackground(Color.clear).listRowSeparator(.hidden)
                    }
                    else {
                        // --- ЛОГІКА ДЛЯ ПОРОЖНЬОГО СПИСКУ ---
                        if filteredRates.isEmpty {
                            VStack(spacing: 16) {
                                // Якщо увімкнено режим "Улюблені" і немає пошуку
                                if viewModel.isFavoritesOnlyMode && searchText.isEmpty {
                                    Image(systemName: "star.slash")
                                        .font(.system(size: 50))
                                        .foregroundColor(.gray.opacity(0.5))
                                    Text("Список улюблених порожній")
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    Text("Натисніть на зірочку біля валюти, щоб додати її сюди.")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                        .multilineTextAlignment(.center)
                                        .padding(.horizontal)
                                } else {
                                    // Якщо просто нічого не знайдено через пошук
                                    Text("Нічого не знайдено")
                                        .foregroundColor(.secondary)
                                }
                            }
                            .frame(maxWidth: .infinity, minHeight: 200, alignment: .center)
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                        } else {
                            // Відображення валют
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
                }
                .listStyle(.plain)
                .refreshable { viewModel.fetchRates() }
                
                // --- Дата оновлення ---
                if !viewModel.rates.isEmpty {
                    VStack(spacing: 0) {
                        Divider()
                        Text(viewModel.lastUpdated)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.vertical, 12)
                            .frame(maxWidth: .infinity)
                            .background(Color(.systemBackground))
                    }
                }
            }
            .navigationTitle(viewModel.isFavoritesOnlyMode ? "Улюблені" : "Курси Валют")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        withAnimation {
                            viewModel.isFavoritesOnlyMode.toggle()
                        }
                    }) {
                        Image(systemName: viewModel.isFavoritesOnlyMode ? "star.fill" : "star")
                            .foregroundColor(viewModel.isFavoritesOnlyMode ? .orange : .accentColor)
                    }
                }
                
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
