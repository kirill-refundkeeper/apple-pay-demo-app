import SwiftUI
import StripeCore
import StripeApplePay

@main
struct apple_pay_demo_appApp: App {
    init() {
        StripeAPI.defaultPublishableKey = AppConfig.stripePublishableKey
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
