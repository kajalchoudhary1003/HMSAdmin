//
//  Home.swift
//  HMSAdmin
//
//  Created by Kajal Choudhary on 04/07/24.
//

import SwiftUI

struct Home: View {
    @State private var currentDate: Date = .init()
    @State private var weekSlider: [[Date.WeekDay]] = []
    @State private var currentWeekIndex: Int = 1
    
    //animation namespace
    @Namespace private var animation
    var body: some View {
        VStack(alignment: .leading, spacing: 0,  content: {
            HeaderView()
        })
        .vSpacing(.top)
        .onAppear(
            perform: {
                if weekSlider.isEmpty{
                    let currentWeek = Date().fetchWeek()
                   
                    weekSlider.append(currentWeek)
                    if let lastDate = currentWeek.last?.date{
                        weekSlider.append(lastDate.createNextWeek())
                    }
                }
            })
    }
    
    @ViewBuilder
    func HeaderView() -> some View{
        VStack(alignment: .leading, spacing: 6){
            Text("Appointments")
                .font(.system(size: 32))
                .fontWeight(.semibold)
            
            TabView(selection: $currentWeekIndex){
                ForEach(weekSlider.indices, id: \.self){
                    index in
                    let week = weekSlider[index]
                    WeekView(week).tag(index)
                        .padding(.horizontal, 15)
                }
            }.tabViewStyle(.page(indexDisplayMode: .never))
                .frame(height: 90)
                .padding(.horizontal, -15)
        }
        .hSpacing(.leading)
        .overlay(alignment: .topTrailing, content: {
            Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/, label: {
                Image(systemName: "person.circle")
                    .resizable()
                    .foregroundColor(Color(hex: "#006666"))
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 45, height: 45)
            })
        })
        .padding(15)
        
    }
    
    @ViewBuilder
    func WeekView(_ week : [Date.WeekDay]) -> some View{
        HStack(spacing: 0){
            ForEach(week){
                day in
                VStack(spacing: 8){
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
                            if isSameDate(day.date, currentDate){
                                Circle().fill(Color(hex: "#006666"))
                                    .matchedGeometryEffect(id: "TABINDICATOR", in: animation)
                            }
                            
                            //indicator to show which is today's date
                            if day.date.isToday{
                                Circle()
                                    .fill(Color(hex: "#006666"))
                                    .frame(width: 5, height: 5)
                                    .vSpacing(.bottom)
                                    .offset(y:12)
                            }
                        })
                        .background(.white.shadow(.drop(radius: 1)), in: .circle)
                }
                .hSpacing(.center)
                .contentShape(.rect)
                .onTapGesture {
                    //updating current date
                    withAnimation(.snappy){
                        currentDate = day.date
                    }
                }
            }
        }
    }
}

#Preview {
    DoctorView()
}
