# Apple Pay Demo App

## 1. Project Description

This is a simple iOS SwiftUI application demonstrating the integration of Apple Pay for recurring subscriptions using the Stripe SDK. It showcases a sample paywall screen for a "Pro" subscription with options for yearly payment and a free trial period.

The app includes:
- A basic UI simulating a paywall for a premium service.
- Integration with Stripe Apple Pay (`StripeApplePay`) for handling payments.
- A backend interaction simulation (via a Vercel backend URL defined in `AppConfig`) to fetch subscription plans and create payment intents. The backend code can be found here: [apple-pay-demo-backend](https://github.com/refundkeeper/apple-pay-demo-backend).
- Handling of Apple Pay's `PKRecurringPaymentRequest` for setting up recurring billing details.

## 2. How to Run

1.  **Clone the repository:**
    ```bash
    git clone <repository-url>
    ```
2.  **Navigate to the project directory:**
    ```bash
    cd apple-pay-demo-app
    ```
3.  **Open the project in Xcode:**
    Open the `.xcodeproj` file.
4.  **Configure Signing & Capabilities:**
    - Ensure you have a valid Apple Developer account set up in Xcode.
    - Go to the project settings -> Signing & Capabilities tab.
    - Select your development team.
    - Make sure the "Apple Pay Payment Processing" capability is added and configured with your merchant identifier. You might need to create a new Merchant ID in your Apple Developer account if you don't have one matching this.
5.  **Run the app:**
    Select a target device or simulator and press Cmd+R or click the Run button in Xcode.

**Note:** The project uses a hardcoded Stripe publishable test key (`pk_test_...`) and a specific merchant identifier in `AppConfig.swift`. For real-world use, you would replace these with your actual keys and identifiers. The backend URL points to a demo service (source code [here](https://github.com/refundkeeper/apple-pay-demo-backend)); you would need your own backend implementation to handle plan fetching and subscription creation with Stripe.

---

## Promotion

Check out [RefundKeeper](https://refundkeeper.com) for automatically managing refund requests and saving revenue for your iOS apps & games!

