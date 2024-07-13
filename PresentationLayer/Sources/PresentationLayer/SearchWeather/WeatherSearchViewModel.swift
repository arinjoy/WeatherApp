import Foundation
import Combine
import DomainLayer
import DataLayer
import SharedUtils

@MainActor
public class WeatherSearchViewModel: ObservableObject {

    private var useCase: WeatherUseCase

    @Published var searchQuery: String = ""

    @Published var weatherSearchState: WeatherSearchState = .idle

    private var searchCancellable: AnyCancellable?

    // MARK: - Lifecycle

    public init() {
        useCase = WeatherUseCase()
    }

    deinit {
        searchCancellable?.cancel()
        searchCancellable = nil
    }

    // MARK: - API Methods

    func bindSearchQuery(_ query: String) {

        self.searchQuery = query

        searchCancellable?.cancel()

        let searchInput = $searchQuery
            .debounce(for: .milliseconds(300), scheduler: Scheduler.main)
            .removeDuplicates()

        searchCancellable = searchInput
            .filter { !$0.isEmpty }
            .setFailureType(to: NetworkError.self)
            .flatMapLatest { [unowned self] query in
                useCase.fetchWeather(with: query)
            }
            .receive(on: Scheduler.main)
            .sink { completion in
                if case .failure(let error) = completion {
                    self.weatherSearchState = .failure(error)
                }
            } receiveValue: { result in
                self.weatherSearchState = .success(result)
                print(result)
            }
    }
}

enum WeatherSearchState {
    case idle
    case searching
    case loading
    case success(CityWeather)
    case failure(NetworkError)
}

extension WeatherSearchState: Equatable {

    static func == (lhs: WeatherSearchState, rhs: WeatherSearchState) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle): return true
        case (.searching, .searching): return true
        case (.loading, .loading): return true
        case (.success(let lhs), .success(let rhs)): return lhs == rhs
        case (.failure, .failure): return true
        default: return false
        }
    }
}
