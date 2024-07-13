import SwiftUI
import DomainLayer

public struct HomeView: View {

    public init() {}

    @StateObject var viewModel: WeatherSearchViewModel = .init()

    @State private var searchText = ""
    @State private var isSearching = false

    public var body: some View {

        ZStack {

            backgroundGradientView

            VStack {
                Spacer()
                toolBarView
            }

            VStack {
                switch viewModel.weatherSearchState {
                case .idle:
                    greeetingView
                case .success(let weather):
                    searchResultView(from: weather)
                case .failure:
                    EmptyView()
                case .loading:
                    EmptyView()
                case .searching:
                    Text("searching now")
                }
            }
        }
        .onChange(of: searchText) {
            applyQuery()
        }
    }

    private func applyQuery() {
        viewModel.bindSearchQuery(searchText)
    }
}

private extension HomeView {

    @ViewBuilder
    var backgroundGradientView: some View {
        LinearGradient(colors: [
            Color(hue: 0.62, saturation: 0.5, brightness: 0.33),
            Color(hue: 0.66, saturation: 0.8, brightness: 0.1)
        ], startPoint: .top, endPoint: .bottom)
            .ignoresSafeArea()
            .opacity(0.85)
    }

    @ViewBuilder
    var greeetingView: some View {
        VStack(alignment: .leading) {
            Spacer()
            Text("Hello!")
                .font(.largeTitle)
                .fontWeight(.medium)
                .foregroundStyle(.white)
            Spacer()
            Spacer()
            Spacer()
        }
    }

    @ViewBuilder
    func searchResultView(from weather: CityWeather) -> some View {
        VStack(alignment: .center) {
            Spacer()
            weatherDetailView(from: weather)
            Spacer()
            Spacer()
            Spacer()
        }
        .offset(y: isSearching ? -60 : 0)
        .padding()
    }

    @ViewBuilder
    func weatherDetailView(from weather: CityWeather) -> some View {
        VStack(alignment: .center) {
            Text("\(Int(weather.temperature))°")
                .font(.system(size: 100))
                .foregroundStyle(.white)

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
        .onTapGesture {
            withAnimation(.easeIn(duration: 0.3)) {
                if isSearching {
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }
            }
        }
    }

    @ViewBuilder
    var toolBarView: some View {
        HStack(spacing: 0) {
            searchBar
                .offset(x: 10)
            Spacer()
            if isSearching {
                Button { // Dismiss system keyboard
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    withAnimation {
                        isSearching = false
                    }
                } label: {
                    Text("Done")
                        .frame(width: 50, height: 30)
                }
                .tint(.white)
            } else {
                settingsButton
            }
            Spacer()
        }
        .padding(.bottom)
    }

    @ViewBuilder
    var searchBar: some View {
        ZStack {
            Capsule()
                .foregroundStyle(.thinMaterial)
                .frame(width: 310, height: 40)

            HStack {
                Image(systemName: "magnifyingglass")
                    .padding(.leading, 5)
                TextField("Search for a location", text: $searchText)
                    .autocorrectionDisabled()
                    .onTapGesture {
                        isSearching = true
                    }
                Spacer()

                if isSearching && !searchText.isEmpty {
                    Button {
                        searchText = ""
                    } label: {
                        Image(systemName: "x.circle.fill")
                            .foregroundStyle(.white)
                    }
                    .padding(.trailing, 5)
                }
            }
            .foregroundStyle(.white)
            .padding()
            .frame(width: 320, height: 40)
        }
    }

    @ViewBuilder
    var settingsButton: some View {
        Menu {
            // TODO: fill up later based on the need of settings
        } label: {
            Image(systemName: "gear")
                .resizable()
                .foregroundColor(.white)
                .scaledToFit()
                .frame(width: 50, height: 30)
                .shadow(radius: 6, y: 4)
        }
        .buttonStyle(PlainButtonStyle())
    }

}

#Preview {
    HomeView()
}
