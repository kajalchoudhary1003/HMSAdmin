import SwiftUI

struct AdminPickerView: View {
    var existingAdmins: [String]
    @Binding var selectedAdminIndex: Int
    @Environment(\.presentationMode) var presentationMode
    @State private var searchText = ""
    
    var filteredAdmins: [String] {
        if searchText.isEmpty {
            return existingAdmins
        } else {
            return existingAdmins.filter { $0.lowercased().contains(searchText.lowercased()) }
        }
    }
    
    var groupedAdmins: [String: [String]] {
        Dictionary(grouping: filteredAdmins) { String($0.prefix(1)).uppercased() }
    }
    
    var sortedKeys: [String] {
        groupedAdmins.keys.sorted()
    }
    
    var body: some View {
            List {
                ForEach(sortedKeys, id: \.self) { key in
                    Section(header: Text(key)) {
                        ForEach(groupedAdmins[key]!, id: \.self) { admin in
                            Button(action: {
                                if let index = existingAdmins.firstIndex(of: admin) {
                                    selectedAdminIndex = index
                                    presentationMode.wrappedValue.dismiss()  // Dismiss the view on selection
                                }
                            }) {
                                HStack {
                                    Text(admin)
                                    if selectedAdminIndex == existingAdmins.firstIndex(of: admin) {
                                        Spacer()
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .listStyle(GroupedListStyle()) // Use GroupedListStyle to remove extra spacing
            .navigationTitle("Select Admin")
            .searchable(text: $searchText, prompt: "Search Admin")
        }
}

struct AdminPickerView_Previews: PreviewProvider {
    static var previews: some View {
        AdminPickerView(existingAdmins: ["Ansh", "Madhav", "John", "Jane", "Michael", "Emily", "David", "Sarah", "Robert"], selectedAdminIndex: .constant(0))
    }
}
