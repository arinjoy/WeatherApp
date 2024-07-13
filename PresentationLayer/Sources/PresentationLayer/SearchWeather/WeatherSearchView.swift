import SwiftUI
import SwiftData
import DomainLayer

public struct WeatherSearchView: View {

    public init() {}

    @StateObject var viewModel: WeatherSearchViewModel = .init()

    @State private var searchText = ""
    @State private var isSearching = false

    @Environment(\.modelContext) private var modelContext

    @Query(sort: \SearchLocation.timeStamp, order: .reverse, animation: .smooth) var recentLocations: [SearchLocation]

    public var body: some View {
        NavigationStack {
            ZStack {
                backgroundGradientView

                VStack {
                    Spacer()
                    recentLocationsView
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
                    default:
                        EmptyView()
                    }
                }
            }
            .onChange(of: searchText) {
                applyQuery()
            }
            .onChange(of: viewModel.weatherSearchState) {
                if case .success(let weather) = viewModel.weatherSearchState {
                    modelContext.insert(
                        SearchLocation(id: weather.id, name: weather.cityName, timeStamp: Date.now)
                    )
                }
            }
        }

    }

    private func applyQuery() {
        viewModel.bindSearchQuery(searchText)
    }
}

private extension WeatherSearchView {

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
        WeatherSummaryView(weather: weather)
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

    private var recentLocationsView: some View {
        VStack {
            if !recentLocations.isEmpty {
                HStack {
                    Text("Recent Searches")
                        .font(.callout)
                        .foregroundStyle(.white.opacity(0.7))
                        .padding(.leading)
                        .padding(.bottom, -10)
                    Spacer()
                }
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(recentLocations, id: \.timeStamp) { location in
                        locationTile(from: location)
                            .contextMenu {
                                Button {
                                    modelContext.delete(location)
                                } label: {
                                    Text("Delete")
                                }
                            }
                    }
                }
                .padding(.vertical, 8)
                .padding(.leading)
            }
        }
    }

    @ViewBuilder
    func locationTile(from location: SearchLocation) -> some View {
        NavigationLink {
            WeatherDetailView(cityName: location.name)
        } label: {
            Text(location.name)
                .font(.headline)
                .foregroundStyle(.white)
                .padding(.vertical, 6)
                .padding(.horizontal, 6)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .foregroundStyle(.thinMaterial)
                    .contentShape(Rectangle())
            )
            .cornerRadius(10)
        }
    }

}

#Preview {
    WeatherSearchView()
}
