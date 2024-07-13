import Foundation
import DomainLayer

struct SampleData {

    static let cityWeather = CityWeather(
        id: "2158177",
        cityName: "Melbourne",
        temperature: 10.19,
        feelsLikeTemperature: 9.48,
        minTemperature: 9.11,
        maxTemperature: 10.93,
        humidity: 85.0,
        windSpeed: 4.5,
        title: "Clouds",
        description: "overcast clouds",
        iconURL: URL(string: "https://openweathermap.org/img/w/04n.png")!
    )

}
