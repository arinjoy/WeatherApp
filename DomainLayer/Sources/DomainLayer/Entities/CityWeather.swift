import Foundation

public struct CityWeather: Hashable, Identifiable {

    // MARK: - Properties

    public let id: String
    public let cityName: String

    public let temperature: Double
    public let feelsLikeTemperature: Double
    public let minTemperature: Double
    public let maxTemperature: Double

    public let humidity: Double

    public let windSpeed: Double?

    public let title: String?
    public let description: String?

    public let iconURL: URL?

    // MARK: - Initializer

    public init(
        id: String,
        cityName: String,
        temperature: Double,
        feelsLikeTemperature: Double,
        minTemperature: Double,
        maxTemperature: Double,
        humidity: Double,
        windSpeed: Double?,
        title: String?,
        description: String?,
        iconURL: URL?
    ) {
        self.id = id
        self.cityName = cityName
        self.temperature = temperature
        self.feelsLikeTemperature = feelsLikeTemperature
        self.minTemperature = minTemperature
        self.maxTemperature = maxTemperature
        self.humidity = humidity
        self.windSpeed = windSpeed
        self.title = title
        self.description = description
        self.iconURL = iconURL
    }
}
