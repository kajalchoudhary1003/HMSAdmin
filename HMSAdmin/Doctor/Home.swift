import SwiftUI

struct Patient: Identifiable {
    let id = UUID()
    let name: String
    let age: Int
    let type: String
    let startTime: Date
    let appointmentDate: Date
    
    var endTime: Date {
        Calendar.current.date(byAdding: .minute, value: 15, to: startTime)!
    }
}

struct PatientRow: View {
    let patient: Patient
    
    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(patient.name)
                        .font(.headline)
                        .foregroundColor(.black)
                    Text("Type: \(patient.type)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    Text("Age: \(patient.age)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                Spacer()
                VStack(alignment: .trailing) {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                    Text(timeRangeString)
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
    
    private var timeRangeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        let startString = formatter.string(from: patient.startTime)
        let endString = formatter.string(from: patient.endTime)
        return "\(startString) - \(endString)"
    }
}

struct Home: View {
    @State private var currentDate: Date = .init()
    @State private var weekSlider: [[Date.WeekDay]] = []
    @State private var currentWeekIndex: Int = 1
    
    @State private var patients: [Patient] = [
        Patient(name: "John Doe", age: 30, type: "Regular", startTime: Calendar.current.date(bySettingHour: 10, minute: 0, second: 0, of: Date())!, appointmentDate: Date().addingTimeInterval(86400)),
        Patient(name: "Jane Smith", age: 25, type: "Urgent", startTime: Calendar.current.date(bySettingHour: 10, minute: 15, second: 0, of: Date())!, appointmentDate: Date()),
        Patient(name: "Mark Johnson", age: 40, type: "Consultation", startTime: Calendar.current.date(bySettingHour: 10, minute: 30, second: 0, of: Date())!, appointmentDate: Date()),
        Patient(name: "Emily Brown", age: 35, type: "Follow-up", startTime: Calendar.current.date(bySettingHour: 10, minute: 45, second: 0, of: Date())!, appointmentDate: Date()),
        Patient(name: "Michael Lee", age: 50, type: "Regular", startTime: Calendar.current.date(bySettingHour: 11, minute: 0, second: 0, of: Date())!, appointmentDate: Date())
    ]
    
    @Namespace private var animation
    
    var body: some View {
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
                        Text("\(todaysPatients.count)/\(patients.count)")
                    }
                    .padding(.bottom, 20)
                    .padding(.horizontal)
                    
                    ForEach(todaysPatients.sorted { $0.startTime < $1.startTime }) { patient in
                        PatientRow(patient: patient)
                    }
                }
            }
        }
        .vSpacing(.top)
        .onAppear {
            if weekSlider.isEmpty {
                let currentWeek = Date().fetchWeek()
                weekSlider.append(currentWeek)
                if let lastDate = currentWeek.last?.date {
                    weekSlider.append(lastDate.createNextWeek())
                }
            }
        }
    }
    
    var todaysPatients: [Patient] {
        patients.filter { Calendar.current.isDate($0.appointmentDate, inSameDayAs: currentDate) }
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
            Button(action: {}, label: {
                Image(systemName: "person.circle")
                    .resizable()
                    .foregroundColor(Color(hex: "#006666"))
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 45, height: 45)
            })
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

#Preview {
    Home()
}

