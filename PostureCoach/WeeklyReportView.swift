//
//  WeeklyReportView.swift
//  PostureCoach
//
//  Created by Youn on 2023/10/13.
//

import SwiftUI
import Charts

struct ExerciseReport: Identifiable {
    var type: String
    var count: Double
    var id = UUID()
}

var data: [ExerciseReport] = [
    .init(type: "월", count: 5),
    .init(type: "화", count: 4),
    .init(type: "수", count: 4),
    .init(type: "목", count: 4),
    .init(type: "금", count: 4),
    .init(type: "토", count: 4),
    .init(type: "일", count: 4),
]

struct WeeklyReportView: View {
    var body: some View {
        VStack{
            
        }
        Chart {
            BarMark(
                x: .value("월", data[0].type),
                y: .value("Total Count", data[0].count)
            )
            BarMark(
                 x: .value("화", data[1].type),
                 y: .value("Total Count", data[1].count)
            )
            BarMark(
                 x: .value("수", data[2].type),
                 y: .value("Total Count", data[2].count)
            )
            BarMark(
                 x: .value("목", data[3].type),
                 y: .value("Total Count", data[3].count)
            )
            BarMark(
                 x: .value("금", data[4].type),
                 y: .value("Total Count", data[4].count)
            )
            BarMark(
                 x: .value("토", data[5].type),
                 y: .value("Total Count", data[5].count)
            )
            BarMark(
                 x: .value("일", data[6].type),
                 y: .value("Total Count", data[6].count)
            )
            
            }
        }
}

struct WeeklyReportView_Previews: PreviewProvider {
    static var previews: some View {
        WeeklyReportView()
    }
}
