//
//  ReportViewController.swift
//  PostureCoach
//
//  Created by Youn on 2023/10/04.
//

import UIKit
import SwiftUI
import Alamofire

class ReportViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var workoutReports: [WorkoutReport] = []
    let machines = ["chestpress", "latpulldown", "legextension", "legpress"]
    
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var logTableView: UITableView!
    
    var monthlyView: UIView!
    var weeklyView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        monthlyView = MonthlyViewController().view
        weeklyView = WeeklyViewController().view
        viewContainer.addSubview(monthlyView)
        viewContainer.addSubview(weeklyView)
        loadWeeklyData()
        setupTable()
    }
    
    func setupTable() {
        logTableView.dataSource = self
        logTableView.delegate = self
        logTableView.register(UITableViewCell.self, forCellReuseIdentifier: "logcell")
    }
    
    @IBAction func switchView(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            viewContainer.bringSubviewToFront(weeklyView)
            
        } else {
            viewContainer.bringSubviewToFront(monthlyView)
        }
    }
    
    func loadWeeklyData() {
        let url = "https://pcoachapi.azurewebsites.net/api/report/weekly"
//        let alamo = AF.request(url, method: .get)
//            alamo.responseJSON { response in
//                switch response.result {
//                case .success:
//                    if let data = response.data,
//                       let result = String(data: data, encoding: .utf8) {
//                           print("JSON Data: \(result)")
//                       }
//
//                        let result = String(data: data) {
//                        print("JSON Data: \(result)")
//                    }
//                case .failure(let error):
//                    print("Network request failed with error: \(error)")
//                    // 사용자에게 오류 메시지를 표시하거나 적절한 조치를 취합니다.
//                }
//            }
        
//        let alamo = AF.request(url, method: .get)
//        alamo.responseDecodable(of: [WorkoutReport].self) { response in
//            if let error = response.error {
//                    print("Network request failed with error: \(error)")
//                    // 사용자에게 오류 메시지를 표시하거나 적절한 조치를 취합니다.
//                } else {
//                    guard let result = response.value else {
//                        print("Response data is nil")
//                        // 사용자에게 오류 메시지를 표시하거나 적절한 조치를 취합니다.
//                        return
//                    }
//                    self.workoutReports = result // 배열에 데이터 저장
//                    print(self.workoutReports)
//                }
//        }
        
        AF.request(url).responseDecodable(of: [WorkoutReport].self) { response in
            switch response.result {
            case .success(let report):
                self.workoutReports = report
                self.logTableView.reloadData()
                print(self.workoutReports)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
        // workoutReports 배열에서 중복되지 않는 machineName들을 가져오기
//        let uniqueMachineNames = Array(Set(workoutReports.map { $0.machineName }))
        
        // 중복되지 않는 machineName의 수를 반환 (중복된 운동 종류는 1로 간주)
//        return uniqueMachineNames.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "logcell", for: indexPath)
        let report = workoutReports[indexPath.row]  // indexPath에 해당하는 데이터 가져오기
        
        if let label = cell.viewWithTag(1) as? UILabel {
            label.text = "\(machines.count)"
        }
        if let label = cell.viewWithTag(2) as? UILabel {
            label.text = "회"
        }
        if let label = cell.viewWithTag(3) as? UILabel {
            label.text = "회"
        }
        
        return cell
    }

}

struct WorkoutReport: Decodable {
    let userId: String
    let machineName: String
    let exerciseCount: Int
    let exerciseDate: String
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case machineName = "machine_name"
        case exerciseCount = "exercise_count"
        case exerciseDate = "exercise_date"
    }
}
