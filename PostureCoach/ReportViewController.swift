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
    let machines = ["chestpress", "latpulldown", "legpress", "legextension"]
    
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
//        let report = workoutReports[indexPath.row]  // indexPath에 해당하는 데이터 가져오기
//
//        if let label = cell.viewWithTag(1) as? UILabel {
//            label.text = "\(machines.count)"
//        }
//        if let label = cell.viewWithTag(2) as? UILabel {
//            label.text = "회"
//        }
//        if let label = cell.viewWithTag(3) as? UILabel {
//            label.text = "회"
//        }
        
        return cell
    }

}

