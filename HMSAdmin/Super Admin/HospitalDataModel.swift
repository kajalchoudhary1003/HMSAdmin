import Foundation

struct Hospital: Identifiable {
    let id = UUID()
    var name: String
    var address: String
    var city: String
    var country: String
    var zipCode: String
    var phone: String
    var email: String
    var type: String
    var admin: Admin?

    struct Admin {
        var name: String
        var email: String
        var phone: String
    }
}
