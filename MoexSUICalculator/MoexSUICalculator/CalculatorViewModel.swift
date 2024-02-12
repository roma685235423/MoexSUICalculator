import Foundation

final class CalculatorViewModel: ObservableObject {
    @Published var topCurrency: Currency = .CNY
    @Published var bottomCurrency: Currency = .RUR
    
    @Published var topAmount: Double = 0
    @Published var bottomAmount: Double = 0
    
    private var model = CalculatorModel()
    
    func setTopAmount(_ amount: Double) {
        topAmount = amount
        updateBottomAmount()
    }
    
    func setBottomAmount(_ amount: Double) {
        bottomAmount = topAmount
        updateTopAmount()
    }
    
    func updateTopAmount() {
        let bottomAmount = CurrencyAmount(currency: bottomCurrency, amount: bottomAmount)
        topAmount = model.convert(bottomAmount, to: topCurrency)
    }
    
    func updateBottomAmount() {
        let topAmount = CurrencyAmount(currency: topCurrency, amount: topAmount)
        bottomAmount = model.convert(topAmount, to: bottomCurrency)
    }
}
