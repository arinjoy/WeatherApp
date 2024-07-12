import Foundation

/// Can provide misc services such as - network data loading, local file data loading, image loading, core-data/caching
/// For now there is only service of `NetworkServiceType` which does HTTP based data loading
public class ServicesProvider {

    /// The underlying network service to load HTTP network based data
    public let network: NetworkServiceType

    init(network: NetworkServiceType) {
        self.network = network
    }

    /// The default provider used for production code to fetch from remote
    public static func defaultProvider() -> ServicesProvider {
        let sessionConfig = URLSessionConfiguration.ephemeral

        // Set 10 seconds timeout for the request,
        // otherwise defaults to 60 seconds which is too long.
        // This helps in network disconnection and error testing.
        sessionConfig.timeoutIntervalForRequest = 5
        sessionConfig.waitsForConnectivity = true
        sessionConfig.allowsConstrainedNetworkAccess = true
        sessionConfig.allowsExpensiveNetworkAccess = true

        let network = NetworkService(with: sessionConfig)

        return ServicesProvider(network: network)
    }

}
