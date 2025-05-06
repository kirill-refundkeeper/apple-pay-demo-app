
import Foundation

// Centralized configuration constants for the application
enum AppConfig {
    // MARK: - API Configuration
    static let baseAPIURL = URL(string: "https://<YOUR_BACKEND_API_URL>.vercel.app")!

    // MARK: - Stripe Configuration
    static let stripePublishableKey = "pk_test_XXXXXXXXXXXXXXXXXXXX"

    // MARK: - Apple Pay Configuration
    static let applePayMerchantIdentifier = "merchant.com.yourcompany.yourapp"
}

