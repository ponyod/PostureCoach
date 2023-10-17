//
//  ExerciseSummaryViewController.swift
//  PostureCoach
//
//  Created by Youn on 2023/10/10.
//

import UIKit

class ExerciseSummaryViewController: UIViewController {

    @IBOutlet var typeLabel: UILabel!
    @IBOutlet var countLabel: UILabel!
    
    var countToReceive: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(handleTossCount(_:)), name: Notification.Name("TossCountNotification"), object: nil)
        
        typeLabel.text = "운동종류"
    }
    
    @objc func handleTossCount(_ notification: Notification) {
        if let legCount = notification.object as? Int {
            // 값(legCount)을 사용
            countLabel.text = "\(legCount) 회"
            print("Received toss count: \(legCount)")
        }
    }
    
    @IBAction func comfirmAlert(_ sender: Any) {
        let alert = UIAlertController(title: "알림", message: "저장되었습니다", preferredStyle: .alert)
        let action = UIAlertAction(title: "확인", style: .default) {_ in
        }
        // 2. UIAlertAction을 생성 (확인 버튼)
        let confirmAction = UIAlertAction(title: "확인", style: .default) { (action) in
            self.navigationController?.popToRootViewController(animated: true)
        }
        alert.addAction(confirmAction)
        present(alert, animated: true)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
