import Foundation
import Combine
import DomainLayer

@MainActor
public class WeatherViewModel: ObservableObject {

    private var weatherUseCase: WeatherUseCase

    @Published var weatherData: CityWeather?

    var query = ""

    public init() {
        weatherUseCase = WeatherUseCase()
    }

    public func fetchWeather() async {
        do {
            weatherData = try await weatherUseCase.fetchWeather(with: query)

        } catch {
            weatherData = nil
        }
    }
}
