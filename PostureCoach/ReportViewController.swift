//
//  ReportViewController.swift
//  PostureCoach
//
//  Created by Youn on 2023/10/04.
//

import UIKit
import SwiftUI
import Alamofire

class ReportViewController: UIViewController {
    
    var workoutReports: [WorkoutReport] = []
    let machines = ["chestpress", "latpulldown", "legpress", "legextension"]
    
    @IBOutlet weak var viewContainer: UIView!
    
    var monthlyView: UIView!
    var weeklyView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        monthlyView = MonthlyViewController().view
        weeklyView = WeeklyViewController().view
        viewContainer.addSubview(monthlyView)
        viewContainer.addSubview(weeklyView)
        self.tabBarController?.tabBar.isHidden = false;
    }
    
    @IBAction func switchView(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            viewContainer.bringSubviewToFront(weeklyView)
            weeklyView.alpha = 1
            monthlyView.alpha = 0
        } else {
            viewContainer.bringSubviewToFront(monthlyView)
            weeklyView.alpha = 0
            monthlyView.alpha = 1
        }
    }
    
}

