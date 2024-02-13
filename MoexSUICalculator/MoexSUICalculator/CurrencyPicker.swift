import SwiftUI

struct CurrencyPicker: View {
    @Binding var currency: Currency
    let onChange: (Currency) -> Void
    var body: some View {
        Picker("", selection: $currency) {
            ForEach(Currency.allCases) {currency in
                Text(currency.rawValue.uppercased())
            }
        }
        .pickerStyle(.wheel)
        .onChange(of: currency, perform: onChange)
    }
}

//#Preview {
//    CurrencyPicker()
//}
