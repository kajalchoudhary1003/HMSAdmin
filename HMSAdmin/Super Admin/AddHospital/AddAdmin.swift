import SwiftUI

struct AddAdminView: View {
    @Binding var newAdmin: Admin
    var onSave: (Admin) -> Void
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Admin Details")) {
                    TextField("First Name", text: $newAdmin.name)
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
