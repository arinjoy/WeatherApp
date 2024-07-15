import SwiftUI
import PresentationLayer

struct ContentView: View {
    var body: some View {
        RootView()
            .modelContainer(for: SearchLocation.self, isAutosaveEnabled: true)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: SearchLocation.self, isAutosaveEnabled: true)
}
