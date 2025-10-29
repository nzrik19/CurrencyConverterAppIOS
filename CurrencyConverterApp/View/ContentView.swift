import SwiftUI

struct MainView: View {
    // Створюємо єдиний екземпляр ViewModel для всього додатку.
    // @StateObject гарантує, що ViewModel буде жити, поки живе View..
    @StateObject private var viewModel = ExchangeRateViewModel()

    var body: some View {
        TabView {
            // Перша вкладка - Курси валют
            RatesView()
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("Курси")
                }

            // Друга вкладка - Конвертер
            ConverterView()
                .tabItem {
                    Image(systemName: "arrow.2.squarepath")
                    Text("Конвертер")
                }
        }
        // Передаємо ViewModel усім дочірнім View через .environmentObject
        // Це дозволяє уникнути передачі viewModel через кожен конструктор.
        .environmentObject(viewModel)
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}

