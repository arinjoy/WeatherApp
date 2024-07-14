import Foundation
import Combine
import DomainLayer
import DataLayer
import SharedUtils

@MainActor
public class WeatherSearchViewModel: ObservableObject {

    // MARK: - Properties

    @Published private var searchQuery: String = ""

    @Published private(set) var weatherSearchState: WeatherSearchState = .idle

    private var useCase: WeatherUseCase

    private var cancellables: Set<AnyCancellable> = .init()

    // MARK: - Initializer

    public init() {
        useCase = WeatherUseCase()
        bindSearch()
    }

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
            weatherSearchState = .idle
            return
        }

        weatherSearchState = .loading

        useCase
            .fetchWeather(with: query)
            .receive(on: Scheduler.main)
            .delay(for: .seconds(0.5), scheduler: Scheduler.main)
            .sink { [unowned self] completion in
                if case .failure(let error) = completion {
                    weatherSearchState = .failure(error)
                }
            } receiveValue: { [unowned self] result in
                weatherSearchState = .success(result)
                print(result)
            }
            .store(in: &cancellables)
    }
}

enum WeatherSearchState {
    case idle
    case loading
    case success(CityWeather)
    case failure(NetworkError)
}

extension WeatherSearchState: Equatable {

    static func == (lhs: WeatherSearchState, rhs: WeatherSearchState) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle): return true
        case (.loading, .loading): return true
        case (.success(let lhs), .success(let rhs)): return lhs == rhs
        case (.failure, .failure): return true
        default: return false
        }
    }
}
