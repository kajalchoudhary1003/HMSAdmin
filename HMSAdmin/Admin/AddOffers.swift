import SwiftUI

struct AddOfferView: View {
    @State private var showImagePicker = false
    @State private var selectedImage: UIImage?
    @State private var hyperlink: String = ""
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Upload Image Section
                VStack(spacing: 10) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [5]))
                            .foregroundColor(.gray)
                            .frame(width: 300, height: 100)

                        if let selectedImage = selectedImage {
                            Image(uiImage: selectedImage)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 300, height: 100)
                                .cornerRadius(10)
                        }
                    }
                    .padding([.leading, .trailing], 20)

                    Button(action: {
                        self.showImagePicker = true
                    }) {
                        Text("Upload Image")
                            .foregroundColor(.blue)
                    }
                }
                .padding()
                .background(Color(UIColor.systemGray6))
                .cornerRadius(10)
                .padding([.leading, .trailing], 20)

                // Upload Hyperlink Section
                VStack(alignment: .leading, spacing: 5) {
                    Text("Upload hyperlink")
                        .font(.headline)

                    TextField("Upload the hyperlink for offers...", text: $hyperlink)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                .padding([.leading, .trailing], 20)

                Spacer()
            }
            .background(Color.customBackground)
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(image: self.$selectedImage)
            }
        }
    }
}

struct ImagePicker: UIViewControllerRepresentable {
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
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
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

struct AddOfferView_Previews: PreviewProvider {
    static var previews: some View {
        AddOfferView()
    }
}

