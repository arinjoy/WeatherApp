import XCTest
import Combine
@testable import DataLayer
@testable import DomainLayer
@testable import PresentationLayer

final class WeatherSearchViewModelTests: XCTestCase {

    // MARK: - Properties

    private var testSubject: WeatherSearchViewModel!

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Lifecycle

    override func setUp() {
        super.setUp()
        testSubject = WeatherSearchViewModel(useCase: WeatherUseCaseMock())
    }

    override func tearDown() {
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
        testSubject = nil
        super.tearDown()
    }

    // MARK: - Tests

    func testIntialIdleState() {
        XCTAssertEqual(testSubject.loadingState, .idle)
    }

    func testSearchEmptyString() {

        // WHEN - search text is typed as empty white space only
        testSubject.updateSearchQuery("   ")

        // THEN - viewModel's state should remain as `idle` state
        XCTAssertEqual(testSubject.loadingState, .idle)
    }

    func testSearchCallsUseCase() {

        let expectation = expectation(description: "Weather must be loaded from useCase")

        let useCaseSpy = WeatherUseCaseSpy()

        // GIVEN - viewModel is configured with useCase spy
        testSubject = .init(useCase: useCaseSpy)

        // WHEN - city keyword is being searched
        testSubject.updateSearchQuery("Mel")

        testSubject.$loadingState.dropFirst().sink { _ in
            expectation.fulfill()
        }
        .store(in: &cancellables)

        waitForExpectations(timeout: 1.0, handler: nil)

        // THEN - useCase's method is being called
        XCTAssertTrue(useCaseSpy.fetchWeatherCalled)
    }

    func testSearchTriggersLoadingState() {

        let expectation = expectation(description: "Weather is going to be loaded from useCase")

        // WHEN - city keyword is being searched
        testSubject.updateSearchQuery("Mel")

        testSubject.$loadingState.dropFirst(1).sink { _ in
            expectation.fulfill()
        }
        .store(in: &cancellables)

        waitForExpectations(timeout: 1.0, handler: nil)

        // THEN - viewModel's state should become `loading`
        XCTAssertEqual(testSubject.loadingState, .loading)
    }

    func testSearchSuccessfulAfterLoading() {

        let expectation = expectation(description: "Weather must be loaded from useCase")

        // WHEN - city keyword is being searched
        testSubject.updateSearchQuery("Melbourne")

        testSubject.$loadingState.dropFirst(2).sink { _ in
            expectation.fulfill()
        }
        .store(in: &cancellables)

        waitForExpectations(timeout: 2.0, handler: nil)

        // THEN - viewModel's state should become `success`
        switch testSubject.loadingState {
        case .success(let item):
            // AND retuned associated item is the same as provided by useCase
            XCTAssertEqual(item, WeatherUseCaseMock.sampleData)
        default:
            XCTFail("Loading state must become `success`")
        }
    }

    func testSearchFailureAfterLoading() {

        let expectation = expectation(description: "Weather must be loaded from useCase")

        // GIVEN - useCase is configured to return an error
        testSubject = .init(useCase: WeatherUseCaseMock(returningError: true, error: .notFound))

        // WHEN - city keyword is being searched
        testSubject.updateSearchQuery("random")

        testSubject.$loadingState.dropFirst(2).sink { _ in
            expectation.fulfill()
        }
        .store(in: &cancellables)

        waitForExpectations(timeout: 2.0, handler: nil)

        // THEN - viewModel's state should become `success`
        switch testSubject.loadingState {
        case .failure(let error):
            // AND - retuned associated error is same as returned by useCase
            XCTAssertEqual(error, .notFound)
        default:
            XCTFail("Loading state must become `failure`")
        }
    }

}
