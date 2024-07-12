import Foundation

public struct City: Decodable {

    public let identifier: Int?
    public let name: String?
    public let coordinate: Coordinate?
    public let country: String?

    private enum CodingKeys: String, CodingKey {
        case identifier = "id"
        case name = "name"
        case coordinate = "coord"
        case country = "country"
    }
}

public struct Coordinate: Decodable {

    public let longitude: Double?
    public let latitude: Double?

    private enum CodingKeys: String, CodingKey {
        case longitude = "lon"
        case latitude = "lat"
    }
}
