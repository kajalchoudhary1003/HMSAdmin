import SwiftUI

struct AddAdminView: View {
    @Binding var newAdmin: AdminProfile
    var onSave: (AdminProfile) -> Void
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Admin Details")) {
                    TextField("First Name", text: $newAdmin.firstName)
                    TextField("Last Name", text: $newAdmin.lastName)
                    TextField("Email", text: $newAdmin.email)
                    TextField("Phone", text: $newAdmin.phone)
                }
            }
            .navigationBarTitle("Add Admin", displayMode: .inline)
            .navigationBarItems(leading: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            }, trailing: Button("Save") {
                onSave(newAdmin)
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}
