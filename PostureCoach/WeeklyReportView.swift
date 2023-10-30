//
//  WeeklyReportView.swift
//  PostureCoach
//
//  Created by Youn on 2023/10/13.
//

import Charts
import Charts
import SwiftUI
import Alamofire
import Combine

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
    let count: Int
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case count = "exercise_count"
    }
}

struct ChestSum: Codable {
    let userId: String
    let count: Int
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case count = "exercise_count"
    }
}

struct LatPullSum: Codable {
    let userId: String
    let count: Int
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case count = "exercise_count"
    }
}

struct PressSum: Codable {
    let userId: String
    let count: Int
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case count = "exercise_count"
    }
}

struct ExtensionSum: Codable {
    let userId: String
    let count: Int
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
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
//                        print("\(self.weeklyReports) 데이터 출력")
                    case .failure(let error):
                        print("\(error) 주간 합계 처리 불가")
                    }
                }
            } else {
            // UserDefaults에서 사용자 아이디를 찾을 수 없는 경우 예외 처리
            print("User ID not found in UserDefaults")
        }
    }
}

class SumModel: ObservableObject {
    @Published var weeklySum: [WeeklySum] = []
    
    init() {
        getSum()
    }
    
    func getSum() {
         if let loggedInUserId = UserDefaults.standard.string(forKey: "loggedInUserId") {
             let url = "https://pcoachapi.azurewebsites.net/api/report/weekly/totalCounts?loggedInUserId=\(loggedInUserId)"
             AF.request(url).responseDecodable(of: [WeeklySum].self) { response in
                     switch response.result {
                     case .success(let total):
//                         print(total)
                         self.weeklySum = total
//                         print("\(self.weeklySum.count) 주간 합계")
                     case .failure(let error):
                         print("\(error) SumModel 처리할 수 없음")
                     }
                 }
             } else {
             // UserDefaults에서 사용자 아이디를 찾을 수 없는 경우 예외 처리
             print("User ID not found in UserDefaults")
         }
     }
}

class ChestCount: ObservableObject {
    @Published var chestCount: [ChestSum] = []
    
    init() {
        getSum()
    }
    
    func getSum() {
         if let loggedInUserId = UserDefaults.standard.string(forKey: "loggedInUserId") {
             let url = "https://pcoachapi.azurewebsites.net/api/report/weekly/chestpress?loggedInUserId=\(loggedInUserId)"
             AF.request(url).responseDecodable(of: [ChestSum].self) { response in
                     switch response.result {
                     case .success(let sum):
//                         print(sum)
                         self.chestCount = sum
//                         print("\(self.chestCount.count) 주간 합계")
                     case .failure(let error):
                         print("\(error) ChestCount 처리할 수 없음")
                     }
                 }
             } else {
             // UserDefaults에서 사용자 아이디를 찾을 수 없는 경우 예외 처리
             print("User ID not found in UserDefaults")
         }
     }
}

class LatPullCount: ObservableObject {
    @Published var latpullCount: [LatPullSum] = []
    
    init() {
        getSum()
    }
    
    func getSum() {
         if let loggedInUserId = UserDefaults.standard.string(forKey: "loggedInUserId") {
             let url = "https://pcoachapi.azurewebsites.net/api/report/weekly/latpulldown?loggedInUserId=\(loggedInUserId)"
             AF.request(url).responseDecodable(of: [LatPullSum].self) { response in
                     switch response.result {
                     case .success(let sum):
//                         print(sum)
                         self.latpullCount = sum
//                         print("\(self.latpullCount.count) 주간 합계")
                     case .failure(let error):
                         print("\(error) LatPullCount 처리할 수 없음")
                     }
                 }
             } else {
             // UserDefaults에서 사용자 아이디를 찾을 수 없는 경우 예외 처리
             print("User ID not found in UserDefaults")
         }
     }
}

class PressCount: ObservableObject {
    @Published var pressCount: [PressSum] = []
    
    init() {
        getSum()
    }
    
    func getSum() {
         if let loggedInUserId = UserDefaults.standard.string(forKey: "loggedInUserId") {
             let url = "https://pcoachapi.azurewebsites.net/api/report/weekly/legpress?loggedInUserId=\(loggedInUserId)"
             AF.request(url).responseDecodable(of: [PressSum].self) { response in
                     switch response.result {
                     case .success(let sum):
//                         print(sum)
                         self.pressCount = sum
                     case .failure(let error):
                         print("\(error) PressCount 처리할 수 없음")
                     }
                 }
             } else {
             // UserDefaults에서 사용자 아이디를 찾을 수 없는 경우 예외 처리
             print("User ID not found in UserDefaults")
         }
     }
}

