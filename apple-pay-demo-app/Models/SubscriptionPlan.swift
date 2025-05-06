import Foundation

// MARK: - Data Model for API Response /api/plans
struct SubscriptionPlan: Codable, Identifiable, Hashable {
    let id: String
    let cost: String
    let currency: String
    let duration: String
    let hasFreeTrial: Bool
    let trialDays: Int?

    enum CodingKeys: String, CodingKey {
        case id, cost, currency, duration
        case hasFreeTrial = "has_free_trial"
        case trialDays = "trial_days"
    }

    var displayPrice: String {
        let numericCost = cost.replacingOccurrences(of: "$", with: "")
        let trialInfo = hasFreeTrial ? (trialDays != nil ? " (\(trialDays!) day trial)" : " (trial)") : ""
        return "\(numericCost) \(currency.uppercased()) / \(duration)\(trialInfo)"
    }
}

// MARK: - Data Model for API Response /api/subscription
struct SubscriptionResponse: Codable {
    let clientSecret: String
    let subscriptionId: String
}

// MARK: - Data Model for API Request /api/subscription
struct SubscriptionRequest: Codable {
    let priceId: String
}
