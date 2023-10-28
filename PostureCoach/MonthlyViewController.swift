//
//  MonthlyViewController.swift
//  PostureCoach
//
//  Created by Youn on 2023/10/21.
//

import UIKit
import Alamofire

class MonthlyViewController: UIViewController, UICalendarViewDelegate, UICalendarSelectionSingleDateDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var calendarView: UIView!
    lazy var dateView: UICalendarView = {
            var view = UICalendarView()
            view.translatesAutoresizingMaskIntoConstraints = false
            view.wantsDateDecorations = true
            return view
        }()
    
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet weak var sumLabel: UILabel!
    var selectedDate: DateComponents? = nil
    var monthlyReports: [MonthlyReport] = []
    var total : [MonthlyTotal] = []
    var totalCount: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        monthlyCounts()
        applyMonthlyConstraints()
        setCalendar()
        getMonthly()
//        calendarView.addSubview(dateView)
        reloadDateView(date: Date())
        // Do any additional setup after loading the view.
        let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy년 M월 d일"

            // 현재 날짜 가져오기
            let today = Date()

            // 1주일 (30일) 후의 날짜 계산
            if let oneMonthAgo = Calendar.current.date(byAdding: .day, value: -30, to: today) {
                let todayString = dateFormatter.string(from: today)
                let oneMonthAgoString = dateFormatter.string(from: oneMonthAgo)
                dateLabel.text = "\(oneMonthAgoString) ~ \(todayString)"
            }
        
    }

    func monthlyCounts(){
        if let loggedInUserId = UserDefaults.standard.string(forKey: "loggedInUserId") {
            let url = "https://pcoachapi.azurewebsites.net/api/report/monthly/totalCounts?loggedInUserId=\(loggedInUserId)"
            
            AF.request(url).responseDecodable(of: [MonthlyTotal].self) { response in
                switch response.result {
                case .success(let total):
                    if let totalCount = total.first?.count {
                        self.totalCount = totalCount
                        self.sumLabel.text = "\(self.totalCount)"
                    } else {
                        print("exercise_count not found in JSON data")
                    }
                case .failure(let error):
                    print("Decoding error: \(error)")
                }
            }
        }
    }
    
    fileprivate func setCalendar() {
        dateView.delegate = self

        let dateSelection = UICalendarSelectionSingleDate(delegate: self)
        dateView.selectionBehavior = dateSelection
    }
    
    func reloadDateView(date: Date?) {
        if date == nil { return }
        let calendar = Calendar.current
        dateView.reloadDecorations(forDateComponents: [calendar.dateComponents([.day, .month, .year], from: date!)], animated: true)
    }
    
    fileprivate func applyMonthlyConstraints() {
        view.addSubview(dateView)
        
        let dateViewConstraints = [
            dateView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            dateView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            dateView.widthAnchor.constraint(equalToConstant: 351),
        ]
        
        NSLayoutConstraint.activate(dateViewConstraints)
    }
    
    func createDate(year: Int, month: Int, day: Int) -> Date {
        let calendar = Calendar.current
        return calendar.date(from: DateComponents(year: year, month: month, day: day))!
    }
    
    // UICalendarView
    func calendarView(_ calendarView: UICalendarView, decorationFor dateComponents: DateComponents) -> UICalendarView.Decoration? {
        getMonthly()
        let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
        // 날짜 형식을 문자열로 변환
            if let date = Calendar.current.date(from: dateComponents) {
                let formattedDate = dateFormatter.string(from: date)

                // monthlyReports 배열에서 해당 날짜와 일치하는 데이터가 있는지 확인
                if monthlyReports.contains(where: { $0.date == formattedDate }) {
                    return .customView {
                        let label = UILabel()
                        label.text = "💪"
                        label.textAlignment = .center
                        return label
                    }
                }
            }

            return nil
    }
    
    func getMonthly(){
        // 웹 요청 보내기
       let url = "https://pcoachapi.azurewebsites.net/api/report/monthly"
        
    AF.request(url).responseDecodable(of: [MonthlyReport].self) { response in
            switch response.result {
            case .success(let monthly):
                self.monthlyReports = monthly
                print("\(self.monthlyReports) 출력")
            case .failure(let error):
                print(error)
            }
        }
    }
    
    // 달력에서 날짜 선택했을 경우
    func dateSelection(_ selection: UICalendarSelectionSingleDate, didSelectDate dateComponents: DateComponents?) {
        selection.setSelected(dateComponents, animated: true)
        selectedDate = dateComponents
        reloadDateView(date: Calendar.current.date(from: dateComponents!))
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
