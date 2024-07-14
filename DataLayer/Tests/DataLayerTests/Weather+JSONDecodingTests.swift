import XCTest
@testable import DataLayer

final class WeatherJSONDecodingTests: XCTestCase {

    private var testJSONData: Data!

    private let jsonDecoder = JSONDecoder()

    // MARK: - Tests

    func testMappingSuccess() throws {

        // GIVEN - a valid JSON file with sample weather body
        testJSONData = TestHelper.jsonData(forResource: "weather_info_valid")

        // WHEN - trying to decode the JSON into `WeatherInfo`
        let mappedItem = try XCTUnwrap(jsonDecoder.decode(WeatherInfo.self, from: testJSONData))

        // THEN - the outcome should be mapped from the data

        XCTAssertEqual(mappedItem.cityId, 2147714)
        XCTAssertEqual(mappedItem.name, "Sydney")

        XCTAssertEqual(mappedItem.mainInfo.temperature, 16.44)
        XCTAssertEqual(mappedItem.mainInfo.feelsLikeTemperature, 15.47)
        XCTAssertEqual(mappedItem.mainInfo.humidity, 51.0)
        XCTAssertEqual(mappedItem.mainInfo.minTemperature, 15.22)
        XCTAssertEqual(mappedItem.mainInfo.maxTemperature, 17.43)
        XCTAssertEqual(mappedItem.mainInfo.pressureLevel, 1009.0)

        XCTAssertEqual(mappedItem.windInfo?.speed, 5.14)
        XCTAssertEqual(mappedItem.windInfo?.degree, 260.0)

        XCTAssertEqual(mappedItem.summaries?.first?.title, "Clear")
        XCTAssertEqual(mappedItem.summaries?.first?.iconCode, "01d")
        XCTAssertEqual(mappedItem.summaries?.first?.description, "clear sky")

        XCTAssertEqual(mappedItem.systemInfo?.sunriseTime, 1720904295.0)
        XCTAssertEqual(mappedItem.systemInfo?.sunsetTime, 1720940602.0)
    }

    func testMappingFailure() {

        // GIVEN - a invalid JSON structure
        testJSONData = TestHelper.jsonData(forResource: "weather_info_invalid")

        // WHEN - trying to decode the JSON into `WeatherInfo`
        let mappedItem = try? jsonDecoder.decode(WeatherInfo.self, from: testJSONData)

        // THEN - outcome cannot be mapped
        XCTAssertNil(mappedItem)
    }
}

