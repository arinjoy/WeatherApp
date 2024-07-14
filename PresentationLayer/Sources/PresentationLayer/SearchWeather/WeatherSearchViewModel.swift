import Foundation
import Combine
import DomainLayer
import DataLayer
import SharedUtils

//@MainActor
public class WeatherSearchViewModel: ObservableObject {

    // MARK: - Properties

    @Published private var searchQuery: String = ""

    @Published private(set) var loadingState: LoadingState = .idle

    private var useCase: WeatherUseCaseType

    private var cancellables: Set<AnyCancellable> = .init()

    // MARK: - Initializer

    public init(useCase: WeatherUseCaseType = WeatherUseCase()) {
        self.useCase = useCase
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
            loadingState = .idle
            return
        }

        loadingState = .loading

        useCase
            .fetchWeather(with: query)
            .receive(on: Scheduler.main)
            .delay(for: .seconds(0.5), scheduler: Scheduler.main)
            .sink { [unowned self] completion in
                if case .failure(let error) = completion {
                    loadingState = .failure(error)
                }
            } receiveValue: { [unowned self] result in
                loadingState = .success(result)
                print(result)
            }
            .store(in: &cancellables)
    }
}

enum LoadingState {
    case idle
    case loading
    case success(CityWeather)
    case failure(NetworkError)
}

extension LoadingState: Equatable {

    static func == (lhs: LoadingState, rhs: LoadingState) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle): return true
        case (.loading, .loading): return true
        case (.success(let lhs), .success(let rhs)): return lhs == rhs
        case (.failure, .failure): return true
        default: return false
        }
    }
}
