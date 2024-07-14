import SwiftUI
import DataLayer

struct ErrorMessageView: View {

    // MARK: - Properties

    let error: NetworkError

    @State private var isAnimatingIcon: Bool = false

    // MARK: - UI Body

    var body: some View {

        VStack(alignment: .center, spacing: 16) {

            Spacer()

            Image(systemName: error.iconName)
                .symbolRenderingMode(.hierarchical)
                .resizable()
                .scaledToFit()
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .frame(width: 60, height: 60)
                .foregroundColor(.white)
                .accessibilityHidden(true)
                .scaleEffect(isAnimatingIcon ? 1.05 : 0.98)
                .rotationEffect(isAnimatingIcon ? .degrees(0) : .degrees(15))
                .opacity(isAnimatingIcon ? 1.0 : 0.7)
                .animation(
                    .spring(response: 1, dampingFraction: 0.2, blendDuration: 0.0)
                    .repeatForever(autoreverses: false),
                    value: isAnimatingIcon
                )
                .padding(.bottom, 6)
                .onAppear {
                    withAnimation {
                        isAnimatingIcon = true
                    }
                }

            Text(error.title)
                .font(.title3)
                .foregroundColor(.white)
                .accessibilityAddTraits(.isHeader)

            Text(error.message)
                .font(.body)
                .foregroundColor(.white)
                .accessibilityAddTraits(.isStaticText)

            Spacer()
            Spacer()
            Spacer()
        }
        .multilineTextAlignment(.center)
        .padding()
    }
}

#Preview {
    ErrorMessageView(error: .notFound)
    .padding(50)
    .background(
        Color.gray
    )
}
