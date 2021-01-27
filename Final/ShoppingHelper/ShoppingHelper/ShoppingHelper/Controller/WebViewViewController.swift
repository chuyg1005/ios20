//
//  WebViewViewController.swift
//  ShoppingHelper
//
//  Created by njuios on 2020/12/31.
//

import UIKit
import WebKit

class WebViewViewController: UIViewController {

    @IBOutlet weak var webView: WKWebView!
    
    @IBOutlet weak var progressView: UIProgressView!
    var urlString: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        progressView.isHidden = true
         webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
        loadWeb()
        // Do any additional setup after loading the view.
    }
    
    func loadWeb() {
        
        if let urlString = urlString, let url = URL(string: urlString) {
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" {
            self.progressView.isHidden = false
            self.progressView.progress = Float(webView.estimatedProgress)
            if self.progressView.progress == 1.0 {
                self.progressView.isHidden = true
            }
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
