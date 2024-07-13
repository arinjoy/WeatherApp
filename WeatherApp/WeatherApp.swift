import SwiftUI
import SwiftData
import PresentationLayer

@main
struct WeatherApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: SearchLocation.self)
    }
}
