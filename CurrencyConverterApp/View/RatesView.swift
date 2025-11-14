import SwiftUI

struct RatesView: View {
@EnvironmentObject var viewModel: ExchangeRateViewModel

@State private var searchText = ""
@State private var isSearching = false

// Оновлена логіка фільтрації
private var filteredRates: [String] {
    let allSortedKeys = viewModel.rates.keys.sorted()
    
    if searchText.isEmpty {
        return allSortedKeys
    } else {
        let lowercasedQuery = searchText.lowercased()
        
        return allSortedKeys.filter { currencyCode in
            // 1. Пошук за кодом
            let codeMatch = currencyCode.lowercased().contains(lowercasedQuery)
            
            // 2. Пошук за назвою (з viewModel)
            // Використовуємо '?? ""' на випадок, якщо назва ще не завантажилась
            let nameMatch = (viewModel.currencyNames[currencyCode] ?? "")
                                         .lowercased()
                                         .contains(lowercasedQuery)
            
            return codeMatch || nameMatch
        }
    }
}

var body: some View {
    NavigationView {
        VStack {
            
            if isSearching {
                HStack {
                    TextField("Пошук за кодом або назвою...", text: $searchText)
                        .textFieldStyle(.roundedBorder)
                        .padding(.horizontal)
                    
                    Button("Скасувати") {
                        withAnimation {
                            isSearching = false
                        }
                        searchText = ""
                    }
                    .padding(.trailing)
                }
                .padding(.top, 8)
                .transition(.move(edge: .top).combined(with: .opacity))
            }
            
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
                    ForEach(filteredRates, id: \.self) { currency in
                        if let rate = viewModel.rates[currency] {
                            // CurrencyRow тепер сам бере назву з viewModel,
                            // тому нам не потрібно передавати її сюди.
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
                        .onTapGesture {
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
        .animation(.default, value: isSearching)
        .navigationTitle("Курси Валют")
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    withAnimation {
                        isSearching.toggle()
                    }
                    searchText = ""
                } label: {
                    Image(systemName: "magnifyingglass")
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
