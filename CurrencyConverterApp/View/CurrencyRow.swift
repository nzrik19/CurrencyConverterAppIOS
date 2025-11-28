import SwiftUI

struct CurrencyRow: View {
// Нам потрібен viewModel, щоб отримати доступ до словника назв
@EnvironmentObject var viewModel: ExchangeRateViewModel

let currencyCode: String
let rate: Double
let baseCurrency: String

// Приватна властивість для отримання назви
private var currencyName: String {
    // Беремо назву з viewModel, або показуємо код, якщо назва ще не завантажилась
    viewModel.currencyNames[currencyCode] ?? currencyCode
}

var body: some View {
    HStack {
        // Прапор
        Text(CurrencyUtils.flag(for: currencyCode))
            .font(.largeTitle)
            .frame(width: 40, height: 40)
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 8))
        
        // --- ОНОВЛЕНИЙ ФОРМАТ ---
        // Назва валюти та (Код)
        VStack(alignment: .leading) {
            // Повна назва (напр., "Japanese Yen")
            Text(currencyName)
                .font(.headline)
            
            // Код (напр., "JPY")
            // Ми показуємо код, лише якщо він *не* збігається з назвою
            // (на випадок, якщо назва ще не завантажилась)
            if currencyName != currencyCode {
                Text(currencyCode)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        // --- КІНЕЦЬ ОНОВЛЕННЯ ---
        
        Spacer()
        
        // Курс
        VStack(alignment: .trailing) {
            Text(String(format: "%.4f", rate))
                .font(.headline)
                .contentTransition(.numericText())
            
            Text("1 \(currencyCode) = \(String(format: "%.4f", 1 / rate)) \(baseCurrency)")
                .font(.caption)
                .foregroundColor(.secondary)
                .contentTransition(.numericText())
        }
        .animation(.default, value: rate)
    }
    .padding(.vertical, 4)
}


}

