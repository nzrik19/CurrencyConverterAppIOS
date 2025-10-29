import SwiftUI

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}


struct ConverterView: View {
    @EnvironmentObject var viewModel: ExchangeRateViewModel
    // @FocusState для керування фокусом клавіатури.
    @FocusState private var isAmountFieldFocused: Bool

    var body: some View {
        NavigationView {
            Form {
                // Секція "Я віддаю"
                Section(header: Text("Я віддаю")) {
                    HStack {
                        Picker("Валюта", selection: $viewModel.fromCurrency) {
                            ForEach(viewModel.availableCurrencies, id: \.self) { currency in
                                // --- ВИПРАВЛЕННЯ: Додаємо прапори ---
                                Text("\(CurrencyUtils.flag(for: currency)) \(currency)")
                                    .tag(currency)
                            }
                        }
                        .pickerStyle(.menu)
                        
                        TextField("Сума", text: $viewModel.amountToConvert)
                            .keyboardType(.decimalPad) // Дозволяє вводити і . і ,
                            .multilineTextAlignment(.trailing)
                            .focused($isAmountFieldFocused) // Прив'язка фокусу
                    }
                }
                
                // Кнопка для обміну валют місцями
                HStack {
                    Spacer()
                    Button(action: {
                        viewModel.swapCurrencies()
                    }) {
                        Image(systemName: "arrow.up.arrow.down.circle.fill")
                            .font(.largeTitle)
                            .foregroundColor(.accentColor)
                    }
                    Spacer()
                }
                .listRowBackground(Color.clear) // Робимо фон рядка прозорим
                
                // Секція "Я отримую"
                Section(header: Text("Я отримую")) {
                    HStack {
                        Picker("Валюта", selection: $viewModel.toCurrency) {
                            ForEach(viewModel.availableCurrencies, id: \.self) { currency in
                                // --- ВИПРАВЛЕННЯ: Додаємо прапори ---
                                Text("\(CurrencyUtils.flag(for: currency)) \(currency)")
                                    .tag(currency)
                            }
                        }
                        .pickerStyle(.menu)
                        
                        Text(String(format: "%.2f", viewModel.convertedAmount))
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .contentTransition(.numericText()) // Плавна анімація зміни числа.
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
            .onTapGesture {
                hideKeyboard()
            }
        }
    }
}

struct ConverterView_Previews: PreviewProvider {
    static var previews: some View {
        ConverterView()
            .environmentObject(ExchangeRateViewModel())
    }
}

