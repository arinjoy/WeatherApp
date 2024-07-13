import SwiftUI
import DomainLayer

struct WeatherSummaryView: View {

    let weather: CityWeather

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("\(Int(weather.temperature))°")
                    .font(.system(size: 100))
                    .foregroundStyle(.white)

                AsyncImage(url: weather.iconURL) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                    case .success(let image):
                        image.resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 100, height: 100)
                    case .failure:
                        Image(systemName: "photo")
                    @unknown default:
                        EmptyView()
                    }
                }
                .frame(maxWidth: 100, maxHeight: 100)
            }

            Text(weather.cityName.prefix(25))
                .font(.largeTitle)
                .fontWeight(.medium)
                .foregroundStyle(.white)
                .lineLimit(1)

            Text(weather.description ?? "")
                .font(.title2)
                .foregroundStyle(.white)
                .lineLimit(1)

            Text("Feels like \(Int(weather.feelsLikeTemperature))°")
                .font(.title2)
                .foregroundStyle(.white)
                .lineLimit(1)
        }
    }
}

#Preview {
    WeatherSummaryView(weather: SampleData.cityWeather)
        .padding(50)
        .background(
            Color.gray
        )
}
