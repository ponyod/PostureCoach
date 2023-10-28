//
//  ContentsWebViewController.swift
//  PostureCoach
//
//  Created by ponyo on 2023/10/13.
//

import UIKit
import WebKit

class ContentsWebViewController: UIViewController {
    @IBOutlet weak var contentsYoutubeWebView: WKWebView!
    
    var url: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let urlString = url, let url = URL(string: urlString) {
            let request = URLRequest(url: url)
            contentsYoutubeWebView.load(request)
        }
    }
}
