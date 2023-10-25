//
//  ExerciseSummaryViewController.swift
//  PostureCoach
//
//  Created by Youn on 2023/10/10.
//

import UIKit
import Alamofire

class ExerciseSummaryViewController: UIViewController {
    @IBOutlet var typeLabel: UILabel!
    @IBOutlet var countLabel: UILabel!
    
    var count : Int?
    var workoutType : String?
    let exerciseDate = Date()
    let dateFormatter = DateFormatter()
    
    let machines = ["chestpress", "latpulldown", "legpress", "legextension"]
    
    var newRecord: WorkoutReport?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let workoutType = workoutType {
            self.typeLabel.text = "\(workoutType)"
        }
        
        if let count = count {
            self.countLabel.text = "\(count) 회"
        }
        
        if let workoutType = workoutType,
            let converted = convertMachineName(machine: workoutType),
            let userId = UserDefaults.standard.string(forKey: "loggedInUserId"),
            let exerciseCount = count {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let dateString = dateFormatter.string(from: exerciseDate)

            newRecord = WorkoutReport(userId: userId, machineName: converted, exerciseCount: exerciseCount, exerciseDate: dateString)
            print(newRecord)
        } else {
            // Handle the case when workoutType or count is nil
            // You can set default values or handle the error as needed
            print("Error: workoutType or count is nil")
            return
        }
        
    }
    
    func convertMachineName(machine: String) -> Int? {
        let machines: [String: Int] = [
            "Chest Press": 1,
            "Lat Pull Down": 2,
            "Leg Press": 3,
            "Leg Extension": 4
        ]
            print("\(machines[workoutType!]) 출력")
            return machines[machine]
    }
    
    // 기록 추가
    func addLog(newRecord: WorkoutReport, completion: @escaping (Bool) -> Void) {
        let url = "https://pcoachapi.azurewebsites.net/api/exercise"
        let params:Parameters = [
            "user_id": newRecord.userId,
            "machine_code": newRecord.machineName,
            "exercise_count": newRecord.exerciseCount,
            "exercise_date": newRecord.exerciseDate
        ]
        AF.request(url, method: .post, parameters: params, encoding: JSONEncoding.default).response { response in
            guard let result = response.value else {
                print("nil")
                return
            }
            print(response)
        }
    }
    
    @IBAction func comfirmAlert(_ sender: Any) {
        let alert = UIAlertController(title: "알림", message: "저장되었습니다", preferredStyle: .alert)
        _ = UIAlertAction(title: "확인", style: .default) {_ in
        }
        if let newRecord = newRecord {
            addLog(newRecord: newRecord) { success in
                if success {
                    print("Exercise Log added successfully")
                } else {
                    print("Failed to add Exercise Log")
                }
            }
        } else {
            // newRecord가 nil인 경우를 처리
            print("Error: newRecord is nil")
            return
        }
        
        // 2. UIAlertAction을 생성 (확인 버튼)
        let confirmAction = UIAlertAction(title: "확인", style: .default) { (action) in
            self.navigationController?.popToRootViewController(animated: true)
        }
        alert.addAction(confirmAction)
        present(alert, animated: true)
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }

}
