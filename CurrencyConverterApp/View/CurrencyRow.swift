import SwiftUI

struct CurrencyRow: View {
    @EnvironmentObject var viewModel: ExchangeRateViewModel
    
    let currencyCode: String
    let rate: Double
    let baseCurrency: String

    private var currencyName: String {
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
            
            // Назва та код
            VStack(alignment: .leading) {
                Text(currencyName)
                    .font(.headline)
                
                if currencyName != currencyCode {
                    Text(currencyCode)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Курс (З АНІМАЦІЄЮ)
            VStack(alignment: .trailing) {
                Text(String(format: "%.4f", rate))
                    .font(.headline)
                    // Магія плавної зміни чисел (iOS 16+)
                    .contentTransition(.numericText())
                
                Text("1 \(currencyCode) = \(String(format: "%.4f", 1 / rate)) \(baseCurrency)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .contentTransition(.numericText())
            }
            // Ця анімація спрацьовує при зміні значення 'rate'
            .animation(.spring(response: 0.5, dampingFraction: 0.8), value: rate)
            
            // Кнопка "Улюблене"
            Button(action: {
                let generator = UIImpactFeedbackGenerator(style: .light)
                generator.impactOccurred()
                
                withAnimation(.spring()) {
                    viewModel.toggleFavorite(currencyCode)
                }
            }) {
                Image(systemName: viewModel.isFavorite(currencyCode) ? "star.fill" : "star")
                    .foregroundColor(viewModel.isFavorite(currencyCode) ? .orange : .gray.opacity(0.3))
                    .font(.title3)
                    .padding(.leading, 8)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.vertical, 4)
    }
}

struct CurrencyRow_Previews: PreviewProvider {
    static var previews: some View {
        CurrencyRow(currencyCode: "USD", rate: 40.50, baseCurrency: "UAH")
            .environmentObject(ExchangeRateViewModel())
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