class ExtensionCount: ObservableObject {
    @Published var extensionCount: [ExtensionSum] = []
    
    init() {
        getSum()
    }
    
    func getSum() {
         if let loggedInUserId = UserDefaults.standard.string(forKey: "loggedInUserId") {
             let url = "https://pcoachapi.azurewebsites.net/api/report/weekly/legextension?loggedInUserId=\(loggedInUserId)"
             AF.request(url).responseDecodable(of: [ExtensionSum].self) { response in
                     switch response.result {
                     case .success(let sum):
//                         print(sum)
                         self.extensionCount = sum
//                         print("\(self.extensionCount.count) 주간 합계")
                     case .failure(let error):
                         print("\(error) ExtensionCount 처리할 수 없음")
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
    
    @State private var dateRange = "날짜를 계산할 수 없습니다"
    @StateObject var total = SumModel()
    @StateObject var report = ReportModel()
    @StateObject var chestpress = ChestCount()
    @StateObject var latpulldown = LatPullCount()
    @StateObject var legpress = PressCount()
    @StateObject var legextension = ExtensionCount()
    
    var body: some View {
        VStack(alignment: .trailing){
            HStack{
                Spacer()
//                weeklySum 배열의 첫 번째 요소의 count를 가져오기
                Text("\(total.weeklySum.first?.count ?? 0)")
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
                        HStack {
                            Text("체스트프레스")
                                .foregroundColor(.black)
                                .bold()
                            Spacer()
                            HStack {
                                Text("\(chestpress.chestCount.first?.count ?? 0)")
                                    .foregroundColor(.blue)
                                    .font(.title3)
                                    .bold()
                                Text("회")
                                    .foregroundColor(.black)
                                    .bold()
                            }
                        }
                        .padding(.bottom, 1)
                    
                        HStack {
                            Text("랫풀다운")
                                .foregroundColor(.black)
                                .bold()
                            Spacer()
                            HStack {
                                Text("\(latpulldown.latpullCount.first?.count ?? 0)")
                                    .foregroundColor(.blue)
                                    .font(.title3)
                                    .bold()
                                Text("회")
                                    .foregroundColor(.black)
                                    .bold()
                            }
                        }
                        .padding(.bottom, 1)
                    
                        HStack {
                            Text("레그프레스")
                                .foregroundColor(.black)
                                .bold()
                            Spacer()
                            HStack {
                                Text("\(legpress.pressCount.first?.count ?? 0)")
                                    .foregroundColor(.blue)
                                    .font(.title3)
                                    .bold()
                                Text("회")
                                    .foregroundColor(.black)
                                    .bold()
                            }
                        }
                        .padding(.bottom, 1)
                    
                        HStack {
                            Text("레그익스텐션")
                                .foregroundColor(.black)
                                .bold()
                            Spacer()
                            HStack {
                                Text("\(legextension.extensionCount.first?.count ?? 0)")
                                    .foregroundColor(.blue)
                                    .font(.title3)
                                    .bold()
                                Text("회")
                                    .foregroundColor(.black)
                                    .bold()
                            }
                        }
                        .padding(.bottom, 1)
                    }
            } // 기구별 주간 기록 끝
        }
        //        .chartForegroundStyleScale([
        //            "Chest Press": .green, "Lat Pull Down": .purple, "Leg Press": .pink, "Leg Extension": .yellow
        //        ])
        .onAppear {
            
            // View가 화면에 나타나면 날짜 범위를 계산하고 표시
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy년 M월 d일"

            let today = Date()

            if let oneWeekAgo = Calendar.current.date(byAdding: .day, value: -6, to: today) {
                let todayString = dateFormatter.string(from: today)
                let oneWeekAgoString = dateFormatter.string(from: oneWeekAgo)

                dateRange = "\(oneWeekAgoString) ~ \(todayString)"
            }
        }
    }
} // view end

//struct WeeklyReportView_Previews: PreviewProvider {
//    static var previews: some View {
//        WeeklyReportView()
//    }
//}
