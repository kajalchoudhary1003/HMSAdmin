import SwiftUI
import AVFoundation

struct PatientDetailsView: View {
    let patient: Patient
    @State private var prescriptionText = ""
    @State private var isShowingActionSheet = false
    @ObservedObject private var speechRecognizer = SpeechRecognizer()
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGray6)
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    // Profile Picture with Edit Button
                    ZStack(alignment: .topTrailing) {
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                            .padding(.top)
                    }
                    .actionSheet(isPresented: $isShowingActionSheet) {
                        ActionSheet(title: Text("Profile Options"), buttons: [
                            .default(Text("View Profile")) {
                                // Handle view profile action
                            },
                            .default(Text("Change Picture")) {
                                // Handle change picture action
                            },
                            .cancel()
                        ])
                    }
                    
                    Form {
                        // Patient Information
                        Section(header: Text("").padding(.bottom, -20)) {
                            HStack {
                                Text("First Name")
                                Spacer()
                                Text(patient.firstName.split(separator: " ").first ?? "")
                                    .foregroundColor(.gray)
                            }
                            HStack {
                                Text("Last Name")
                                Spacer()
                                Text(patient.lastName.split(separator: " ").last ?? "")
                                    .foregroundColor(.gray)
                            }
                            HStack {
                                Text("Age")
                                Spacer()
                                Text("\(patient.age)")
                                    .foregroundColor(.gray)
                            }
                            HStack {
                                Text("Type")
                                Spacer()
                                Text(patient.type)
                                    .foregroundColor(.gray)
                            }
                            HStack {
                                Text("Appointment Date")
                                Spacer()
                                Text(patient.appointmentDate, style: .date)
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding(.bottom, -10)
                        
                        // Medical Reports
                        Section(header: Text("").padding(.bottom, -20)) {
                            HStack {
                                Image(systemName: "pdf")
                                Text("Pathology")
                                Spacer()
                                Text("440 Kbs")
                                    .foregroundColor(.gray)
                            }
                            HStack {
                                Image(systemName: "pdf")
                                Text("Radiology")
                                Spacer()
                                Text("440 Kbs")
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(.bottom, -10)
                        
                        // Prescription Section
                        Section(header: Text("").padding(.bottom, -20)) {
                            ZStack(alignment: .bottomTrailing) {
                                TextField("Write Prescription...", text: $prescriptionText)
                                    .padding(.bottom, 100)
                                    .background(Color.white)
                                Button(action: {
                                    if speechRecognizer.isRunning {
                                        speechRecognizer.stopRecording()
                                    } else {
                                        speechRecognizer.startRecording()
                                    }
                                }) {
                                    Image(systemName: speechRecognizer.isRunning ? "mic.circle.fill" : "mic.circle")
                                        .resizable()
                                        .frame(width: 30, height: 30)
                                        .padding(.top,50)
                                        .padding(.leading,1)
                                        
                                }
                                .padding(.bottom, 8)
                                .padding(.trailing, 8)
                            }
                            .onChange(of: speechRecognizer.recognizedText) { newValue in
                                prescriptionText = newValue
                            }
                        }
                    }
                    .background(Color.white)
                }
                .navigationBarTitle("Patient Details", displayMode: .inline)
            }
        }
    }
}

//struct PatientDetailsView_Previews: PreviewProvider {
//    static var previews: some View {
//        PatientDetailsView(patient: Patient(name: "Madhav Sharma", age: 21, type: "Regular", startTime: Date(), appointmentDate: Date()))
//    }
//}

