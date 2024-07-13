import Foundation
import Combine
import DataLayer
import SharedUtils

public final class WeatherUseCase: WeatherUseCaseType {

    // MARK: - Properties

    private let networkService: NetworkServiceType

    // MARK: - Initializer

    public init(
        networkService: NetworkServiceType = ServicesProvider.defaultProvider().network
    ) {
        self.networkService = networkService
    }

    // MARK: - WeatherUseCaseType

    public func fetchWeather(with query: String) -> AnyPublisher<CityWeather, NetworkError> {
        networkService
            .load(Resource<WeatherInfo>.weather(query: query + ",au"))
            .map { [unowned self] in
                self.mapCityWeather(from: $0)
            }
            .subscribe(on: Scheduler.background)
            .receive(on: Scheduler.main)
            .eraseToAnyPublisher()
    }

    public func fetchWeather(with query: String) async throws -> CityWeather {
        try await fetchWeather(with: query).async()
    }

}

// MARK: - Private Helpers

private extension WeatherUseCase {

    /// Maps data from `DataLayer.WeatherInfo` to `DomainLayer.CityWeather`
    /// Note:  There is some subtle differences between data structures at two layers. Basically at domain layer the 
    /// data is flattened inside one structure and some custom logic and/or formatting rules can be applied here.
    /// Similarly `DataLayer.NetworkError` can also be converted into `DomainLayer.DomainError` for more
    /// granular and customised error handling and unit testing.

    private func mapCityWeather(from item: WeatherInfo) -> CityWeather {
        CityWeather(id: String(item.cityId),
                    cityName: item.name,
                    temperature: item.mainInfo.temperture,
                    minTemperature: item.mainInfo.minTemperature,
                    maxTemperature: item.mainInfo.maxTemperature,
                    humidity: item.mainInfo.humidity,
                    windSpeed: item.windInfo?.speed,
                    title: item.summaries?.first?.title,
                    description: item.summaries?.first?.description,
                    iconURL: URL(
                        string: "https://openweathermap.org/img/w/" +
                                (item.summaries?.first?.iconCode ?? "") + ".png"
                    )
        )
    }
}
