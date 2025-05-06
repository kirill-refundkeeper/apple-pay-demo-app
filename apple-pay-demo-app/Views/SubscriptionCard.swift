import SwiftUI

struct SubscriptionCard: View {
    let plan: SubscriptionPlan
    let isSelected: Bool
    let action: () -> Void

    private var displayWeeklyCostString: String? {
        guard let costValue = Double(plan.cost.filter("0123456789.".contains)) else { return nil }
        let weeklyCost: Double
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = plan.currency
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2

        if plan.duration == "year" {
            weeklyCost = costValue / 52.0
            return formatter.string(from: NSNumber(value: weeklyCost))
        } else if plan.duration == "week" && plan.hasFreeTrial {
            weeklyCost = costValue
            return formatter.string(from: NSNumber(value: weeklyCost))
        }
        return nil
    }

    private var formattedPlanCost: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = plan.currency
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        
        let costValue = Double(plan.cost.filter("0123456789.".contains)) ?? 0.0
        return formatter.string(from: NSNumber(value: costValue)) ?? plan.cost
    }

    var body: some View {
        Button(action: action) {
            HStack(alignment: .center, spacing: 16) {
                
                VStack(alignment: .leading, spacing: 4) {
                    if plan.hasFreeTrial {
                        Text("\(plan.trialDays ?? 3)-Days Free then")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(Theme.textColor)
                        Text("Cancel anytime")
                            .font(.system(size: 13))
                            .foregroundColor(Theme.secondaryTextColor)
                    } else if plan.duration == "year" {
                        HStack(alignment: .center, spacing: 8) {
                            Text("Yearly Access")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(Theme.textColor)
                            Text("Best price")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.black)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(Theme.yellowAccent)
                                .clipShape(Capsule())
                        }
                        Text("$\(plan.cost) / year")
                            .font(.system(size: 15))
                            .foregroundColor(Theme.secondaryTextColor)
                    } else {
                         Text("\(plan.duration.capitalized) Access")
                             .font(.system(size: 17, weight: .semibold))
                             .foregroundColor(Theme.textColor)
                         Text("$\(plan.cost) per \(plan.duration)")
                             .font(.system(size: 13))
                             .foregroundColor(Theme.secondaryTextColor)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text(formattedPlanCost)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(Theme.textColor)

                    Text("per \(plan.duration)")
                        .font(.system(size: 13))
                        .foregroundColor(Theme.secondaryTextColor)
                }
                
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 15)
            .background(Theme.cardBackgroundColor)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? Theme.textColor : Color.clear, lineWidth: 2)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

#Preview("Yearly Card") {
    SubscriptionCard(
        plan: SubscriptionPlan(id: "yearly", cost: "59.99", currency: "USD", duration: "year", hasFreeTrial: false, trialDays: 0),
        isSelected: true,
        action: {}
    )
    .padding()
    .background(Theme.appBackgroundColor)
    .preferredColorScheme(.dark)
}

#Preview("Trial Card") {
    SubscriptionCard(
        plan: SubscriptionPlan(id: "trial", cost: "7.99", currency: "USD", duration: "week", hasFreeTrial: true, trialDays: 3),
        isSelected: false,
        action: {}
    )
    .padding()
    .background(Theme.appBackgroundColor)
    .preferredColorScheme(.dark)
}
