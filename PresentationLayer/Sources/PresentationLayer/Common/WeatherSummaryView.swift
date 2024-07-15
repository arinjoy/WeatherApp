import SwiftUI
import DomainLayer

struct WeatherSummaryView: View {

    let item: WeatherPresentationItem

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                Text(item.averageTemperature)
                    .font(.system(size: 60))

                remoteWeatherIcon(from: item.iconURL)
            }

            Text(item.cityName)
                .font(.largeTitle)
                .fontWeight(.medium)
                .lineLimit(1)

            Text(item.summary)
                .font(.title2)
                .lineLimit(1)

            HStack {
                Image(systemName: "thermometer")

                Text(item.feelsLike)
                    .font(.title2)
                    .lineLimit(1)
            }

//            infoTileView(icon: "wind", header: "WIND", infoText: item.windSpeed)

        }
        .foregroundStyle(.white)
    }

}

// MARK: - Private views

private extension WeatherSummaryView {

    @ViewBuilder
    func remoteWeatherIcon(from url: URL?) -> some View {
        AsyncImage(url: item.iconURL) { phase in
            switch phase {
            case .success(let image):
                image.resizable()
                    .aspectRatio(contentMode: .fit)
            default:
                EmptyView()
            }
        }
        .frame(width: 60)
    }
}

#Preview {
    WeatherSummaryView(item: .init(SampleData.cityWeather))
        .padding(50)
        .background(
            Color.gray
        )
}
