import Foundation

/**
 Please refer to comprehensive documentation available at:
 https://openweathermap.org/api
*/

struct ApiConstants {

    /// Note:  change to other OpenWeatherMap API key if needed
    ///
    /// TESTING NOTE:  modify this to trigger server error
    static let apiKey = "<<YOUR OWN API KEY HERE>>"

    static let baseUrl = URL(string: "https://api.openweathermap.org/data/2.5/weather")!
}
