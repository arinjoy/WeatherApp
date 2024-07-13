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

    public static func weather(cityId: String) -> Resource<WeatherInfo> {
        let url = ApiConstants.baseUrl
        let parameters: [(String, CustomStringConvertible)] = [
            ("id", cityId),
            ("appid", ApiConstants.apiKey),
            ("units", "metric")
        ]
        return Resource<WeatherInfo>(url: url, parameters: parameters)
    }

}
