import Foundation

struct Hospital: Identifiable, Codable {
    var id: String = UUID().uuidString
    var name: String
    var address: String
    var phone: String
    var email: String
    var type: String
}
