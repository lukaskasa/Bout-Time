//
//  WebViewController.swift
//  Bout Time
//
//  Created by Lukas Kasakaitis on 31.03.19.
//  Copyright © 2019 Lukas Kasakaitis. All rights reserved.
//

import UIKit
import WebKit

class WebViewController: UIViewController {
    
    var eventLink: URL?
    
    @IBOutlet weak var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let url = eventLink {
            let request = URLRequest(url: url)
            webView.load(request)
        }

    }
    
    // To hide the status bar
    override var prefersStatusBarHidden: Bool {
        return true
    }

    @IBAction func dismissWebview() {
        dismiss(animated: true, completion: nil)
    }

}
