import Foundation
import Combine
import DataLayer

public protocol WeatherUseCaseType {

    /// Searches for weather for a given query string of city/location
    func fetchWeather(with query: String) -> AnyPublisher<CityWeather, NetworkError>

}
