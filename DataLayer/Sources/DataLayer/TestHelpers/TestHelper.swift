import Foundation

// swiftlint:disable force_try force_unwrapping
public struct TestHelper {

    public static var sampleWeatherInfo: WeatherInfo {
        return try! JSONDecoder().decode(
            WeatherInfo.self,
            from: TestHelper.jsonData(forResource: "weather_info_valid")
        )
    }

    public static func jsonData(forResource resource: String) -> Data {
        let fileURLPath = Bundle.module.url(forResource: resource,
                                            withExtension: "json",
                                            subdirectory: "JSON/Mocks")

        return try! Data(contentsOf: fileURLPath!)
    }
}
// swiftlint:enable force_try force_unwrapping
