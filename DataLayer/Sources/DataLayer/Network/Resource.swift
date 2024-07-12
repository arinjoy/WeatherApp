import Foundation

public struct Resource<T: Decodable> {

    // MARK: - Properties

    let url: URL
    let parameters: [(String, CustomStringConvertible)]

    // MARK: - Initializer

    public init(
        url: URL,
        parameters: [(String, CustomStringConvertible)] = []
    ) {
        self.url = url
        self.parameters = parameters
    }

    // MARK: - Helper

    var request: URLRequest? {
        guard
            var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        else {
            return nil
        }

        components.queryItems = parameters.map { (key, value) in
            URLQueryItem(name: key, value: value.description)
        }

        guard let url = components.url else {
            return nil
        }

        return URLRequest(url: url)
    }

}
