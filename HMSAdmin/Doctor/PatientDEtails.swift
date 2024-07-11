import SwiftUI
import AVFoundation

struct PatientDetailsView: View {
    let patient: Patient
    @State private var prescriptionText = ""
    @State private var isShowingActionSheet = false
    @State private var isRecordingPathology = false
    @State private var isRecordingRadiology = false
    @State private var audioRecorder: AVAudioRecorder?
    @State private var pathologyAudioURLs: [URL] = []
    @State private var radiologyAudioURLs: [URL] = []
    @State private var audioPlayer: AVAudioPlayer?
    
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
                        .padding(.bottom, 10)
                        
                        // Medical Records
                        Section(header: Text("Medical Records").font(.headline).padding(.bottom, 20)) {
                            HStack {
                                Image(systemName: "doc.text")
                                Text("Pathology")
                                Spacer()
                                Button(action: {}) {
                                    Image(systemName: isRecordingPathology ? "mic.circle.fill" : "mic.circle")
                                        .resizable()
                                        .frame(width: 20, height: 20)
                                }
                                .simultaneousGesture(
                                    LongPressGesture(minimumDuration: 0.5)
                                        .onEnded { _ in
                                            if isRecordingPathology {
                                                stopRecording()
                                                isRecordingPathology = false
                                            } else {
                                                startRecording(fileName: "pathology.m4a")
                                                isRecordingPathology = true
                                            }
                                        }
                                )
                            }
                            ForEach(pathologyAudioURLs, id: \.self) { url in
                                HStack {
                                    Text(url.lastPathComponent)
                                    Spacer()
                                    Button(action: {
                                        playAudio(url: url)
                                    }) {
                                        Image(systemName: "play.circle")
                                            .resizable()
                                            .frame(width: 20, height: 20)
                                    }
                                }
                            }
                            HStack {
                                Image(systemName: "doc.text")
                                Text("Radiology")
                                Spacer()
                                Button(action: {}) {
                                    Image(systemName: isRecordingRadiology ? "mic.circle.fill" : "mic.circle")
                                        .resizable()
                                        .frame(width: 20, height: 20)
                                }
                                .simultaneousGesture(
                                    LongPressGesture(minimumDuration: 0.5)
                                        .onEnded { _ in
                                            if isRecordingRadiology {
                                                stopRecording()
                                                isRecordingRadiology = false
                                            } else {
                                                startRecording(fileName: "radiology.m4a")
                                                isRecordingRadiology = true
                                            }
                                        }
                                )
                            }
                            ForEach(radiologyAudioURLs, id: \.self) { url in
                                HStack {
                                    Text(url.lastPathComponent)
                                    Spacer()
                                    Button(action: {
                                        playAudio(url: url)
                                    }) {
                                        Image(systemName: "play.circle")
                                            .resizable()
                                            .frame(width: 20, height: 20)
                                    }
                                }
                            }
                        }
                        .padding(.bottom, -10)
                        
                        // Prescription Section
                        Section(header: Text("").padding(.bottom, -20)) {
                            TextField("Write Prescription...", text: $prescriptionText)
                                .padding(.bottom, 100)
                                .background(Color.white)
                        }
                    }
                    .background(Color.white)
                }
                .navigationBarTitle("Patient Details", displayMode: .inline)
            }
        }
    }

    func startRecording(fileName: String) {
        let audioFilename = getDocumentsDirectory().appendingPathComponent(fileName)
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder?.record()
        } catch {
            // Handle the error
        }
    }

    func stopRecording() {
        audioRecorder?.stop()
        if let url = audioRecorder?.url {
            if isRecordingPathology {
                pathologyAudioURLs.append(url)
            } else if isRecordingRadiology {
                radiologyAudioURLs.append(url)
            }
        }
        audioRecorder = nil
    }

    func playAudio(url: URL) {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
        } catch {
            // Handle the error
        }
    }

    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}

struct PatientDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        PatientDetailsView(patient: Patient(name: "Madhav Sharma", age: 21, type: "Regular", startTime: Date(), appointmentDate: Date()))
    }
}
