//
//  ReportViewController.swift
//  PostureCoach
//
//  Created by Youn on 2023/10/04.
//

import UIKit
import SwiftUI

class ReportViewController: UIViewController, UICalendarViewDelegate, UICalendarSelectionSingleDateDelegate {

    @IBOutlet weak var weeklyView: UIView!
    @IBOutlet weak var monthlyView: UIView!
    
    lazy var dateView: UICalendarView = {
            var view = UICalendarView()
            view.translatesAutoresizingMaskIntoConstraints = false
            view.wantsDateDecorations = true
            return view
        }()
    
    var selectedDate: DateComponents? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        applyWeeklyConstraints()
        
        setCalendar()
        reloadDateView(date: Date())
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
            dateView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            dateView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            dateView.widthAnchor.constraint(equalToConstant: 361),
            dateView.heightAnchor.constraint(equalToConstant: 360),
//            dateView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
//            dateView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
//            dateView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
        ]
        
        NSLayoutConstraint.activate(dateViewConstraints)
        self.view.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
    }
    
    fileprivate func applyWeeklyConstraints() {
        let vc = UIHostingController(rootView: WeeklyReportView())
        let swiftuiView = vc.view!
            swiftuiView.translatesAutoresizingMaskIntoConstraints = false

        addChild(vc)
        view.addSubview(swiftuiView)

        NSLayoutConstraint.activate([
            swiftuiView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            swiftuiView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            swiftuiView.widthAnchor.constraint(equalToConstant: 361),
            swiftuiView.heightAnchor.constraint(equalToConstant: 360)
            ])
        vc.didMove(toParent: self)
    }
    
    // UICalendarView
    func calendarView(_ calendarView: UICalendarView, decorationFor dateComponents: DateComponents) -> UICalendarView.Decoration? {
        if let selectedDate = selectedDate,
            selectedDate == dateComponents {
            return .customView {
                let label = UILabel()
                label.text = "🐶"
                label.textAlignment = .center
                return label
            }
        }
        return nil
    }
    
    // 달력에서 날짜 선택했을 경우
    func dateSelection(_ selection: UICalendarSelectionSingleDate, didSelectDate dateComponents: DateComponents?) {
        selection.setSelected(dateComponents, animated: true)
        selectedDate = dateComponents
        reloadDateView(date: Calendar.current.date(from: dateComponents!))
    }
    
    @IBAction func switchView(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            weeklyView.alpha = 1
            monthlyView.alpha = 0

            applyWeeklyConstraints()
        } else {
            weeklyView.alpha = 0
            monthlyView.alpha = 1
            
            applyMonthlyConstraints()
        }
    }

}
