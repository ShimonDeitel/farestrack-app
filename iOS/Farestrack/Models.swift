import Foundation

struct FareItem: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var provider: String
    var amount: Double
    var purpose: String
    var dateAdded: Date = Date()
}
