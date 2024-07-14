import SwiftUI
import DomainLayer

struct WeatherDetailView: View {

    // MARK: - Properties

    private let cityName: String

    @StateObject var viewModel: WeatherSearchViewModel = .init()

    // MARK: - Initializer

    init(cityName: String) {
        self.cityName = cityName
    }

    // MARK: - UI Body

    var body: some View {
     
        ZStack {
      
            backgroundGradientView

            VStack {
                switch viewModel.loadingState {
                case .loading:
                    Spacer()
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: Color.white))
                    Spacer()
                    Spacer()

                case .success(let weather):
                    WeatherSummaryView(weather: weather)

                case .failure(let error):
                    Spacer()
                    ErrorMessageView(error: error)
                    Spacer()
                    Spacer()

                default:
                    EmptyView()
                }

                Spacer()
            }
        }
        .onAppear {
            viewModel.updateSearchQuery(cityName)
        }
    }

    // MARK: - Private Views

    @ViewBuilder
    private var backgroundGradientView: some View {
        LinearGradient(colors: [
            Color(hue: 0.62, saturation: 0.5, brightness: 0.33),
            Color(hue: 0.66, saturation: 0.8, brightness: 0.1)
        ], startPoint: .top, endPoint: .bottom)
            .ignoresSafeArea()
            .opacity(0.85)
    }
}

#Preview {
    WeatherDetailView(cityName: "Sydney")
}
