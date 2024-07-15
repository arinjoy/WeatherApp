import SwiftUI

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
                    Spacer()
                    WeatherSummaryView(item: weatherItem)


                    Spacer().frame(height: 30)

                    HStack(spacing: 20) {
                        infoTileView(icon: "wind", header: "WIND", infoText: weatherItem.windSpeed)

                        infoTileView(icon: "humidity", header: "HUMIDITY", infoText: weatherItem.humidity)
                    }

                    Spacer()
                    Spacer()
                    Spacer()

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
    private func infoTileView(icon: String, header: String, infoText: String) -> some View {

        VStack {
            HStack {
                Image(systemName: icon)
                Text(header)
                    .font(.footnote)
            }
            .foregroundStyle(.white.opacity(0.7))

            Text(infoText)
                .font(.headline)
                .foregroundStyle(.white)
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .foregroundStyle(.thinMaterial.opacity(0.2))
        )
    }
}

#Preview {
    WeatherDetailView(cityName: "Sydney")
}
