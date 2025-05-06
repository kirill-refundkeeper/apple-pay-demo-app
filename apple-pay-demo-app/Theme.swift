import SwiftUI

enum Theme {
    static let appBackgroundColor = Color(red: 25/255, green: 25/255, blue: 28/255)
    static let cardBackgroundColor = Color(red: 44/255, green: 44/255, blue: 46/255)
    static let textColor = Color.white
    static let secondaryTextColor = Color.gray
    static let yellowAccent = Color.yellow

    static let topGradient = LinearGradient(
        gradient: Gradient(colors: [Color(red: 40/255, green: 35/255, blue: 60/255),
                                    appBackgroundColor.opacity(0.8),
                                    appBackgroundColor]),
        startPoint: .top,
        endPoint: .bottom
    )

}
