import SwiftUI
import DomainLayer

struct WeatherDetailView: View {

    private let cityName: String

    init(cityName: String) {
        self.cityName = cityName
    }

    @StateObject var viewModel: WeatherSearchViewModel = .init()

    var body: some View {
        
        ZStack {
        
            backgroundGradientView

            VStack {
                switch viewModel.weatherSearchState {
                case .loading:
                    Spacer()
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: Color.white))
                    Spacer()
                    Spacer()

                case .success(let weather):
                    WeatherSummaryView(weather: weather)

                case .failure:
                    Spacer()
                    Text("Error!")
                        .font(.largeTitle)
                        .fontWeight(.medium)
                        .foregroundStyle(.white)
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

    @ViewBuilder
    var backgroundGradientView: some View {
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
