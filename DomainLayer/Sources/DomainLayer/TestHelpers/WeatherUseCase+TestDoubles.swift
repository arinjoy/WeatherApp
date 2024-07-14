import Foundation
import Combine
import SharedUtils
import DataLayer

// MARK: - UseCase Spy

public final class WeatherUseCaseSpy: WeatherUseCaseType {

    // Spied calls
    public var fetchWeatherCalled: Bool = false

    // Spied values
    public var query: String?

    public func fetchWeather(with query: String) -> AnyPublisher<CityWeather, NetworkError> {
        fetchWeatherCalled = true
        self.query = query
        return .empty()
    }
}

// MARK: - UseCase Mock

public final class WeatherUseCaseMock: WeatherUseCaseType {

    public var returningError: Bool
    public var error: NetworkError
    public var resultingData: CityWeather

    init(
        returningError: Bool = false,
        error: NetworkError = .unknown,
        resultingData: CityWeather = WeatherUseCaseMock.sampleData
    ) {
        self.returningError = returningError
        self.error = error
        self.resultingData = resultingData
    }

    public func fetchWeather(with query: String) -> AnyPublisher<CityWeather, NetworkError> {
        if returningError {
            return .fail(error)
        }
        return .just(resultingData).eraseToAnyPublisher()
    }

    // MARK: - Sample Test data

    public static let sampleData = CityWeather(
        id: "2158177",
        cityName: "Melbourne",
        temperature: 10.19,
        feelsLikeTemperature: 9.48,
        minTemperature: 9.11,
        maxTemperature: 10.93,
        humidity: 85.0,
        windSpeed: 4.5,
        title: "Clouds",
        description: "overcast clouds",
        iconURL: URL(string: "https://openweathermap.org/img/w/04n.png")!
    )
}
