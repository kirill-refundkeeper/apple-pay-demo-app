import SwiftUI

struct SuccessView: View {
    var onContinue: () -> Void 

    var body: some View {
        VStack(spacing: 30) {
            Spacer() 

            Image(systemName: "checkmark.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .foregroundColor(.green) 

            Text("Subscription Activated!")
                .font(.largeTitle.weight(.bold))
                .foregroundColor(Theme.textColor) 

            Text("You now have full access.\nEnjoy the premium features!")
                .font(.title3)
                .foregroundColor(Theme.secondaryTextColor) 
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Spacer() 

            Button(action: onContinue) {
                Text("Continue")
                    .font(.headline.weight(.semibold))
                    .foregroundColor(.black) 
                    .frame(maxWidth: .infinity)
                    .frame(height: 60)
                    .background(Color.green) 
                    .cornerRadius(16)
            }
            .padding(.horizontal)
            .padding(.bottom, 20) 
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity) 
        .background(Theme.appBackgroundColor) 
        .ignoresSafeArea(.container, edges: .bottom) 
    }
}

#Preview {
    SuccessView(onContinue: {})
        .preferredColorScheme(.dark)
}
