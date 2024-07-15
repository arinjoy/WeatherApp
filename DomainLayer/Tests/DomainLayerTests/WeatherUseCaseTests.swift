import XCTest
import Combine
@testable import DataLayer
@testable import DomainLayer

final class WeatherUseCaseTests: XCTestCase {

    private var useCase: WeatherUseCaseType!

    private var cancellables: [AnyCancellable] = []

    // MARK: - Lifecycle

    override func tearDown() {
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
        useCase = nil

        super.tearDown()
    }

    // MARK: - Tests

    func testCallingServiceSpy() throws {

        // NOTE:
        // Integration level testing from `UseCase` -> `NetworkService`

        // GIVEN - network service that is a spy
        let serviceSpy = NetworkServiceSpy()
        useCase = WeatherUseCase(networkService: serviceSpy)

        // WHEN - being requested to load data
        useCase.fetchWeather(with: "Sydney")
        .sink { _ in } receiveValue: { _ in
        }.store(in: &cancellables)

        // THEN - Spying works correctly to see what values are being hit

        // Spied call
        XCTAssertTrue(serviceSpy.loadResourceCalled)

        // Spied values
        XCTAssertNotNil(serviceSpy.url)
        XCTAssertEqual(
            serviceSpy.url?.absoluteString,
            "https://api.openweathermap.org/data/2.5/weather"
        )
        XCTAssertNotNil(serviceSpy.parameters)
        XCTAssertEqual(serviceSpy.parameters?.count, 3)

        XCTAssertEqual(serviceSpy.parameters?.first?.0, "q")

        // Note: `au` country code added in the request param to restrict to Australia only result
        XCTAssertEqual(serviceSpy.parameters?.first?.1.description, "Sydney,au")
    }

    func testFetchingSuccess() {

        var receivedError: NetworkError?
        var receivedResponse: CityWeather?

        // GIVEN - the useCase is made out of service mock that returns sample data
        let serviceMock = NetworkServiceMock(
            response: TestHelper.sampleWeatherInfo,
            returningError: false)
        useCase = WeatherUseCase(networkService: serviceMock)

        // WHEN - being requested for sydney
        useCase.fetchWeather(with: "Sydney")
            .sink { completion in
                if case .failure(let error) = completion {
                    receivedError = error
                }
            } receiveValue: { response in
                receivedResponse = response
            }
            .store(in: &cancellables)

        // THEN - received `CityWeather` response should be correct with
        // and being mapped correctly (flattened) from underlying data layer object
        // which is nested substructure

        XCTAssertEqual(receivedResponse?.id, "2147714")
        XCTAssertEqual(receivedResponse?.cityName, "Sydney")
        XCTAssertEqual(receivedResponse?.title, "Clear")
        XCTAssertEqual(receivedResponse?.description, "clear sky")
        XCTAssertEqual(receivedResponse?.temperature, 16.44)
        XCTAssertEqual(receivedResponse?.feelsLikeTemperature, 15.47)
        XCTAssertEqual(receivedResponse?.minTemperature, 15.22)
        XCTAssertEqual(receivedResponse?.maxTemperature, 17.43)
        XCTAssertEqual(receivedResponse?.humidity, 51.0)
        XCTAssertEqual(receivedResponse?.windSpeed, 5.14)
        XCTAssertEqual(
            receivedResponse?.iconURL?.absoluteString,
            "https://openweathermap.org/img/w/01d.png")

        // AND - there should not any error returned
        XCTAssertNil(receivedError)
    }

    func testFetchingFailure() {

        var receivedError: NetworkError?
        var receivedResponse: CityWeather?

        // GIVEN - the useCase is made out of service mock that returns `server` error
        let serviceMock = NetworkServiceMock(
            response: TestHelper.sampleWeatherInfo,
            returningError: true,
            error: .server
        )
        useCase = WeatherUseCase(networkService: serviceMock)

        // WHEN - being requested for query
        useCase.fetchWeather(with: "Sydney")
            .sink { completion in
                if case .failure(let error) = completion {
                    receivedError = error
                }
            } receiveValue: { response in
                receivedResponse = response
            }
            .store(in: &cancellables)

        // THEN - there should any error returned and it is expected `server` error
        XCTAssertEqual(receivedError, .server)

        // AND - Received data response should not arrive
        XCTAssertNil(receivedResponse)
    }
}
