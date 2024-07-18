import SwiftUI

struct AddOffersView: View {
    @State private var showModal = false

    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Text("Offers")
                        .font(.system(size: 32, weight: .bold))
                    Spacer()
                    Button(action: {
                        showModal.toggle()
                    }) {
                        Image(systemName: "plus")
                            .font(.title)
                    }
                    .sheet(isPresented: $showModal) {
                        OfferView()
                    }
                }
                .padding()
                Spacer() // This pushes the content to the top
            }
            .navigationBarTitle("", displayMode: .inline)
            .navigationBarHidden(true)
        }
    }
}

struct AddOffersView_Previews: PreviewProvider {
    static var previews: some View {
        AddOffersView()
    }
}

// Separate file or further down in the same file

struct OfferView: View {
    @State private var showImagePicker = false
    @State private var selectedImage: UIImage?
    @State private var hyperlink: String = ""
    
    var body: some View {
        VStack(spacing: 25) {
            
            // Upload Image Section
            VStack(spacing: 10) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [5]))
                        .foregroundColor(.gray)
                        .frame(width: 380, height: 100)
                    
                    if let selectedImage = selectedImage {
                        Image(uiImage: selectedImage)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                            .cornerRadius(10)
                    }
                }
                //.padding([.leading, .trailing], 20)
                
                Button(action: {
                    self.showImagePicker = true
                }) {
                    Text("Upload Image")
                        .foregroundColor(.blue)
                }
            }
            .padding(.top, 5)
            .padding(.bottom, 10)
            .background(Color(UIColor.systemGray5))
            .cornerRadius(10)
            
            // Upload Hyperlink Section
            VStack(alignment: .leading, spacing: 15) {
                Text("Upload hyperlink")
                    .font(.headline)
                
                TextField("Upload the hyperlink for offers", text: $hyperlink)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            .padding([.leading, .trailing], 20)
            
            Spacer()
        }
        .padding(.top, 20) // Add padding at the top
        .navigationBarItems(trailing: Button("Done") {
            // Handle Done action
        })
        .sheet(isPresented: $showImagePicker) {
            ImagesPicker(image: self.$selectedImage)
        }
    }
}

struct OfferView_Previews: PreviewProvider {
    static var previews: some View {
        OfferView()
    }
}

// Separate file or further down in the same file

struct ImagesPicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagesPicker
        
        init(_ parent: ImagesPicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
            }
            
            picker.dismiss(animated: true)
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}
