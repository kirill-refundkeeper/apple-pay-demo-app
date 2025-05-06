import SwiftUI
import StripeApplePay
import PassKit

struct ContentView: View {
    @StateObject private var viewModel = SubscriptionViewModel()

    var body: some View {
        ZStack {
            Theme.appBackgroundColor.ignoresSafeArea()

            if viewModel.isPaymentSuccessful {
                SuccessView {
                    viewModel.isPaymentSuccessful = false
                }
            } else {
                VStack(spacing: 0) {
                    ZStack(alignment: .top) {
                        Theme.topGradient
                            .frame(height: 350)
                            .ignoresSafeArea(edges: .top)

                        VStack(spacing: 16) {
                            HStack {
                                Spacer()
                                Text("Pro")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.black)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 5)
                                    .background(Color.white.opacity(0.8))
                                    .cornerRadius(8)
                                Spacer()
                            }
                            .padding(.top, (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.safeAreaInsets.top ?? 0 + 15)

                            Spacer()

                            Text("Unlock restful\nsleep")
                                .font(.system(size: 42, weight: .bold))
                                .foregroundColor(Theme.textColor)
                                .multilineTextAlignment(.center)
                                .lineSpacing(4)
                                .lineLimit(2)
                                .fixedSize(horizontal: false, vertical: true)
                                .shadow(color: .black.opacity(0.3), radius: 5, y: 3)
                                .padding(.horizontal)

                            VStack(alignment: .leading, spacing: 20) {
                                FeatureRow(icon: "moon.stars.fill", title: "Relaxing Sleepscapes", subtitle: "Immersive journeys to help you unwind")
                                FeatureRow(icon: "brain.head.profile", title: "Calm Your Mind", subtitle: "Soothe thoughts and fall asleep faster")
                                FeatureRow(icon: "slider.horizontal.3", title: "Personalized Experience", subtitle: "Content adapted to your sleep needs")
                            }
                            .padding(.top, 20)
                            .padding(.horizontal, 30)
                            .padding(.bottom, 40)

                        }
                        .frame(height: 350)
                    }

                    Spacer()

                    VStack(spacing: 20) {
                        if viewModel.isLoading && viewModel.plans.isEmpty {
                            Spacer()
                            ProgressView().tint(Theme.textColor)
                            Spacer()
                        } else if let errorMessage = viewModel.errorMessage {
                            Spacer()
                            VStack {
                                Text("Error: \(errorMessage)")
                                    .foregroundColor(.red)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal)
                                Button("Retry Fetch") {
                                    Task { await viewModel.fetchPlans() }
                                }
                                .buttonStyle(.bordered)
                                .tint(.red)
                                .padding(.top, 4)
                            }
                            .padding()
                            Spacer()
                        } else {
                            HStack {
                                Text("Enable Free Trial")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(Theme.textColor)
                                Spacer()
                                Toggle("", isOn: $viewModel.isTrialMode)
                                    .labelsHidden()
                                    .toggleStyle(SwitchToggleStyle(tint: .green))
                                    .disabled(viewModel.isLoading)
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 15)
                            .background(Theme.cardBackgroundColor)
                            .cornerRadius(16)

                            if let yearlyPlan = viewModel.plans.first(where: { !$0.hasFreeTrial && $0.duration == "year" }) {
                                SubscriptionCard(
                                    plan: yearlyPlan,
                                    isSelected: yearlyPlan.id == viewModel.selectedPlan?.id,
                                    action: { viewModel.selectPlan(yearlyPlan) }
                                )
                                .disabled(viewModel.isLoading)
                            }

                            if let trialPlan = viewModel.plans.first(where: { $0.hasFreeTrial }) {
                                SubscriptionCard(
                                    plan: trialPlan,
                                    isSelected: trialPlan.id == viewModel.selectedPlan?.id,
                                    action: { viewModel.selectPlan(trialPlan) }
                                )
                                .disabled(viewModel.isLoading)
                            }


                            Button(action: {
                                viewModel.prepareSubscriptionIntent()
                            }) {
                                HStack {
                                    Spacer()
                                    if viewModel.isLoading && viewModel.selectedPlan != nil {
                                        ProgressView().tint(.black)
                                    } else {
                                        Text(viewModel.selectedPlan?.hasFreeTrial ?? false ? "Start Free Trial" : "Continue")
                                            .font(.system(size: 17, weight: .semibold))
                                    }
                                    Spacer()
                                }
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .frame(height: 60)
                                .background(Color.green)
                                .cornerRadius(16)
                            }
                            .disabled(viewModel.selectedPlan == nil || viewModel.isLoading)

                            HStack(spacing: 32) {
                                Button("Restore Purchases") { }
                                Button("Privacy Policy") { }
                                Button("Terms of Use") { }
                            }
                            .font(.system(size: 13))
                            .foregroundColor(Theme.secondaryTextColor)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 10)
                    .frame(maxHeight: .infinity)
                    .ignoresSafeArea(.container, edges: .bottom)

                }
            }
        }
        .animation(nil, value: viewModel.isLoading)
        .animation(.default, value: viewModel.isPaymentSuccessful)
        .animation(nil, value: viewModel.selectedPlan)
        .animation(nil, value: viewModel.errorMessage)
        .task { if viewModel.plans.isEmpty { await viewModel.fetchPlans() } }
    }
}

#Preview("Paywall View") {
    ContentView()
        .preferredColorScheme(.dark)
}
