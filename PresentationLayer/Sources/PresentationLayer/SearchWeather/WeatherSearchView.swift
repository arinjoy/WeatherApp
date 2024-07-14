import SwiftUI
import SwiftData
import DomainLayer

public struct WeatherSearchView: View {

    public init() {}

    // MARK: - Properties

    @StateObject var viewModel: WeatherSearchViewModel = .init()

    @State private var searchText = ""
    @State private var isSearching = false

    @Environment(\.modelContext) private var modelContext

    @Query(sort: \SearchLocation.timeStamp, order: .reverse, animation: .smooth)
    var recentLocations: [SearchLocation]

    // MARK: - UI Body

    public var body: some View {
        NavigationStack {
            ZStack {
                backgroundGradientView

                VStack {
                    Spacer()
                    recentLocationsView
                    bottomSearchBarView
                }

                VStack {
                    switch viewModel.weatherSearchState {
                    case .idle:
                        greeetingView

                    case .loading:
                        Spacer()
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: Color.white))
                        Spacer()
                        Spacer()

                    case .success(let weather):
                        searchResultView(from: weather)

                    case .failure(let error):
                        Spacer()
                        ErrorMessageView(error: error)
                        Spacer()
                        Spacer()
                    }
                }
            }
            .toolbar { toolBarContent }
            .onChange(of: searchText) {
                viewModel.updateSearchQuery(searchText)
            }
            .onChange(of: viewModel.weatherSearchState) {
                if case .success(let weather) = viewModel.weatherSearchState {
                    modelContext.insert(
                        SearchLocation(id: weather.id, name: weather.cityName, timeStamp: Date.now)
                    )
                }
            }
            .onTapGesture {
                withAnimation(.easeIn(duration: 0.3)) {
                    if isSearching {
                        toggleSystemKeyboard(isShowing: false)
                    }
                }
            }
        }
    }
}

// MARK: - Private views

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
        VStack(alignment: .center) {
            Spacer()
            Image(systemName: "cloud")
                .symbolRenderingMode(.hierarchical)
                .resizable()
                .scaledToFit()
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .frame(width: 60, height: 60)
                .foregroundColor(.white)
                .accessibilityHidden(true)

            Text("Search weather by city name or postcode")
                .font(.title3)
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

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
    }

    @ToolbarContentBuilder
    var toolBarContent: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            Button {
                // TODO: isShowingSettings.toggle()
            } label: {
                Image(systemName: "gear")
                    .resizable()
                    .foregroundColor(.white)
                    .scaledToFit()
                    .frame(width: 50, height: 30)
                    .shadow(radius: 6, y: 4)
                    .accessibilityAddTraits(.isButton)
                    .accessibilityLabel("Settings")
            }
        }
    }

    @ViewBuilder
    var bottomSearchBarView: some View {
        HStack {

            searchBar

            if isSearching {
                Spacer()

                Button {
                    toggleSystemKeyboard(isShowing: false)
                    withAnimation {
                        isSearching = false
                    }
                } label: {
                    Text("Done")
                        .frame(width: 50, height: 30)
                }
                .tint(.white)

                Spacer()
            }
        }
        .padding(.bottom)
    }

    @ViewBuilder
    var searchBar: some View {
        ZStack {
            Capsule()
                .foregroundStyle(.ultraThinMaterial)
                .frame(width: 310, height: 40)

            HStack {
                Image(systemName: "magnifyingglass")
                    .padding(.leading, 5)
                TextField("Search for a city", text: $searchText)
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
                    .accessibilityLabel("Clear")
                    .padding(.trailing, 5)
                }
            }
            .foregroundStyle(.white)
            .padding()
            .frame(width: 320, height: 40)
        }
    }

    @ViewBuilder
    var recentLocationsView: some View {
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
                                Button(role: .destructive) {
                                    modelContext.delete(location)
                                } label: {
                                    Label("Delete", systemImage: "trash")
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

    func toggleSystemKeyboard(isShowing: Bool) {
        if isShowing {
            UIApplication.shared.sendAction(
                #selector(UIResponder.becomeFirstResponder),
                to: nil,
                from: nil,
                for: nil
            )
        } else {
            UIApplication.shared.sendAction(
                #selector(UIResponder.resignFirstResponder),
                to: nil,
                from: nil,
                for: nil
            )
        }

    }

}

#Preview {
    WeatherSearchView()
}
