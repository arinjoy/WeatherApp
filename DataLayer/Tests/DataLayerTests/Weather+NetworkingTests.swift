import XCTest
import Combine
@testable import DataLayer

final class WeatherNetworkingTests: XCTestCase {

    var cancellables: [AnyCancellable] = []

    // MARK: - Lifecycle

    override func tearDown() {
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()

        super.tearDown()
    }

    // MARK: - Tests

    func testSpyLoadingResource() throws {

        // GIVEN - network service that is a spy
        let networkServiceSpy = NetworkServiceSpy()

        // WHEN - loading of desired resource type
        _ = networkServiceSpy
            .load(Resource<WeatherInfo>.weather(query: "Sydney"))

        // THEN - Spying works correctly to see what values are being hit

        // Spied call
        XCTAssertTrue(networkServiceSpy.loadResourceCalled)

        // Spied values
        XCTAssertNotNil(networkServiceSpy.url)
        XCTAssertEqual(
            networkServiceSpy.url?.absoluteString,
            "https://api.openweathermap.org/data/2.5/weather"
        )

        XCTAssertNotNil(networkServiceSpy.parameters)
        XCTAssertEqual(networkServiceSpy.parameters?.count, 3)

        XCTAssertEqual(networkServiceSpy.parameters?[0].0, "q")
        XCTAssertEqual(networkServiceSpy.parameters?[0].1.description, "Sydney")

        XCTAssertEqual(networkServiceSpy.parameters?[1].0, "appid")
        XCTAssertEqual(networkServiceSpy.parameters?[1].1.description, "6379ee91d0b77e1f680a38b96ee6b716")

        XCTAssertEqual(networkServiceSpy.parameters?[2].0, "units")
        XCTAssertEqual(networkServiceSpy.parameters?[2].1.description, "metric")

        XCTAssertNotNil(networkServiceSpy.request)
    }

    func testSuccessfulLoading() throws {
        var receivedError: NetworkError?
        var receivedResponse: WeatherInfo?

        // GIVEN - network service that is a Mock with sample list successfully without error
        let networkServiceMock = NetworkServiceMock(response: TestHelper.sampleWeatherInfo, returningError: false)

        // WHEN - loading of desired resource type
        networkServiceMock
            .load(Resource<WeatherInfo>.weather(query: "Sydney"))
            .sink { completion in
                if case .failure(let error) = completion {
                    receivedError = error
                }
            } receiveValue: { response in
                receivedResponse = response
            }
            .store(in: &cancellables)

        // THEN - received weather response should be correct
        XCTAssertNotNil(receivedResponse)
        XCTAssertEqual(receivedResponse?.cityId, 2147714)
        XCTAssertEqual(receivedResponse?.name, "Sydney")
        XCTAssertEqual(receivedResponse?.mainInfo.temperture, 16.44)
        XCTAssertEqual(receivedResponse?.mainInfo.feelsLikeTemperature, 15.47)
        XCTAssertEqual(receivedResponse?.mainInfo.humidity, 51.0)
        XCTAssertEqual(receivedResponse?.summaries?.first?.title, "Clear")
        XCTAssertEqual(receivedResponse?.summaries?.first?.iconCode, "01d")
        XCTAssertEqual(receivedResponse?.summaries?.first?.description, "clear sky")
        XCTAssertEqual(receivedResponse?.systemInfo?.sunriseTime, 1720904295.0)
        XCTAssertEqual(receivedResponse?.systemInfo?.sunsetTime, 1720940602.0)

        // Note: The rest of the JSON mapping related tests are always done
        // at the unit level inside`Weather+JSONDecodingTests`.
        // So not repeating for each of the avialable property...

        // AND - there should not any error returned
        XCTAssertNil(receivedError)
    }

    func testFailureLoading() throws {
        var receivedError: NetworkError?
        var receivedResponse: WeatherInfo?

        // GIVEN - network service that to return an `.notFound` error
        let networkServiceMock = NetworkServiceMock(
            response: TestHelper.sampleWeatherInfo,
            returningError: true,
            error: .notFound
        )

        // WHEN - loading of desired resource type
        networkServiceMock
            .load(Resource<WeatherInfo>.weather(query: "Test city"))
            .sink { completion in
                if case .failure(let error) = completion {
                    receivedError = error
                }
            } receiveValue: { response in
                receivedResponse = response
            }
            .store(in: &cancellables)

        // THEN - there should be an error returned
        XCTAssertNotNil(receivedError)

        // AND - error type is desired
        XCTAssertEqual(receivedError, .notFound)

        // AND - weather response should not be returned
        XCTAssertNil(receivedResponse)
    }

}
