import Foundation
import SwiftUI
import SwiftData

@Model
final public class SearchLocation {

    @Attribute(.unique)
    public let id: String
    public let name: String
    public let timeStamp: Date

    init(id: String, name: String, timeStamp: Date) {
        self.id = id
        self.name = name
        self.timeStamp = timeStamp
    }
}
