//
//  MonthlyViewController.swift
//  PostureCoach
//
//  Created by Youn on 2023/10/28.
//

import UIKit
import Alamofire
import FSCalendar


class MonthlyViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var totalCountView: UIView!
    
    @IBOutlet weak var calendarView: FSCalendar!
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    let machines = ["체스트프레스", "랫풀다운", "레그프레스", "레그익스텐션"]
    
    
    var monthlyReports: [MonthlyReport] = []
    var total : [MonthlyTotal] = []
    var monthlyType : [MonthlyType] = []
    var totalCount: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        getdateRange()
        monthlyCounts()
        getMonthlyTypeCounts()
        boderLine()
        
        if let tableView = tableView {
            tableView.dataSource = self
            tableView.delegate = self
            tableView.rowHeight = UITableView.automaticDimension
            tableView.estimatedRowHeight = UITableView.automaticDimension
        }
    }
    
    func boderLine() {
        totalCountView?.layer.borderWidth = 1
        totalCountView?.layer.borderColor = UIColor.black.cgColor
        
        tableView?.layer.borderWidth = 1
        tableView?.layer.borderColor = UIColor.black.cgColor
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return machines.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return 32
        }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reportcell", for: indexPath)
        if let label = cell.viewWithTag(1) as? UILabel {
                let ExerciseType = machines[indexPath.row]
                label.text = ExerciseType
            }
        
        if let label = cell.viewWithTag(2) as? UILabel {
            if indexPath.row < monthlyType.count {
                let count = monthlyType[indexPath.row].count
                label.text = "\(count)"
            } else {
                label.text = "N/A"
            }
        }
        return cell
    }
    
    func monthlyCounts(){
        if let loggedInUserId = UserDefaults.standard.string(forKey: "loggedInUserId") {
            let url = "https://pcoachapi.azurewebsites.net/api/report/monthly/totalCounts?loggedInUserId=\(loggedInUserId)"
            
            AF.request(url).responseDecodable(of: [MonthlyTotal].self) { response in
                switch response.result {
                case .success(let total):
                    if let totalCount = total.first?.count {
                        self.totalCount = totalCount
                        if let totalLabel = self.totalLabel {
                            self.totalLabel.text = "\(self.totalCount)"
                        }
                    } else {
                        print("exercise_count not found in JSON data")
                    }
                case .failure(let error):
                    print("Decoding error: \(error)")
                }
            }
        }
    }
    
    func getdateRange() {
        let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy년 M월 d일"

            // 현재 날짜 가져오기
            let today = Date()

            // 1주일 (30일) 후의 날짜 계산
            if let oneMonthAgo = Calendar.current.date(byAdding: .day, value: -30, to: today) {
                let todayString = dateFormatter.string(from: today)
                let oneMonthAgoString = dateFormatter.string(from: oneMonthAgo)
                if let dateLabel = dateLabel {
                    dateLabel.text = "\(oneMonthAgoString) ~ \(todayString)"
                }
            }
    }
    
    func getMonthlyTypeCounts() {
        if let loggedInUserId = UserDefaults.standard.string(forKey: "loggedInUserId") {
            let url = "https://pcoachapi.azurewebsites.net/api/report/monthly/type?loggedInUserId=\(loggedInUserId)"
            AF.request(url).responseDecodable(of: [MonthlyType].self) { response in
                    switch response.result {
                    case .success(let types):
                        self.monthlyType = types
                        if let tableView = self.tableView {
                            tableView.reloadData()
                        }
//                        print("\(self.monthlyType) 월간 합계")
                    case .failure(let error):
                        print("\(error) 처리할 수 없음")
                    }
                }
            } else {
            // UserDefaults에서 사용자 아이디를 찾을 수 없는 경우 예외 처리
            print("User ID not found in UserDefaults")
        }
    }
    
}

struct MonthlyTotal: Decodable {
    let userId: String
    let count: Int
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case count = "exercise_count"
    }
}

struct MonthlyReport: Decodable {
    let userId: String
    let count: Int
    let date: String
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case count = "exercise_count"
        case date = "exercise_date"
    }
}

struct MonthlyType: Decodable {
    let machineName: String
    let count: Int
    
    enum CodingKeys: String, CodingKey {
        case machineName = "machine_name"
        case count = "exercise_count"
    }
}
