import Foundation

extension Resource {

    public static func weather(query: String) -> Resource<WeatherInfo> {
        let url = ApiConstants.baseUrl
        let parameters: [(String, CustomStringConvertible)] = [
            ("appid", ApiConstants.apiKey),
            ("q", query)
        ]
        return Resource<WeatherInfo>(url: url, parameters: parameters)
    }
}
