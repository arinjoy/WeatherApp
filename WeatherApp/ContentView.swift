import SwiftUI
import PresentationLayer

struct ContentView: View {
    var body: some View {
        WeatherSearchView()
            .modelContainer(for: SearchLocation.self, isAutosaveEnabled: true)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: SearchLocation.self, isAutosaveEnabled: true)
}
