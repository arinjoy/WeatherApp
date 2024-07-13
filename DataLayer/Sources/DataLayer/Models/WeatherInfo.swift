import Foundation

public struct WeatherInfo: Decodable {

    public let cityId: Int
    public let name: String

    public let mainInfo: MainInfo
    public let summaries: [SummaryInfo]?
    public let systemInfo: SystemInfo?
    public let visibility: Double?
    public let windInfo: WindInfo?

    private enum CodingKeys: String, CodingKey {
        case cityId = "id"
        case name = "name"
        case mainInfo = "main"
        case summaries = "weather"
        case systemInfo = "sys"
        case visibility = "visibility"
        case windInfo = "wind"
    }
}

public struct MainInfo: Decodable {
    public let temperture: Double
    public let feelsLikeTemperature: Double
    public let minTemperature: Double
    public let maxTemperature: Double
    public let pressureLevel: Double
    public let humidity: Double

    private enum CodingKeys: String, CodingKey {
        case temperture = "temp"
        case feelsLikeTemperature = "feels_like"
        case minTemperature = "temp_min"
        case maxTemperature = "temp_max"
        case pressureLevel = "pressure"
        case humidity = "humidity"
    }
}

public struct SummaryInfo: Decodable {
    public let title: String
    public let description: String

    /// "http://openweathermap.org/img/w/" + iconcode + ".png";
    public let iconCode: String

    private enum CodingKeys: String, CodingKey {
        case title = "main"
        case description = "description"
        case iconCode = "icon"
    }
}

public struct SystemInfo: Decodable {
    public let sunriseTime: Double
    public let sunsetTime: Double

    private enum CodingKeys: String, CodingKey {
        case sunriseTime = "sunrise"
        case sunsetTime = "sunset"
    }
}

public struct WindInfo: Decodable {
    public let speed: Double
    public let degree: Double

    private enum CodingKeys: String, CodingKey {
        case speed = "speed"
        case degree = "deg"
    }
}
