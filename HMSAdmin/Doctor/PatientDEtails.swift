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
    @State private var recordingDuration: TimeInterval = 0
    @State private var recordingTimer: Timer?

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
                        Section(header: Text("Patient Information").padding(.bottom, -20)) {
                            HStack {
                                Text("First Name")
                                Spacer()
                                Text(patient.firstName)
                                    .foregroundColor(.gray)
                            }
                            HStack {
                                Text("Last Name")
                                Spacer()
                                Text(patient.lastName)
                                    .foregroundColor(.gray)
                            }
                            HStack {
                                Text("Blood Group")
                                Spacer()
                                Text(patient.bloodGroup)
                                    .foregroundColor(.gray)
                            }
                            HStack {
                                Text("Gender")
                                Spacer()
                                Text(patient.gender)
                                    .foregroundColor(.gray)
                            }
                            HStack {
                                Text("Date of Birth")
                                Spacer()
                                Text(formatDate(patient.dateOfBirth))
                                    .foregroundColor(.gray)
                            }
                            HStack {
                                Text("Emergency Phone")
                                Spacer()
                                Text(patient.emergencyPhone)
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(.bottom, -10)
                        
                        Section(header: Text("Medical Records").font(.headline).padding(.bottom, 20)) {
                            // Pathology Recording
                            HStack {
                                Image(systemName: "doc.text")
                                Text("Pathology")
                                Spacer()
                                VStack {
                                    Button(action: {
                                        if isRecordingPathology {
                                            stopRecording(isPathology: true)
                                        } else {
                                            startRecording(fileName: "pathology.m4a")
                                            isRecordingPathology = true
                                            startTimer()
                                        }
                                    }) {
                                        Image(systemName: isRecordingPathology ? "stop.circle.fill" : "mic.circle")
                                            .resizable()
                                            .frame(width: 20, height: 20)
                                    }
                                    if isRecordingPathology {
                                        Text("\(Int(recordingDuration))s")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                }
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
                                .contextMenu {
                                    Button(action: {
                                        deleteRecording(url: url, isPathology: true)
                                    }) {
                                        Text("Delete")
                                        Image(systemName: "trash")
                                    }
                                }
                            }
                            
                            // Radiology Recording
                            HStack {
                                Image(systemName: "doc.text")
                                Text("Radiology")
                                Spacer()
                                VStack {
                                    Button(action: {
                                        if isRecordingRadiology {
                                            stopRecording(isPathology: false)
                                        } else {
                                            startRecording(fileName: "radiology.m4a")
                                            isRecordingRadiology = true
                                            startTimer()
                                        }
                                    }) {
                                        Image(systemName: isRecordingRadiology ? "stop.circle.fill" : "mic.circle")
                                            .resizable()
                                            .frame(width: 20, height: 20)
                                    }
                                    if isRecordingRadiology {
                                        Text("\(Int(recordingDuration))s")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                }
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
                                .contextMenu {
                                    Button(action: {
                                        deleteRecording(url: url, isPathology: false)
                                    }) {
                                        Text("Delete")
                                        Image(systemName: "trash")
                                    }
                                }
                            }
                        }
                        .padding(.bottom, -10)
                        
                        // Prescription Section
                        Section(header: Text("Prescription").padding(.bottom, -20)) {
                            TextField("Write Prescription...", text: $prescriptionText)
                                .padding(.bottom, 100)
                                .background(Color.white)
                        }
                    }
                    .background(Color.white)
                }
            }
            .navigationBarTitle("Patient Details", displayMode: .inline)
            .onAppear {
                configureAudioSession()
                loadMedicalRecords()
                loadPrescriptions()
            }
        }
    }

    func configureAudioSession() {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
            try session.setActive(true)
        } catch {
            print("Error setting up audio session: \(error.localizedDescription)")
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
            recordingDuration = 0
        } catch {
            print("Error starting recording: \(error.localizedDescription)")
        }
    }

    func stopRecording(isPathology: Bool) {
        audioRecorder?.stop()
        if let url = audioRecorder?.url {
            if isPathology {
                pathologyAudioURLs.append(url)
            } else {
                radiologyAudioURLs.append(url)
            }
        }
        audioRecorder = nil
        recordingDuration = 0
        recordingTimer?.invalidate()
        recordingTimer = nil
        isRecordingPathology = false
        isRecordingRadiology = false
    }

    func playAudio(url: URL) {
        do {
            if audioPlayer?.isPlaying == true {
                audioPlayer?.stop()
            }
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
        } catch {
            print("Error playing audio: \(error.localizedDescription)")
        }
    }

    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }

    func startTimer() {
        recordingTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            recordingDuration += 1
        }
    }

    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }

    func loadMedicalRecords() {
        // Fetch medical records from your data source and update pathologyAudioURLs and radiologyAudioURLs
        // For example:
        // pathologyAudioURLs = fetchedPathologyURLs
        // radiologyAudioURLs = fetchedRadiologyURLs
    }

    func loadPrescriptions() {
        // Fetch the prescription text from your data source and update prescriptionText
        // For example:
        // prescriptionText = fetchedPrescriptionText
    }

    func deleteRecording(url: URL, isPathology: Bool) {
        do {
            try FileManager.default.removeItem(at: url)
            if isPathology {
                pathologyAudioURLs.removeAll { $0 == url }
            } else {
                radiologyAudioURLs.removeAll { $0 == url }
            }
        } catch {
            print("Error deleting recording: \(error.localizedDescription)")
        }
    }
}
