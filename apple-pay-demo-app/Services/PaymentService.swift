import Foundation
import PassKit
import StripeApplePay
import SwiftUI

enum PaymentError: Error, LocalizedError {
    case applePayNotSupported
    case configurationError(String)
    case applePayFailed(Error?)
    case applePayCancelled
    case unknown(String?)

    var errorDescription: String? {
        switch self {
        case .applePayNotSupported:
            return "Apple Pay is not supported on this device."
        case .configurationError(let message):
            return "Apple Pay configuration error: \(message)"
        case .applePayFailed(let underlyingError):
            if let error = underlyingError {
                if let pkError = error as? PKPaymentError {
                    return "Apple Pay failed: \(pkError.localizedDescription)"
                }
                return "Apple Pay failed: \(error.localizedDescription)"
            } else {
                return "Apple Pay failed with an unknown error."
            }
        case .applePayCancelled:
            return "Apple Pay payment was cancelled."
        case .unknown(let message):
            return message ?? "An unknown payment error occurred."
        }
    }

    var isUserCancellation: Bool {
        if case .applePayCancelled = self {
            return true
        }
        return false
    }
}

class PaymentService: NSObject, ApplePayContextDelegate {

    private var applePayContext: STPApplePayContext?
    private var clientSecretForPayment: String?

    private var paymentContinuation: CheckedContinuation<Void, Error>?

    func startApplePay(clientSecret: String, plan: SubscriptionPlan) async throws {
        self.applePayContext = nil
        self.clientSecretForPayment = nil
        self.paymentContinuation = nil
        self.clientSecretForPayment = clientSecret
        guard StripeAPI.deviceSupportsApplePay() else { throw PaymentError.applePayNotSupported }

        // CHANGE: Use AppConfig for merchant identifier
        let merchantIdentifier = AppConfig.applePayMerchantIdentifier
        guard !merchantIdentifier.isEmpty else { throw PaymentError.configurationError("Merchant Identifier not configured.") }

        // --- Create Payment Request ---
        let paymentRequest = StripeAPI.paymentRequest(
            withMerchantIdentifier: merchantIdentifier, // Use the variable defined above
            country: "US",
            currency: plan.currency
        )

        let costString = plan.cost.filter("0123456789.".contains)
        guard let costDouble = Double(costString) else {
            throw PaymentError.configurationError("Invalid plan cost format: \(plan.cost)")
        }
        let regularAmount = NSDecimalNumber(value: costDouble)

        let planDescription = "RefundKeeper Pro - \(plan.duration.capitalized)"
        let regularBillingLabel = "RefundKeeper Pro (\(plan.duration.capitalized))"
        guard let managementURL = URL(string: "https://example.com/manage-subscription") else {
            throw PaymentError.configurationError("Invalid Management URL configured.")
        }

        let intervalUnit: NSCalendar.Unit
        let intervalCount: Int = 1
        switch plan.duration.lowercased() {
        case "year": intervalUnit = .year
        case "month": intervalUnit = .month
        case "day": intervalUnit = .day
        case "week":
            throw PaymentError.configurationError("Apple Pay's recurring payment sheet does not support weekly intervals.")
        default:
            throw PaymentError.configurationError("Unsupported plan duration for recurring payment configuration: \(plan.duration)")
        }

        let regularBillingStartDate: Date = plan.hasFreeTrial
            ? (Calendar.current.date(byAdding: .day, value: plan.trialDays ?? 0, to: Date()) ?? Date())
            : Date()

        let regularBillingItem = PKRecurringPaymentSummaryItem(label: regularBillingLabel, amount: regularAmount)
        regularBillingItem.startDate = regularBillingStartDate
        regularBillingItem.intervalUnit = intervalUnit
        regularBillingItem.intervalCount = intervalCount

        let recurringRequest = PKRecurringPaymentRequest(
            paymentDescription: planDescription,
            regularBilling: regularBillingItem,
            managementURL: managementURL
        )

        if plan.hasFreeTrial {
            let trialLabel = "\(plan.trialDays ?? 0)-Day Free Trial"
            let trialBillingItem = PKRecurringPaymentSummaryItem(label: trialLabel, amount: NSDecimalNumber.zero)
            trialBillingItem.startDate = Date()
            trialBillingItem.intervalUnit = .day
            trialBillingItem.intervalCount = plan.trialDays ?? 0
            recurringRequest.trialBilling = trialBillingItem

            paymentRequest.paymentSummaryItems = [
                PKPaymentSummaryItem(label: trialLabel, amount: NSDecimalNumber.zero, type: .pending),
                PKPaymentSummaryItem(label: regularBillingLabel, amount: regularAmount, type: .pending),
                PKPaymentSummaryItem(label: "Total Due Today", amount: NSDecimalNumber.zero, type: .final)
            ]

        } else {
            paymentRequest.paymentSummaryItems = [
                PKPaymentSummaryItem(label: "RefundKeeper Pro", amount: regularAmount, type: .final)
            ]
        }
        paymentRequest.recurringPaymentRequest = recurringRequest

        let context: STPApplePayContext = try await MainActor.run {
            guard let ctx = STPApplePayContext(paymentRequest: paymentRequest, delegate: self) else {
                throw PaymentError.configurationError("Failed to initialize STPApplePayContext. Check device/user restrictions.")
            }
            self.applePayContext = ctx
            return ctx
        }

        try await withCheckedThrowingContinuation { continuation in
            self.paymentContinuation = continuation

            Task { @MainActor in
                context.presentApplePay {
                    print("PaymentService: Attempted to present Apple Pay sheet (Recurring).")
                }
            }
        }
    }

    func applePayContext(_ context: STPApplePayContext, didCreatePaymentMethod paymentMethod: StripeAPI.PaymentMethod, paymentInformation: PKPayment, completion: @escaping STPIntentClientSecretCompletionBlock) {
        guard let secret = self.clientSecretForPayment else {
            print("PaymentService Delegate Error: Missing client secret when creating payment method.")
            completion(nil, NSError(domain: "PaymentService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Client secret missing."]))
            return
        }
        print("PaymentService Delegate: Passing client secret back to SDK")
        completion(secret, nil)
    }

    func applePayContext(_ context: STPApplePayContext, didCompleteWith status: STPApplePayContext.PaymentStatus, error: Error?) {
        guard let continuation = paymentContinuation else {
            print("PaymentService Error: Continuation missing in didCompleteWith.")
            self.applePayContext = nil
            self.clientSecretForPayment = nil
            return
        }
        self.paymentContinuation = nil

        self.applePayContext = nil
        self.clientSecretForPayment = nil

        switch status {
        case .success:
            print("PaymentService Delegate: Payment succeeded!")
            continuation.resume()
        case .error:
            print("PaymentService Delegate: Payment failed: \(error?.localizedDescription ?? "Unknown error")")
            continuation.resume(throwing: PaymentError.applePayFailed(error))
        case .userCancellation:
            print("PaymentService Delegate: Payment cancelled.")
            continuation.resume(throwing: PaymentError.applePayCancelled)
        }
    }
}
