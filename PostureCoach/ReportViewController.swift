//
//  ReportViewController.swift
//  PostureCoach
//
//  Created by Youn on 2023/10/04.
//

import UIKit

class ReportViewController: UIViewController {

    @IBOutlet weak var weeklyView: UIView!
    @IBOutlet weak var monthlyView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    @IBAction func switchView(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            weeklyView.alpha = 1
            monthlyView.alpha = 0
        } else {
            weeklyView.alpha = 0
            monthlyView.alpha = 1
        }
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
