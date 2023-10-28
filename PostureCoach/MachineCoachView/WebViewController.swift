//
//  WebViewController.swift
//  WebViewTest
//
//  Created by ponyo on 2023/09/28.
//

import UIKit
import WebKit

class WebViewController: UIViewController {
    @IBOutlet weak var youtubeWebView: WKWebView!
    
    var urlString: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // urlString이 유효한 경우, WKWebView에 웹 페이지 로드
        if let urlString = urlString, let url = URL(string: urlString) {
            let request = URLRequest(url: url)
            youtubeWebView.load(request)
        }
    }
}
