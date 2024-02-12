import SwiftUI

@main
struct MoexSUICalculatorApp: App {
    var body: some Scene {
        WindowGroup {
            CalculatorView(viewModel: CalculatorViewModel())
        }
    }
}
