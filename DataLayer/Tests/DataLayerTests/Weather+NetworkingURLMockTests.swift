import XCTest
import Combine
@testable import DataLayer

// swiftlint:disable force_unwrapping
final class WeatherNetworkingURLMockTests: XCTestCase {

    // MARK: - Properties

    private lazy var sessionConfiguration: URLSessionConfiguration = {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [URLProtocolMock.self]
        return config
    }()

    private lazy var networkService = NetworkService(with: sessionConfiguration)

    private let resource = Resource<WeatherInfo>.weather(query: "Sydney")

    private var cancellables: [AnyCancellable] = []

    // MARK: - Lifecycle

    override func setUp() {
        super.setUp()

        URLProtocol.registerClass(URLProtocolMock.self)
    }

    override func tearDown() {
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()

        super.tearDown()
    }

    // MARK: - Tests

    func testURLoadingSuccess() {

        // GIVEN
        var response: WeatherInfo!
        let expectation = self.expectation(description: "networkServiceExpectation")
        URLProtocolMock.requestHandler = { _ in
            let response = HTTPURLResponse(
                url: self.resource.url,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, TestHelper.jsonData(forResource: "weather_info_valid"))
        }

        // WHEN
        networkService.load(resource)
            .sink(receiveCompletion: { _ in },
                  receiveValue: { value in
                response = value
                expectation.fulfill()
            })
            .store(in: &cancellables)

        // THEN
        self.waitForExpectations(timeout: 1.0, handler: nil)

        // There valid response should arrive
        XCTAssertEqual(response.cityId, 2147714)
        XCTAssertEqual(response.mainInfo.temperature, 16.44)

    }

    func testURLoadingFailure500ServerError() {
        var resultingError: NetworkError!

        // GIVEN
        let expectation = self.expectation(description: "networkServiceExpectation")
        URLProtocolMock.requestHandler = { _ in
            let response = HTTPURLResponse(
                url: self.resource.url,
                statusCode: 500,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, Data())
        }

        // WHEN
        networkService.load(resource)
            .sink(receiveCompletion: { completion in
                switch  completion {
                case .failure(let error):
                    resultingError = error
                    expectation.fulfill()
                case .finished: break
                }
            }, receiveValue: { _ in })
            .store(in: &cancellables)

        // THEN
        self.waitForExpectations(timeout: 1.0, handler: nil)

        XCTAssertEqual(resultingError, .server)
    }

    func testURLoadingFailure403ForbiddenError() {
        var resultingError: NetworkError!

        // GIVEN
        let expectation = self.expectation(description: "networkServiceExpectation")
        URLProtocolMock.requestHandler = { _ in
            let response = HTTPURLResponse(
                url: self.resource.url,
                statusCode: 403,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, Data())
        }

        // WHEN
        networkService.load(resource)
            .sink(receiveCompletion: { completion in
                switch  completion {
                case .failure(let error):
                    resultingError = error
                    expectation.fulfill()
                case .finished: break
                }
            }, receiveValue: { _ in })
            .store(in: &cancellables)

        // THEN
        self.waitForExpectations(timeout: 1.0, handler: nil)

        XCTAssertEqual(resultingError, .forbidden)
    }

    func testURLLoadingFailureJSONDecodingError() {

        // GIVEN
        var resultingError: NetworkError!
        let expectation = self.expectation(description: "networkServiceExpectation")
        URLProtocolMock.requestHandler = { _ in
            let response = HTTPURLResponse(
                url: self.resource.url,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, Data()) // Empty data
        }

        // WHEN
        networkService.load(resource)
            .sink(receiveCompletion: { completion in
                switch  completion {
                case .failure(let error):
                    resultingError = error
                    expectation.fulfill()
                case .finished: break
                }
            }, receiveValue: { _ in })
            .store(in: &cancellables)

        // THEN
        self.waitForExpectations(timeout: 1.0, handler: nil)
        guard case .jsonDecodingError = resultingError else {
            XCTFail("Must fail with JSON decoding error")
            return
        }
    }

    // TODO: Add more unit tests for various error code mapping
    // to cover the internals of the error mapping of NetworkService

}
// swiftlint:enable force_unwrapping

// MARK: - HTTP URL Protocol Test helper

private class URLProtocolMock: URLProtocol {

    static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data?))?

    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    override func startLoading() {
        guard let handler = URLProtocolMock.requestHandler else {
            assertionFailure("The handler is not provided!")
            return
        }

        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            if let data = data {
                client?.urlProtocol(self, didLoad: data)
            }
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {
        // nop
    }
}
