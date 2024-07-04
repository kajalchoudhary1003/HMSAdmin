import Foundation

struct Hospital: Identifiable {
    let id = UUID()
    var name: String
    var address: String
    var phone: String
    var email: String
    var type: String
}
