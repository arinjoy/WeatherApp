import SwiftUI

struct DarkGradientView: View {
    var body: some View {
        LinearGradient(colors: [
            Color(hue: 0.66, saturation: 0.55, brightness: 0.33),
            Color(hue: 0.66, saturation: 0.8, brightness: 0.11)
        ], startPoint: .top, endPoint: .bottom)
            .ignoresSafeArea()
            .opacity(0.95)
    }
}

#Preview {
    DarkGradientView()
}
