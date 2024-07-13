import Foundation

public struct CityWeather: Hashable, Identifiable {

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
}
