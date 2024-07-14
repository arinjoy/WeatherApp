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

            DarkGradientView()

            VStack {
                switch viewModel.loadingState {
                case .loading:
                    Spacer()
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: Color.white))
                    Spacer()
                    Spacer()

                case .success(let weatherItem):
                    WeatherSummaryView(item: weatherItem)

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
}

#Preview {
    WeatherDetailView(cityName: "Sydney")
}
