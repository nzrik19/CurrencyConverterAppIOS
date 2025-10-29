import SwiftUI

struct CurrencyRow: View {
    let currencyCode: String
    let rate: Double
    let baseCurrency: String

    var body: some View {
        HStack {
            // --- ФІКСОВАНИЙ РОЗМІР ПРАПОРА ---
            // Встановлюємо фіксований розмір для Text,
            // щоб усі елементи списку були вирівняні.
            Text(CurrencyUtils.flag(for: currencyCode))
                .font(.largeTitle) // Великий шрифт для гарного емодзі
                .frame(width: 40, height: 40, alignment: .center) // Фіксований розмір
                .background(Color(UIColor.systemGray6)) // Легкий фон-контейнер
                .clipShape(RoundedRectangle(cornerRadius: 6)) // Заокруглені кути.
            
            VStack(alignment: .leading) {
                Text(currencyCode)
                    .font(.headline)
                // Форматуємо рядок для курсу
                Text("1 \(currencyCode) = \(String(format: "%.4f", rate)) \(baseCurrency)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Відображення основного курсу
            Text(String(format: "%.4f", rate))
                .font(.body)
                .fontWeight(.medium)
        }
        .padding(.vertical, 4) // Невеликий відступ для кращої читабельності
    }
}

struct CurrencyRow_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            CurrencyRow(currencyCode: "USD", rate: 40.5123, baseCurrency: "UAH")
                .previewLayout(.sizeThatFits)
                .padding()
            
            CurrencyRow(currencyCode: "ANG", rate: 23.5123, baseCurrency: "UAH")
                .previewLayout(.sizeThatFits)
                .padding()
        }
    }
}

