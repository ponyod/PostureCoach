//
//  MonthlyViewController.swift
//  PostureCoach
//
//  Created by Youn on 2023/10/17.
//

import UIKit
import Alamofire

class MonthlyViewController: UIViewController, UICalendarViewDelegate, UICalendarSelectionSingleDateDelegate {

    lazy var dateView: UICalendarView = {
            var view = UICalendarView()
            view.translatesAutoresizingMaskIntoConstraints = false
            view.wantsDateDecorations = true
            return view
        }()
    
    var selectedDate: DateComponents? = nil
    var workoutReports: [WorkoutReport] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        applyMonthlyConstraints()
        setCalendar()
        reloadDateView(date: Date())
        // Do any additional setup after loading the view.
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
            dateView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            dateView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            dateView.widthAnchor.constraint(equalToConstant: 345),
            dateView.heightAnchor.constraint(equalToConstant: 390)
//            dateView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
//            dateView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
//            dateView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
        ]
        
        NSLayoutConstraint.activate(dateViewConstraints)
        self.view.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
    }
    
    func createDate(year: Int, month: Int, day: Int) -> Date {
        let calendar = Calendar.current
        return calendar.date(from: DateComponents(year: year, month: month, day: day))!
    }
    
    // UICalendarView
    func calendarView(_ calendarView: UICalendarView, decorationFor dateComponents: DateComponents) -> UICalendarView.Decoration? {
        // 웹 요청 보내기
            let url = "https://pcoachapi.azurewebsites.net/api/report/monthly"
        
        //                responseDecodable(of:ResultData.self) { response in
        //                    guard let result = response.value else { return }
        //
        //                    self.books = result.documents
        //                    let meta = result.meta
        //                    print(self.books)
        //                }
        
//            AF.request(url).responseDecodable(of: [WorkoutReport].self) { response in
//                switch response.result {
//                case .success(let reports):
//                    if let exerciseReport = self.getExerciseReport(for: dateComponents, from: reports) {
//                        DispatchQueue.main.async {
                            // 해당 날짜에 운동 보고서가 있는 경우 데코레이션 추가
//                            self.dateView
//                            return self.dateView {
//                                let label = UILabel()
//                                label.text = "💪"
//                                label.textAlignment = .center
//                                return label
//                            }
//                        }
//                    }
//                case .failure(let error):
//                    // 에러 핸들링
//                    if let data = response.data, let errorString = String(data: data, encoding: .utf8) {
//                        print("Error: \(errorString)")
//                    } else {
//                        print(error)
//                    }
//                }
//
//            }
//
//            return nil
//        if let exerciseReport = getExerciseReport(for: dateComponents) {
//                return .customView {
//                    let label = UILabel()
//                    label.text = "💪"
//                    label.textAlignment = .center
//                    return label
//                }
//            }
            return nil
        
//        if let selectedDate = selectedDate, selectedDate == dateComponents {
//               return .customView {
//                   let label = UILabel()
//                   label.textAlignment = .center
//
//                if let exerciseReport = self.fetchDataForDate(dateComponents) {
//                        // 해당 날짜에 데이터가 있는 경우, 텍스트를 설정.
//                        label.text = "💪"
//                    } else {
//                        // 데이터가 없는 경우, 아무것도 표시되지 않음.
//                        label.text = ""
//                    }
//                    return label
//            }
//        }
    }
    
    // 달력에서 날짜 선택했을 경우
    func dateSelection(_ selection: UICalendarSelectionSingleDate, didSelectDate dateComponents: DateComponents?) {
        selection.setSelected(dateComponents, animated: true)
        selectedDate = dateComponents
        reloadDateView(date: Calendar.current.date(from: dateComponents!))
    }
    
    // 날짜별 데이터를 가져오는 함수 (예: fetchDataForDate)
    func fetchDataForDate(_ dateComponents: DateComponents) -> String? {
        let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            if let exerciseDate = Calendar.current.date(from: dateComponents) {
                let formattedDate = dateFormatter.string(from: exerciseDate)
                // 여기에서 ExerciseReport를 가져옵니다. 이 예제에서는 임의의 데이터를 사용합니다.
//                if let exerciseReport = exerciseReports[formattedDate] {
//                    return exerciseReport
//                }
            }
            return nil
    }
    
//    func getExerciseReport(for dateComponents: DateComponents, from reports: [WorkoutReport]) -> WorkoutReport? {
//        // 주어진 dateComponents와 일치하는 보고서 찾기
//        if let date = Calendar.current.date(from: dateComponents) {
//            return reports.first { Calendar.current.isDate($0.exerciseDate, inSameDayAs: date) }
//        }
//
//        return nil
//    }
    
    
}
