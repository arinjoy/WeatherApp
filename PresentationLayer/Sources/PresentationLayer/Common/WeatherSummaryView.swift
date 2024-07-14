import SwiftUI
import DomainLayer

struct WeatherSummaryView: View {

    let item: WeatherPresentationItem

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(item.averageTemperature)
                    .font(.system(size: 100))
                    .foregroundStyle(.white)

                AsyncImage(url: item.iconURL) { phase in
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

            Text(item.cityName)
                .font(.largeTitle)
                .fontWeight(.medium)
                .foregroundStyle(.white)
                .lineLimit(1)

            Text(item.summary)
                .font(.title2)
                .foregroundStyle(.white)
                .lineLimit(1)

            Text(item.feelsLike)
                .font(.title2)
                .foregroundStyle(.white)
                .lineLimit(1)
        }
    }
}

#Preview {
    WeatherSummaryView(item: .init(SampleData.cityWeather))
        .padding(50)
        .background(
            Color.gray
        )
}
