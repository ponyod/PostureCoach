//
//  CellWebViewController.swift
//  WebViewTest
//
//  Created by ponyo on 2023/10/06.
//

import UIKit
import WebKit

class CellWebViewController: UIViewController {
    @IBOutlet weak var cellYoutubeWebView: WKWebView!
    
    var UrlString: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // urlString이 유효한 경우, WKWebView에 웹 페이지 로드
        if let urlString = UrlString, let url = URL(string: urlString) {
            let request = URLRequest(url: url)
            cellYoutubeWebView.load(request)
        }
        
        print(UrlString ?? "cellUrlString")

    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        print("Provisional navigation failed with error: \(error.localizedDescription)")
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("Navigation failed with error: \(error.localizedDescription)")
    }

}
