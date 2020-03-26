//
//  ViewController.swift
//  sfsafariview
//
//  Created by Howard Ellenberger on 3/5/20.
//  Copyright © 2020 Howard Ellenberger. All rights reserved.
//
import Foundation
import UIKit
import WebKit
import ObjectiveC

class BrowserViewController: UIViewController, UIScrollViewDelegate, WKUIDelegate, WKNavigationDelegate, UISearchBarDelegate {
    
    var cameraViewController : CameraViewController!
    

    @IBOutlet var webView: WKWebView!
    
    @IBOutlet weak var toolBar: UIToolbar!
    
    @IBOutlet weak var ActInd: UIActivityIndicatorView!


    @IBAction func back(_ sender: Any) {

        if webView!.canGoBack {

            webView?.goBack()
        }
    }
 
    @IBAction func forward(_ sender: Any) {

        if webView!.canGoForward {

            webView?.goForward()
        }
    }
    
    @IBAction func refresh(_ sender: Any) {
        
        webView?.reload()
    }
    
    @IBAction func stop(_ sender: Any) {
        
        webView?.stopLoading()
    }
    
     @IBAction func toCamera(_ sender: Any) {


          OperationQueue.main.addOperation {[weak self] in
          self?.performSegue(withIdentifier: "toCamera", sender: self)

          return
      }
    }
      
    @IBAction func myUnwindAction(unwindSegue: UIStoryboardSegue){}

    
    func loadWebView() {
        webView?.translatesAutoresizingMaskIntoConstraints = false
        let configuration = WKWebViewConfiguration()
        if #available(iOS 10.0, *) {
        configuration.mediaTypesRequiringUserActionForPlayback = []
        configuration.allowsInlineMediaPlayback = true
        
        configuration.dataDetectorTypes = [.all]
            
        }
        configuration.allowsPictureInPictureMediaPlayback = true
        let javascript = "var meta = document.createElement('meta');meta.setAttribute('name', 'viewport');meta.setAttribute('content', 'width=device-width, initial-scale=0.3|, maximum-scale=5.0, user-scalable=yes');document.getElementsByTagName('head')[0].appendChild(meta);"
        
        webView = WKWebView(frame: CGRect(origin: CGPoint.zero, size: webView.frame.size), configuration: configuration)
        
        let us = WKUserScript(source: javascript, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        webView.configuration.userContentController.addUserScript(us)
        
        
        webView?.navigationDelegate = self
        webView?.uiDelegate = self
 
    }
  
    override func viewDidLayoutSubviews() {
        //let *** = CALayer()
       
        let replicatorLayer = CAReplicatorLayer()

        webView.frame = CGRect(x: 20, y: 15, width: 275, height: 235)
       
        replicatorLayer.frame = CGRect(x: 20, y: 15, width: 275, height: 235)
        let instanceCount = 2
        replicatorLayer.backgroundColor = UIColor.clear.cgColor
        replicatorLayer.instanceCount = instanceCount
        replicatorLayer.instanceTransform = CATransform3DMakeTranslation(310, 0, 0)
        replicatorLayer.addSublayer(webView!.layer)
        view.layer.addSublayer(replicatorLayer)
    }
    
    @IBAction func youTube(_ sender: Any) {
        let searchText = "https://www.youtube.com"
        let url = URL(string: searchText)
        let request = URLRequest(url: url!)
        webView.load(request)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        loadWebView()

        let searchText = "https://www.google.com"

        let url = URL(string: searchText)
        let request = URLRequest(url: url!)
        webView.load(request)
        }
       
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)


    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        webView!.becomeFirstResponder()
        
        self.view.addSubview(self.webView!)
        
       
        
        webView?.addSubview(ActInd)
        ActInd.startAnimating()
        ActInd.stopAnimating()
        ActInd.hidesWhenStopped = true
}
    
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        let ac = UIAlertController(title: "Hey, listen!", message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(ac, animated: true)
        completionHandler()
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: (WKNavigationActionPolicy) -> Void) {
      
      decisionHandler(.allow) //allow the user to navigate to the requested page.
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: (WKNavigationResponsePolicy) -> Void) {
      
      decisionHandler(.allow) //allow the webView to process the response.
    }
    
     func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
            
            ActInd.startAnimating()
        }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {

         ActInd.stopAnimating()
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {

        ActInd.stopAnimating()
    }

//    func bringSubviewToFront(_ view: UIView) {
//        view.bringSubviewToFront(webView!)
//        webView!.layer.zPosition = 1
//
//    }
}

extension WKWebView {
    func load(_ urlString: String) {
        if let url = URL(string: urlString) {
            let request = URLRequest(url: url)
            load(request)
        }
    }
}
   
