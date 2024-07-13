import Foundation

extension Resource {

    public static func weather(query: String) -> Resource<WeatherInfo> {
        let url = ApiConstants.baseUrl
        let parameters: [(String, CustomStringConvertible)] = [
            ("q", query),
            ("appid", ApiConstants.apiKey),
            ("units", "metric")
        ]
        return Resource<WeatherInfo>(url: url, parameters: parameters)
    }
}
