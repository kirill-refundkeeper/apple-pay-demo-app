import Foundation
import SwiftUI

@MainActor
class SubscriptionViewModel: NSObject, ObservableObject {

    @Published var plans: [SubscriptionPlan] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var isPaymentSuccessful: Bool = false
    @Published var selectedPlan: SubscriptionPlan?
    @Published var isTrialMode: Bool = true {
        didSet {
            if isTrialMode {
                self.selectedPlan = plans.first { $0.hasFreeTrial } ?? self.selectedPlan
            } else {
                self.selectedPlan = plans.first { !$0.hasFreeTrial && $0.duration == "year" } ?? self.selectedPlan
            }
        }
    }

    private let apiService = SubscriptionAPIService()
    private let paymentService = PaymentService()

    override init() {
        super.init()
    }

    func fetchPlans() async {
        guard plans.isEmpty else { return }
        isLoading = true
        errorMessage = nil
        isPaymentSuccessful = false

        do {
            let fetchedPlans = try await apiService.fetchPlans()
            self.plans = fetchedPlans
            self.selectedPlan = plans.first { $0.hasFreeTrial } ?? plans.first { !$0.hasFreeTrial && $0.duration == "year" } ?? fetchedPlans.first
        } catch {
            handleError(error)
        }
        isLoading = false
    }

    func selectPlan(_ plan: SubscriptionPlan) {
        self.selectedPlan = plan
        if self.isTrialMode != plan.hasFreeTrial {
            Task { @MainActor in
                self.isTrialMode = plan.hasFreeTrial
            }
        }
    }

    func prepareSubscriptionIntent() {
        guard !isLoading else { return }
        guard let planToPurchase = selectedPlan else {
            handleError(NSError(domain: "ViewModel", code: 1, userInfo: [NSLocalizedDescriptionKey: "No plan selected for purchase."]))
            return
        }

        isLoading = true
        errorMessage = nil
        isPaymentSuccessful = false

        Task {
            defer { isLoading = false }

            do {
                let response = try await apiService.createSubscriptionIntent(priceId: planToPurchase.id)

                try await paymentService.startApplePay(clientSecret: response.clientSecret, plan: planToPurchase)

                self.isPaymentSuccessful = true
                self.errorMessage = nil

            } catch let paymentError as PaymentError {
                if paymentError.isUserCancellation {
                    self.errorMessage = nil
                    print("Payment cancelled by user.")
                } else {
                    handleError(paymentError)
                }
                isPaymentSuccessful = false
            } catch {
                handleError(error)
                isPaymentSuccessful = false
            }
        }
    }

    func handleError(_ error: Error) {
        isPaymentSuccessful = false
        self.errorMessage = error.localizedDescription
        print("Error: \(error.localizedDescription)")
    }
}
