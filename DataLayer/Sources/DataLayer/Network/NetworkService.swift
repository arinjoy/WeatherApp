import Foundation
import Combine
import SharedUtils

final public class NetworkService: NetworkServiceType {

    private let session: URLSession

    public init(with configuration: URLSessionConfiguration) {
        self.session = URLSession(configuration: configuration)
    }

    @discardableResult
    public func load<T>(_ resource: Resource<T>) -> AnyPublisher<T, NetworkError> {

        guard let request = resource.request else {
            return .fail(NetworkError.unknown)
        }

        return URLSession.shared.dataTaskPublisher(for: request)
            .mapError { error in
                // 1. Check for network connection related error first
                return self.mapConnectivityError(error)
            }
            .tryMap { data, response  in

                // 2. If reponse came back, check if data exists via `HTTPURLResponse`
                guard let response = response as? HTTPURLResponse else {
                    throw NetworkError.noDataFound
                }

                // 3. If data exists, then check for negative/faliure HTTP status code
                // and map them to custom errors for potential custom handling
                guard 200..<300 ~= response.statusCode else {
                    throw self.mapHTTPStatusError(statusCode: response.statusCode)
                }

                // 4. If everyhting went well return the data response to be
                // decoded as JSON as next step
                return data
            }
            .decode(type: T.self, decoder: JSONDecoder())
            .map {
                // 5. JSON decoding is successful and return decoded entity/model
                return $0
            }
            .catch { error -> AnyPublisher<T, NetworkError> in

                // 6. If JSON decoding fails, from decode above (i.e. error came as non NetworkError)
                // return decoding error
                guard let networkError = error as? NetworkError else {
                    return .fail(NetworkError.jsonDecodingError(error: error))
                }

                // 7. Else, just pass the already mapped NetworkError
                return .fail(networkError)
            }
            .eraseToAnyPublisher()
    }

}

// MARK: - Custom Error Mapping Helpers

private extension NetworkService {

    /// Maps an HTTP negative status code into an custom error enum via `NetworkError`
    func mapHTTPStatusError(statusCode: Int) -> NetworkError {
        switch statusCode {
        case 401:
            return .unAuthorized
        case 403:
            return .forbidden
        case 404:
            return .notFound
        case 429:
            return .apiRateLimited
        case 503:
            return .serviceUnavailable
        case 500 ... 599:
            return .server
        default:
            return .unknown
        }
    }

    /// Maps an error from potential network connectivity related issues
    func mapConnectivityError(_ error: Error) -> NetworkError {
        let errorCode = (error as NSError).code

        if NSURLErrorConnectionFailureCodes.contains(errorCode) {
            return .networkFailure
        } else if errorCode == NSURLErrorTimedOut {
            return .timeout
        } else {
            return .unknown
        }
    }

    ///
    /// A collection of error codes that related to network connection failures.
    /// 🙏🏽 https://www.avanderlee.com/swift/optimizing-network-reachability/
    ///
    var NSURLErrorConnectionFailureCodes: [Int] {
        [
            NSURLErrorBackgroundSessionInUseByAnotherProcess,   /// Code: `-996`
            // NSURLErrorCannotFindHost,                        /// Code: `-1003`
            NSURLErrorCannotConnectToHost,                      /// Code: ` -1004`
            NSURLErrorNetworkConnectionLost,                    /// Code: ` -1005`
            NSURLErrorNotConnectedToInternet,                   /// Code: ` -1009`
            NSURLErrorSecureConnectionFailed,                   ///  Code: ` -1200`
        ]
    }
}


public extension Publisher {

    static func empty() -> AnyPublisher<Output, Failure> {
        return Empty().eraseToAnyPublisher()
    }

    static func just(_ output: Output) -> AnyPublisher<Output, Failure> {
        // By definition `Just` should never fail, but some syntax sugar has been
        // added to make it usable conveniently to avoid an Apple's warning
        return Just(output)
            .setFailureType(to: Failure.self)
            .catch { _ in AnyPublisher<Output, Failure>.empty() }
            .eraseToAnyPublisher()
    }

    static func fail(_ error: Failure) -> AnyPublisher<Output, Failure> {
        // By definition `Just` should never fail, but some syntax sugar has been
        // added to make it usable conveniently to avoid an Apple's warning
        return Fail(error: error).eraseToAnyPublisher()
    }
}

public extension Publisher {

    /**
     The flatMapLatest operator behaves much like the standard `flatMap` operator, except that whenever
     a new item is emitted by the source Publisher, it will unsubscribe to and stop mirroring the Publisher
     that was generated from the previously-emitted item, and begin only mirroring the current one.
     */
    func flatMapLatest<T: Publisher>(
        _ transform: @escaping (Self.Output) -> T
    ) -> Publishers.SwitchToLatest<T, Publishers.Map<Self, T>> where T.Failure == Self.Failure {
        map(transform).switchToLatest()
    }
}
