import SwiftUI
import AVFoundation

struct PatientDetailsView: View {
    let patient: Patient
    @State private var prescriptionText = ""
    @State private var isShowingActionSheet = false
    
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
                        Section(header: Text("")) {
                            HStack {
                                Text("First Name")
                                Spacer()
                                Text(patient.name.split(separator: " ").first ?? "")
                                    .foregroundColor(.gray)
                            }
                            HStack {
                                Text("Last Name")
                                Spacer()
                                Text(patient.name.split(separator: " ").last ?? "")
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
                        
                        // Prescription Section
                        Section(header: Text("")) {
                            ZStack(alignment: .bottomTrailing) {
                                TextField("Write Prescription...", text: $prescriptionText)
                                    .padding(.bottom, 100)
                                    .background(Color.white)
                                Button(action: {
                                    // Handle microphone action
                                }) {
                                    Image(systemName: "mic.circle.fill")
                                        .resizable()
                                        .frame(width: 30, height: 30)
                                        .padding()
                                }
                                .padding(.bottom, 8)
                                .padding(.trailing, 8)
                            }
                        }
                        
                        // Medical Reports
                        Section(header: Text("")) {
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
                    }
                    .background(Color.white)
                }
                .navigationBarTitle("Patient Details", displayMode: .inline)
            }
        }
    }
}

struct PatientDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        PatientDetailsView(patient: Patient(name: "Madhav Sharma", age: 21, type: "Regular", startTime: Date(), appointmentDate: Date()))
    }
}

