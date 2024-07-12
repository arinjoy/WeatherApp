import Foundation

/**
 Please refer to comprehensive documentation available at:
 https://openweathermap.org/api
*/

struct ApiConstants {

    /// Note:  change to your own OpenWeatherMap API key if needed
    static let apiKey = "6379ee91d0b77e1f680a38b96ee6b716"

    static let baseUrl = URL(string: "https://api.openweathermap.org/data/2.5/weather")!
}
