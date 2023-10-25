//
//  WeeklyReportView.swift
//  PostureCoach
//
//  Created by Youn on 2023/10/13.
//

import Charts
import SwiftUI
import Alamofire

struct WeeklyReport: Identifiable, Codable {
    let userId: String
    let machineName: String
    let weekday: String
    let counts: Int
    
    var id: String { weekday }
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case machineName = "machine_name"
        case weekday = "exercise_date"
        case counts = "exercise_count"
    }
}

struct WeeklySum: Codable {
    let userId: String
    let machineName: String
    let count: Int
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case machineName = "machine_name"
        case count = "exercise_count"
    }
}

class ReportModel: ObservableObject {
    @Published var weeklyReports: [WeeklyReport] = []
    
    init() {
        getReports()
    }
    
    func getReports() {
        if let loggedInUserId = UserDefaults.standard.string(forKey: "loggedInUserId") {
                let url = "https://pcoachapi.azurewebsites.net/api/report/weekly?loggedInUserId=\(loggedInUserId)"
                
                AF.request(url).responseDecodable(of: [WeeklyReport].self) { response in
                    switch response.result {
                    case .success(let report):
                        self.weeklyReports = report
                        print(self.weeklyReports)
                    case .failure(let error):
                        print(error)
                    }
                }
            } else {
            // UserDefaults에서 사용자 아이디를 찾을 수 없는 경우 예외 처리
            print("User ID not found in UserDefaults")
        }
    }
}

struct WeeklyReportView: View {
    @State private var dateRange = "날짜를 계산할 수 없습니다"
    @State var weeklySum: [WeeklySum] = []
    @StateObject var report = ReportModel()
    
    var body: some View {
        VStack(alignment: .trailing){
            
            HStack{
                Spacer()
                Text("\(weeklySum.count)")
                    .foregroundColor(.blue)
                    .font(.title3)
                    .bold()
                Text("회")
                    .foregroundColor(.black)
                    .bold()
            }
            HStack{
                Spacer()
                Text(dateRange)  // 날짜 범위를 표시할 Text 뷰
                    .foregroundColor(.gray)
                    .font(.caption)
            }
            
            
            Chart(report.weeklyReports){ element in
                BarMark(
                    x: .value("Date", element.weekday),
                    y: .value("Count", element.counts)
                )
                //            .foregroundStyle(by: .value("Type", element.counts))
            }
            
            HStack{
                VStack(alignment: .leading) {
                    Text("Chest Press")
                        .foregroundColor(.black)
                        .bold()
                    Text("Lat Pull Down")
                        .foregroundColor(.black)
                        .bold()
                    Text("Leg Press")
                        .foregroundColor(.black)
                        .bold()
                    Text("Leg Extension")
                        .foregroundColor(.black)
                        .bold()
                }
                Spacer()
                HStack{
                    VStack(alignment: .leading) {
                        Text("회")
                            .foregroundColor(.black)
                            .font(.title3)
                            .bold()
                        Text("회")
                            .foregroundColor(.black)
                            .font(.title3)
                            .bold()
                        Text("회")
                            .foregroundColor(.black)
                            .font(.title3)
                            .bold()
                        Text("회")
                            .foregroundColor(.black)
                            .font(.title3)
                            .bold()
                    }
                    
                }
                
            }
            
            
        }
        //        .chartForegroundStyleScale([
        //            "Chest Press": .green, "Lat Pull Down": .purple, "Leg Press": .pink, "Leg Extension": .yellow
        //        ])
        .onAppear {
            // View가 화면에 나타나면 날짜 범위를 계산하고 표시
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy년 M월 d일"
            
            let today = Date()
            
            if let oneWeekAgo = Calendar.current.date(byAdding: .day, value: -7, to: today) {
                let todayString = dateFormatter.string(from: today)
                let oneWeekAgoString = dateFormatter.string(from: oneWeekAgo)
                
                dateRange = "\(oneWeekAgoString) ~ \(todayString)"
            }
        }
    }
    
    func getSum() {
        if let loggedInUserId = UserDefaults.standard.string(forKey: "loggedInUserId") {
                let url = "https://pcoachapi.azurewebsites.net/api/report/weekly/total?loggedInUserId=\(loggedInUserId)"
            AF.request(url).responseDecodable(of: [WeeklySum].self) { response in
                    switch response.result {
                    case .success(let report):
                        self.weeklySum = report
                        print("\(self.weeklySum) 주간합계")
                    case .failure(let error):
                        print(error)
                    }
                }
            } else {
            // UserDefaults에서 사용자 아이디를 찾을 수 없는 경우 예외 처리
            print("User ID not found in UserDefaults")
        }
    }
} // view end



struct WeeklyReportView_Previews: PreviewProvider {
    static var previews: some View {
        WeeklyReportView()
    }
}
