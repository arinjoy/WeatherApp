import Foundation
import Combine
import DomainLayer
import DataLayer
import SharedUtils

public class WeatherSearchViewModel: ObservableObject {

    // MARK: - Properties

    @Published private var searchQuery: String = ""

    @Published private(set) var loadingState: LoadingState = .idle

    private var useCase: WeatherUseCaseType

    private var cancellables: Set<AnyCancellable> = .init()

    // MARK: - Types

    enum LoadingState {
        case idle
        case loading
        case success(WeatherPresentationItem)
        case failure(NetworkError)
    }

    // MARK: - Initializer

    public init(useCase: WeatherUseCaseType = WeatherUseCase()) {
        self.useCase = useCase
        bindSearch()
    }

    // MARK: - String copies

    // TODO: ✋🏼
    // Move these copies into some form of localisation framework or SwiftGen
    // so that all copies can be placed in centralised strings files and
    // can be unit tested

    var greetingMessage: String { "Search weather by city name or postcode" }
    var searchBarPlaceholder: String { "Search for a city" }
    var recentSearchesHeaderText: String { "Recent Searches" }

    // MARK: - API Methods

    func updateSearchQuery(_ query: String) {
        searchQuery = query
    }
}

// MARK: - Private

private extension WeatherSearchViewModel {

    private func bindSearch() {
        let searchInput = $searchQuery
            .debounce(for: .milliseconds(500), scheduler: Scheduler.main)
            .removeDuplicates()

        searchInput
            .sink(receiveValue: { [unowned self] query in
                updateSearchState(from: query)
            })
            .store(in: &cancellables)
    }

    private func updateSearchState(from query: String) {

        guard query.trimmed().isEmpty == false else {
            loadingState = .idle
            return
        }

        loadingState = .loading

        useCase
            .fetchWeather(with: query)
            .receive(on: Scheduler.main)
            // TODO: 
            // Extra delay added for testing and visualisation only.
            // Should be removed in production code.
            .delay(for: .seconds(0.5), scheduler: Scheduler.main)
            .sink { [unowned self] completion in
                if case .failure(let error) = completion {
                    loadingState = .failure(error)
                }
            } receiveValue: { [unowned self] weather in
                loadingState = .success(WeatherPresentationItem(weather))
            }
            .store(in: &cancellables)
    }
}

extension WeatherSearchViewModel.LoadingState: Equatable {

    static func == (
        lhs: WeatherSearchViewModel.LoadingState, rhs: WeatherSearchViewModel.LoadingState
    ) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle): return true
        case (.loading, .loading): return true
        case (.success(let lhs), .success(let rhs)): return lhs == rhs
        case (.failure, .failure): return true
        default: return false
        }
    }
}
