import SwiftUI

struct CalculatorView: View {
    @ObservedObject var viewModel: CalculatorViewModel
    
    var body: some View {
        List {
            CurrencyInput(
                currency: viewModel.topCurrency,
                amount: viewModel.topAmount,
                calculator: viewModel.setTopAmount
            )
            CurrencyInput(
                currency: viewModel.bottomCurrency,
                amount: viewModel.bottomAmount,
                calculator: viewModel.setBottomAmount
            )
        }
    }
}
    
    #Preview {
        CalculatorView(viewModel: CalculatorViewModel())
    }
