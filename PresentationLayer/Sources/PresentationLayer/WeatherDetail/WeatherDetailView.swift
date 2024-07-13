import SwiftUI
import DomainLayer

struct WeatherDetailView: View {

    let weather: CityWeather

    var body: some View {
        
        ZStack {
        
            backgroundGradientView

            VStack {
                WeatherSummaryView(weather: weather)
                Spacer()
            }
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
    WeatherDetailView(weather: SampleData.cityWeather)
}
