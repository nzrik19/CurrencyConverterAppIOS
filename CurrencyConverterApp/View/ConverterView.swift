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
                            // ДОДАЄМО КНОПКУ "ГОТОВО" НАД КЛАВІАТУРОЮ
                            .toolbar {
                                ToolbarItemGroup(placement: .keyboard) {
                                    Spacer() // Кнопка буде праворуч
                                    Button("Готово") {
                                        isAmountFieldFocused = false // Ховаємо клавіатуру
                                    }
                                }
                            }
                    }
                }
                
                // ВИПРАВЛЕННЯ КНОПКИ
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
                        // НАДІЙНЕ ВИПРАВЛЕННЯ PICKER (для "ToCurrency")
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
                }
                
                // Секція з індикативним курсом
                Section {
                    if let fromRate = viewModel.rates[viewModel.fromCurrency], let toRate = viewModel.rates[viewModel.toCurrency], fromRate > 0 {
                        // Рахуємо крос-курс: 1 "From" = X "To"
                        let singleUnitRate = toRate / fromRate
                        Text("1 \(viewModel.fromCurrency) = \(String(format: "%.4f", singleUnitRate)) \(viewModel.toCurrency)")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Конвертер")
        }
        // --- ОНОВЛЕННЯ: Додано виправлення для iPad ---
        .navigationViewStyle(.stack)
    }
}

struct ConverterView_Previews: PreviewProvider {
    static var previews: some View {
        ConverterView()
            .environmentObject(ExchangeRateViewModel())
    }
}

