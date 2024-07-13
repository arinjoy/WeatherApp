import SwiftUI

public struct HomeView: View {

    public init() {}

    @StateObject var weatherViewModel: WeatherViewModel = .init()

    @State private var searchText = ""
    @State private var searchTimer: Timer?
    @State private var isSearching = false
    @State private var searchResultsNeeded = false

    @State private var curtainOpacity = 1.0

    public var body: some View {

        ZStack {

            LinearGradient(colors: [
                Color(hue: 0.62, saturation: 0.5, brightness: 0.33),
                Color(hue: 0.66, saturation: 0.8, brightness: 0.1)
            ], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
                .opacity(0.85)

            VStack {
                Spacer()

                if !searchResultsNeeded {
                    Text("Hello!") // TODO: update with welcome message
                    Spacer()
                    Spacer()
                }

                toolBarView
            }

            VStack {
                if weatherViewModel.weatherData != nil && searchResultsNeeded {
                    HStack {
                        VStack(alignment: .leading) {
                            Spacer()
                            searchResultView
                            Spacer()
                            Spacer()
                            Spacer()
                        }
                        .offset(y: isSearching ? -60 : 0)
                        .onTapGesture {
                            hideResults()
                        }
                        .padding()

                        Spacer()
                    }
                }
            }
        }
        .onChange(of: searchText) {
            applyQuery()
        }

    }

    private func hideResults() {
        searchResultsNeeded = false
    }

    private func applyQuery() {
        // Start a new timer with a 1-second delay
        searchTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { _ in

            DispatchQueue.main.async {

                searchResultsNeeded = true
                weatherViewModel.query = searchText
                
                print(searchText)

                Task {
                    await weatherViewModel.fetchWeather()
                }
            }
        }
    }
}

private extension HomeView {
    
    @ViewBuilder
    var searchResultView: some View {

        VStack(alignment: .leading) {
            Text("\(Int(weatherViewModel.weatherData?.temperature  ?? 0))°")
                .font(.system(size: 100))
                .foregroundStyle(.white)

            Text(weatherViewModel.weatherData?.cityName.prefix(25) ?? "")
                .font(.largeTitle)
                .fontWeight(.medium)
                .foregroundStyle(.white)
                .lineLimit(1)

            Text(weatherViewModel.weatherData?.description ?? "")
                .font(.title2)
                .lineLimit(1)
        }
        .onTapGesture {
            withAnimation(.easeIn(duration: 0.3)){
                if isSearching {
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }
                //viewingDetails = true
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
                        weatherViewModel.weatherData = nil
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
