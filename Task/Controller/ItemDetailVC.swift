//
//  ItemDetailVC.swift
//  Task
//
//  Created by Admin on 9/18/18.
//  Copyright © 2018 Admin. All rights reserved.
//

import UIKit
import WebKit

class ItemDetailVC: UIViewController,WKUIDelegate, WKNavigationDelegate  {
    
    @IBOutlet weak var webView: WKWebView!
    
    var urlString = ""
    var personTitle = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
        self.title = personTitle
        print(urlString)
        
        if Reachability.isConnectedToNetwork() == true{
            
            if let myURL = URL(string: urlString){
                let myRequest = URLRequest(url: myURL)
                webView.load(myRequest)
                print("Webpage Loaded Successfully...!!!")
            }
            
        }else{
            
            showAlert(targetVC: self, title: "", message: noInternetMessage)
        }
    }
}
