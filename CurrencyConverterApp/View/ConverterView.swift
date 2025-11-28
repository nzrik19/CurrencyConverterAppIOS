import SwiftUI

struct ConverterView: View {
    @EnvironmentObject var viewModel: ExchangeRateViewModel
    @FocusState private var isAmountFieldFocused: Bool

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                
                Form {
                    // Секція "Я віддаю"
                    Section(header: Text("Я віддаю")) {
                        HStack {
                            Menu {
                                Picker("Валюта", selection: $viewModel.fromCurrency) {
                                    ForEach(viewModel.availableCurrencies, id: \.self) { currency in
                                        Text("\(CurrencyUtils.flag(for: currency)) \(currency)")
                                            .tag(currency)
                                    }
                                }
                                .pickerStyle(.inline)
                            } label: {
                                Text("\(CurrencyUtils.flag(for: viewModel.fromCurrency)) \(viewModel.fromCurrency)")
                                    .font(.body)
                                    .foregroundColor(Color.primary)
                            }
                            
                            // Пряма прив'язка + .onChange для валідації вводу
                            TextField("Сума", text: $viewModel.amountToConvert)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                                .focused($isAmountFieldFocused)
                                // --- ВИПРАВЛЕННЯ ДЛЯ iOS 17+ ---
                                // Замість { newValue in ... } використовуємо { oldValue, newValue in ... }
                                .onChange(of: viewModel.amountToConvert) { oldValue, newValue in
                                    // 1. Дозволяємо лише цифри і розділювачі
                                    let filtered = newValue.filter { "0123456789.,".contains($0) }
                                    
                                    if filtered != newValue {
                                        viewModel.amountToConvert = filtered
                                        return
                                    }
                                    
                                    // 2. Перевірка на розділювачі (крапка або кома)
                                    let separators = CharacterSet(charactersIn: ".,")
                                    if let range = filtered.rangeOfCharacter(from: separators) {
                                        let integerPart = filtered[..<range.lowerBound]
                                        let fractionalPart = filtered[range.upperBound...]
                                        
                                        // Забороняємо другий розділювач (напр. 10.5.5)
                                        if fractionalPart.rangeOfCharacter(from: separators) != nil {
                                            viewModel.amountToConvert = String(filtered.dropLast())
                                            return
                                        }
                                        
                                        // 3. ОБМЕЖЕННЯ ДО 2 ЦИФР
                                        if fractionalPart.count > 2 {
                                            let truncatedFraction = fractionalPart.prefix(2)
                                            // Повертаємо назад "обрізане" значення
                                            viewModel.amountToConvert = String(integerPart) + String(filtered[range]) + String(truncatedFraction)
                                        }
                                    }
                                }
                                // -------------------------
                                .toolbar {
                                    ToolbarItemGroup(placement: .keyboard) {
                                        Spacer()
                                        Button("Готово") {
                                            isAmountFieldFocused = false
                                        }
                                    }
                                }
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                    }
                    
                    // Кнопка обміну
                    Section {
                        HStack {
                            Spacer()
                            Button(action: {
                                viewModel.swapCurrencies()
                            }) {
                                Image(systemName: "arrow.up.arrow.down.circle.fill")
                                    .font(.largeTitle)
                                    .foregroundColor(.accentColor)
                            }
                            .contentShape(Rectangle())
                            Spacer()
                        }
                    }
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets())
                    
                    // Секція "Я отримую"
                    Section(header: Text("Я отримую")) {
                        HStack {
                            Menu {
                                Picker("Валюта", selection: $viewModel.toCurrency) {
                                    ForEach(viewModel.availableCurrencies, id: \.self) { currency in
                                        Text("\(CurrencyUtils.flag(for: currency)) \(currency)")
                                            .tag(currency)
                                    }
                                }
                                .pickerStyle(.inline)
                            } label: {
                                Text("\(CurrencyUtils.flag(for: viewModel.toCurrency)) \(viewModel.toCurrency)")
                                    .font(.body)
                                    .foregroundColor(Color.primary)
                            }
                            
                            Text(String(format: "%.2f", viewModel.convertedAmount))
                                .frame(maxWidth: .infinity, alignment: .trailing)
                                .contentTransition(.numericText())
                                .animation(.default, value: viewModel.convertedAmount)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                    }
                    
                    // Секція з індикативним курсом
                    Section {
                        if let fromRate = viewModel.rates[viewModel.fromCurrency], let toRate = viewModel.rates[viewModel.toCurrency], fromRate > 0 {
                            let singleUnitRate = toRate / fromRate
                            Text("1 \(viewModel.fromCurrency) = \(String(format: "%.4f", singleUnitRate)) \(viewModel.toCurrency)")
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                // Блок з датою оновлення ВИДАЛЕНО звідси
            }
            .navigationTitle("Конвертер")
        }
        .navigationViewStyle(.stack)
    }
}

struct ConverterView_Previews: PreviewProvider {
    static var previews: some View {
        ConverterView()
            .environmentObject(ExchangeRateViewModel())
    }
}
