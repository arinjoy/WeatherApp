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

        // Modify the query to append AU country code
        // NOTE: Please see the `transformQueryString(:)` below and technical notes
        // why Australian only search has been implemented at this stage and we are
        // not fuzzy searching globally
        let modifiedQuery = query + ",au"

        return networkService
            .load(Resource<WeatherInfo>.weather(query: modifiedQuery))
            .map { [unowned self] in
                self.mapCityWeather(from: $0)
            }
            .eraseToAnyPublisher()
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
                    temperature: item.mainInfo.temperature,
                    feelsLikeTemperature: item.mainInfo.feelsLikeTemperature,
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

    // TODO: - ✋🏼
    /// Currently this method is not being used as it is not fully optimised yet.
    /// If we don't specify a fixed country code then results into global search combining all possible city names 
    /// across the world. Ideally, we should show a list of cities first when a city is searched and and then tapping
    /// on the city we should fetch weather by it's city Id. That requires two stage UX journey to search for cities
    /// using one api call and fetch weather for single specific city, involving two api calls.
    ///
    /// Modify the incoming query string based on city or postcode
    /// - Parameter query: The raw query string that was sent which could contain city name or postcode
    /// - Returns: The modified query after trimming and possible "au" country injection
    private func transformQueryString(_ query: String) -> String {
        let keyword = query.trimmed()

        var shouldAppendAUCountryCode = false

        if keyword.isNumber && keyword.count == 4 {
            shouldAppendAUCountryCode = true
        } else {
            // There are cities in other countries such as
            // `Mel`, `Melbourn`, `Bris`.
            // So we can filter out some those cities
            // WIP: Not fully implemented yet...
            for city in ["melbourne", "brisbane"] {
                if city.contains(keyword.lowercased()) {
                    shouldAppendAUCountryCode = true
                    break
                } else {
                    continue
                }
            }
        }

        if shouldAppendAUCountryCode {
            return keyword + ",au"
        }

        return keyword
    }

}

private extension String {

    var isNumber: Bool {
        let digitsCharacters = CharacterSet(charactersIn: "0123456789")
        return CharacterSet(charactersIn: self).isSubset(of: digitsCharacters)
    }
}
