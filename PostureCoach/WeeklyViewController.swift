//
//  WeeklyViewController.swift
//  PostureCoach
//
//  Created by Youn on 2023/10/17.
//

import UIKit
import SwiftUI

class WeeklyViewController: UIViewController {
    
    var swiftUiView = UIHostingController(rootView: WeeklyReportView())
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        applyWeeklyConstraints()
    }

    fileprivate func applyWeeklyConstraints() {
        let vc = UIHostingController(rootView: WeeklyReportView())
        let swiftuiView = vc.view!
            swiftuiView.translatesAutoresizingMaskIntoConstraints = false

        addChild(vc)
        view.addSubview(swiftuiView)

        NSLayoutConstraint.activate([
            swiftuiView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            swiftuiView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            swiftuiView.widthAnchor.constraint(equalToConstant: 355),
            swiftuiView.heightAnchor.constraint(equalToConstant: 523)
            ])
        vc.didMove(toParent: self)
        
    }

}
