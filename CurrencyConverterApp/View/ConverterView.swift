import SwiftUI

struct ConverterView: View {
    @EnvironmentObject var viewModel: ExchangeRateViewModel
    @FocusState private var isAmountFieldFocused: Bool

    var body: some View {
        NavigationView {
            Form {
                // Секція "Я віддаю"
                Section(header: Text("Я віддаю")) {
                    HStack {
                        // НАДІЙНЕ ВИПРАВЛЕННЯ PICKER
                        Menu {
                            Picker("Валюта", selection: $viewModel.fromCurrency) {
                                ForEach(viewModel.availableCurrencies, id: \.self) { (currency: String) in
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
                        
                        TextField("Сума", text: $viewModel.amountToConvert)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .focused($isAmountFieldFocused)
                            // ДОДАЄМО КНОПКУ "ГОТОВО"
                            .toolbar {
                                ToolbarItemGroup(placement: .keyboard) {
                                    Spacer()
                                    Button("Готово") {
                                        isAmountFieldFocused = false
                                    }
                                }
                            }
                    }
                    // --- ДОДАНО ВІДСТУПИ ---
                    .padding(.horizontal, 8) // Додатковий відступ з боків
                    .padding(.vertical, 4)   // Трохи більше "повітря" зверху і знизу
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
                                ForEach(viewModel.availableCurrencies, id: \.self) { (currency: String) in
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
                    // --- ДОДАНО ВІДСТУПИ ---
                    .padding(.horizontal, 8) // Додатковий відступ з боків
                    .padding(.vertical, 4)   // Трохи більше "повітря" зверху і знизу
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
