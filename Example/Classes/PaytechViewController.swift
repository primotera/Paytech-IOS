//
//  PaytechViewController.swift
//  Paytech_Example
//
//  Created by Làye DIOP on 01/04/2020.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit
import WebKit

class PaytechViewController: UIViewController {
    
    var requestTokenUrl: URL?
    weak var delegate: PaytechViewControllerDelegate?
    var tokenUrl: URL?
    var params: [String: Any] = [:]
    private let CANCEL_URL = "https://paytech.sn/mobile/cancel"
    private let SUCCESS_URL = "https://paytech.sn/mobile/success"
    private var isFetching = false
    private var webView: WKWebView! = nil
    
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.webView = WKWebView(frame: self.view.frame)
        self.view.addSubview(self.webView)
        self.webView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        self.webView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        self.webView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        self.webView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        self.webView.navigationDelegate = self
    }
    
    
    func send() {
        if let requestTokenUrl = requestTokenUrl {
            params["is_mobile"] =  "yes"
            var request = URLRequest(url: requestTokenUrl)
            request.httpMethod = "POST"
            request.httpBody = params.percentEncoded()
            
            let task = URLSession.shared.dataTask(with: request) {(data, response, error) in
                
                guard let data = data else {
                    self.delegate?.paytech(self, didFinishWithStatus: .fail)
                    return
                }
                guard let json = (try? JSONSerialization.jsonObject(with: data, options: [])) as? [String: Any]
                    else {
                        self.dismiss(animated: true, completion: nil)
                        self.delegate?.paytech(self, didFinishWithStatus: .fail)
                        return
                }
                
                if let tokenString = json["redirect_url"] as? String, let tokenUrl = URL(string: tokenString) {
                    
                    let request = URLRequest(url: tokenUrl)
                    DispatchQueue.main.async {

                        self.webView.load(request)
                        
                    }
                    
                } else {
                    self.dismiss(animated: true, completion: nil)
                    self.delegate?.paytech(self, didFinishWithStatus: .fail)
                    return
                }
                
            }
            
            task.resume()
        } else {
            self.dismiss(animated: true, completion: nil)
            self.delegate?.paytech(self, didFinishWithStatus: .fail)
        }
        
        
    }
    
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    
}


protocol PaytechViewControllerDelegate: class {
    func paytech(_ controller: PaytechViewController, didFinishWithStatus status: PaymentStatus)
}



enum PaymentStatus {
    case success
    case fail
    case cancel
}


extension PaytechViewController: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        
        
        print("Navigation:  \(navigationAction.request.url?.absoluteString ?? "")")
        
        if navigationAction.request.url?.absoluteString ==  CANCEL_URL {
            
            self.dismiss(animated: true, completion: nil)
            self.delegate?.paytech(self, didFinishWithStatus: .cancel)
            
        } else if navigationAction.request.url?.absoluteString ==  SUCCESS_URL {
            
            self.dismiss(animated: true, completion: nil)
            self.delegate?.paytech(self, didFinishWithStatus: .success)
            
        }
        
        
        decisionHandler(.allow)
    }
    
}


extension Dictionary {
    func percentEncoded() -> Data? {
        return map { key, value in
            let escapedKey = "\(key)".addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
            let escapedValue = "\(value)".addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
            return escapedKey + "=" + escapedValue
        }
        .joined(separator: "&")
        .data(using: .utf8)
    }
}

extension CharacterSet {
    static let urlQueryValueAllowed: CharacterSet = {
        let generalDelimitersToEncode = ":#[]@" // does not include "?" or "/" due to RFC 3986 - Section 3.4
        let subDelimitersToEncode = "!$&'()*+,;="

        var allowed = CharacterSet.urlQueryAllowed
        allowed.remove(charactersIn: "\(generalDelimitersToEncode)\(subDelimitersToEncode)")
        return allowed
    }()
}
