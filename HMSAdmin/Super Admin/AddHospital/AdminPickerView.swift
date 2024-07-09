import SwiftUI

struct AdminPickerView: View {
    @Binding var existingAdmins: [String] // List of existing admin names
    @Binding var selectedAdminIndex: Int
    @Environment(\.presentationMode) var presentationMode
    @State private var searchText = ""
    
    // Computed property to filter admins based on search text
    var filteredAdmins: [String] {
        if searchText.isEmpty {
            return existingAdmins
        } else {
            return existingAdmins.filter { $0.lowercased().contains(searchText.lowercased()) }
        }
    }
    
    // Computed property to group admins by the first letter
    var groupedAdmins: [String: [String]] {
        Dictionary(grouping: filteredAdmins) { String($0.prefix(1)).uppercased() }
    }
    
    // Computed property to get sorted keys for sections
    var sortedKeys: [String] {
        groupedAdmins.keys.sorted()
    }
    
    var body: some View {
        List {
            // Loop through sorted keys to create sections
            ForEach(sortedKeys, id: \.self) { key in
                Section(header: Text(key)) {
                    // Loop through admins in each section
                    ForEach(groupedAdmins[key]!, id: \.self) { admin in
                        Button(action: {
                            if let index = existingAdmins.firstIndex(of: admin) {
                                selectedAdminIndex = index // Update selected admin index
                                presentationMode.wrappedValue.dismiss()  // Dismiss the view on selection
                            }
                        }) {
                            HStack {
                                Text(admin)
                                // Show checkmark if the admin is selected
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

