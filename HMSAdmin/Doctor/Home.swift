import SwiftUI
import Firebase

struct PatientRow: View {
    let patient: Patient
    let appointment: Appointment
    var body: some View {
        NavigationLink(destination: PatientDetailsView(patient: patient)) {
            VStack {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(patient.firstName) \(patient.lastName)")
                            .font(.headline)
                            .foregroundColor(.black)
                        Text("Blood Group: \(patient.bloodGroup)")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        Text("Gender: \(patient.gender)")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                    VStack(alignment: .trailing) {
                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray)
                        Text(formatDate(appointment.date))
                            .font(.headline)
                            .foregroundColor(Color(hex: "#006666"))
                            .padding(.top, 10)
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(8)
                .shadow(color: .gray.opacity(0.1), radius: 4, x: 0, y: 2)
            }
            .padding(.horizontal)
        }
    }
}

struct Home: View {
        @State private var currentDate: Date = .init()
        @State private var weekSlider: [[Date.WeekDay]] = []
        @State private var currentWeekIndex: Int = 1
        @State private var isProfileSheetPresented = false
        @State private var currentDoctorID: String = Auth.auth().currentUser!.uid
        @Namespace private var animation
    
    var body: some View {
            NavigationView {
                ZStack {
                    Color(uiColor: .systemGray6)
                        .ignoresSafeArea()
                    
                    VStack(alignment: .leading, spacing: 0) {
                        HeaderView()
                        ScrollView {
                            HStack {
                                Text("Active:")
                                    .padding(.trailing, 250)
                                    .fontWeight(.bold)
                                Text("\(todaysAppointments.count)/\(DataController.shared.appointments.count)")
                            }
                            .padding(.bottom, 20)
                            .padding(.horizontal)
                            
                            ForEach(todaysAppointments) { appointment in
                                if let patient = DataController.shared.patients[appointment.patientID] {
                                    PatientRow(patient: patient, appointment: appointment)
                                }
                            }
                        }
                    }
                }
                .vSpacing(.top)
                .onAppear {
                    DataController.shared.fetchAppointmentsById(for: currentDoctorID)
                    print("current user \(currentDoctorID)")
                    if weekSlider.isEmpty {
                        let currentWeek = Date().fetchWeek()
                        weekSlider.append(currentWeek)
                        if let lastDate = currentWeek.last?.date {
                            weekSlider.append(lastDate.createNextWeek())
                        }
                    }
                }
            }
        }
        var doctorAppointments: [Appointment] {
            DataController.shared.appointments.filter { $0.doctorID == currentDoctorID }
        }
        
        var todaysAppointments: [Appointment] {
            DataController.shared.appointments.filter { Calendar.current.isDate($0.date, inSameDayAs: currentDate) }
        }

    
    @ViewBuilder
    func HeaderView() -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Appointments")
                .font(.system(size: 32))
                .fontWeight(.semibold)
            
            TabView(selection: $currentWeekIndex) {
                ForEach(weekSlider.indices, id: \.self) { index in
                    let week = weekSlider[index]
                    WeekView(week).tag(index)
                        .padding(.horizontal, 15)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(height: 90)
            .padding(.horizontal, -15)
        }
        .hSpacing(.leading)
        .overlay(alignment: .topTrailing) {
            Button(action: {
                // Show profile screen modally
                isProfileSheetPresented = true
            }) {
                Image(systemName: "person.circle")
                    .resizable()
                    .foregroundColor(Color(hex: "#006666"))
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 45, height: 45)
            }
            .sheet(isPresented: $isProfileSheetPresented) {
                ProfileView()
            }
        }
        .padding(15)
    }
    
    @ViewBuilder
    func WeekView(_ week: [Date.WeekDay]) -> some View {
        HStack(spacing: 0) {
            ForEach(week) { day in
                VStack(spacing: 8) {
                    Text(day.date.format("E"))
                        .font(.callout)
                        .fontWeight(.medium)
                        .textScale(.secondary)
                        .foregroundStyle(.gray)
                    
                    Text(day.date.format("dd"))
                        .font(.callout)
                        .fontWeight(.medium)
                        .textScale(.secondary)
                        .foregroundStyle(isSameDate(day.date, currentDate) ? .white : .gray)
                        .frame(width: 35, height: 35)
                        .background(content: {
                            if isSameDate(day.date, currentDate) {
                                Circle().fill(Color(hex: "#006666"))
                                    .matchedGeometryEffect(id: "TABINDICATOR", in: animation)
                            }
                            
                            if day.date.isToday {
                                Circle()
                                    .fill(Color(hex: "#006666"))
                                    .frame(width: 5, height: 5)
                                    .vSpacing(.bottom)
                                    .offset(y: 12)
                            }
                        })
                        .background(.white.shadow(.drop(radius: 1)), in: .circle)
                }
                .hSpacing(.center)
                .contentShape(.rect)
                .onTapGesture {
                    withAnimation(.snappy) {
                        currentDate = day.date
                    }
                }
            }
        }
    }
}
func formatDate(_ date: Date) -> String {
       let formatter = DateFormatter()
       formatter.dateStyle = .medium
       return formatter.string(from: date)
   }
struct Home_Previews: PreviewProvider {
    static var previews: some View {
        Home()
    }
}
