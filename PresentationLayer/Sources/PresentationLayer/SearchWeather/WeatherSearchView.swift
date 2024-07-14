import SwiftUI
import SwiftData
import DomainLayer

public struct WeatherSearchView: View {

    public init() {}

    // MARK: - Properties

    @StateObject var viewModel: WeatherSearchViewModel = .init()

    @State private var searchText = ""
    @State private var isSearching = false

    @State private var isShowingRecentSearches = false

    @Environment(\.modelContext) private var modelContext

    @Query(sort: \SearchLocation.timeStamp, order: .reverse, animation: .smooth)
    var recentLocations: [SearchLocation]

    // MARK: - UI Body

    public var body: some View {
        NavigationStack {
            ZStack {

                DarkGradientView()

                VStack {
                    Spacer()
                    recentLocationsView
                    bottomSearchBarView
                }

                VStack {
                    switch viewModel.loadingState {
                    case .idle:
                        instructionsView

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
            .navigationTitle("")
            .onChange(of: searchText) {
                viewModel.updateSearchQuery(searchText)
            }
            .onChange(of: viewModel.loadingState) {
                if case .success(let item) = viewModel.loadingState {
                    modelContext.insert(
                        SearchLocation(id: item.id, name: item.cityName, timeStamp: Date.now)
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
        .sheet(isPresented: $isShowingRecentSearches) {
            RecentSearchesListView()
        }
    }
}

// MARK: - Private views

private extension WeatherSearchView {

    @ViewBuilder
    var instructionsView: some View {
        VStack(alignment: .center) {
            Spacer()
            Image(systemName: "cloud")
                .symbolRenderingMode(.hierarchical)
                .resizable()
                .scaledToFit()
                .frame(width: 60, height: 60)
                .foregroundColor(.white)
                .accessibilityHidden(true)

            Text(viewModel.greetingMessage)
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
    func searchResultView(from item: WeatherPresentationItem) -> some View {
        VStack(alignment: .center) {
            Spacer()
            weatherDetailView(from: item)
            Spacer()
            Spacer()
            Spacer()
        }
        .offset(y: isSearching ? -60 : 0)
        .padding()
    }

    @ViewBuilder
    func weatherDetailView(from item: WeatherPresentationItem) -> some View {
        WeatherSummaryView(item: item)
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

                TextField(
                    "",
                    text: $searchText,
                    prompt: Text(viewModel.searchBarPrompt).foregroundStyle(.white.opacity(0.7)))
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
            if recentLocations.isEmpty == false {
                Button {
                    isShowingRecentSearches = true
                } label: {
                    HStack(spacing: 10) {
                        Text(viewModel.recentSearchesHeaderText)
                            .font(.body)
                            .foregroundStyle(.white.opacity(0.7))
                            .padding(.leading)

                        Image(systemName: "chevron.right")
                            .foregroundStyle(.white)
                            .frame(height: 30)

                        Spacer()
                    }
                }
                .padding(.bottom, -10)

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
                    .foregroundStyle(.thinMaterial.opacity(0.5))
                    .contentShape(Rectangle())
            )
            .cornerRadius(10)
        }
    }

    // MARK: - Private methods

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(recentLocations[index])
            }
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
