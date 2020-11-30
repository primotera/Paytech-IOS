
//
//  PaytechViewController.swift
//  Paytech_Example
//
//  Created by Làye DIOP on 01/04/2020.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit
import WebKit

@objc public class PaytechViewController: UIViewController , WKNavigationDelegate {
    
    @objc public var requestTokenUrl: URL?
    public var delegate: PaytechViewControllerDelegate?
    var tokenUrl: URL?
    @objc public var params: NSMutableDictionary = NSMutableDictionary()
    private let CANCEL_URL = "https://paytech.sn/mobile/cancel"
    private let SUCCESS_URL = "https://paytech.sn/mobile/success"
    private var _isPayementProcessing = false
    @objc var isPaymentProcessing: Bool  {
        get {
            return self._isPayementProcessing
        }
    }
    private var webView: WKWebView! = nil
    private var currentCallBack: ((String) -> Void)?
    
    
    public init() {
        super.init(nibName: nil, bundle: nil)
        self.webView = WKWebView(frame: self.view.frame)
        self.view.addSubview(self.webView)
        self.webView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        self.webView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        self.webView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        self.webView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        self.webView.navigationDelegate = self
        self.webView.configuration.userContentController.add(self, name: WebEvent.openDial.rawValue)
        self.webView.configuration.userContentController.add(self, name: WebEvent.onPaymentStart.rawValue)
        self.webView.configuration.userContentController.add(self, name: WebEvent.openUrl.rawValue)
        print("PaytechViewController is On")
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
    }
    
    public override func viewDidDisappear(_ animated: Bool) {
        if !isPaymentProcessing {
            self.responseWith(status: .cancel)
        }
    }
    
    @objc public func send(withCallback callback: ((String) -> Void)? = nil) {
        if let requestTokenUrl = requestTokenUrl {
            self.currentCallBack = callback
            params["is_mobile"] =  "yes"
            var request = URLRequest(url: requestTokenUrl)
            request.httpMethod = "POST"
            request.httpBody = params.percentEncoded()
            
            let task = URLSession.shared.dataTask(with: request) {(data, response, error) in
                
                guard let data = data else {
                    self.responseWith(status: .fail)
                    return
                }
                guard let json = (try? JSONSerialization.jsonObject(with: data, options: [])) as? [String: Any]
                    else {
                        self.responseWith(status: .fail)
                        return
                }
                
                if let tokenString = json["redirect_url"] as? String, let tokenUrl = URL(string: tokenString) {
                    
                    let request = URLRequest(url: tokenUrl)
                    DispatchQueue.main.async {
                        
                        self.webView.load(request)
                        
                    }
                    
                } else {
                    
                    DispatchQueue.main.async {
                        self.responseWith(status: .fail)
                    }
                    return
                }
                
            }
            task.resume()
        } else {
            self.responseWith(status: .fail)
        }
        
        
    }
    
    enum WebEvent: String {
        case onPaymentStart
        case openDial
        case openUrl
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    deinit {
        print("PaytechController is off")
    }
    
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        if navigationAction.request.url?.absoluteString ==  CANCEL_URL {
            
            self.responseWith(status: .cancel)
            
        } else if navigationAction.request.url?.absoluteString ==  SUCCESS_URL {
            self.responseWith(status: .success)
            
        }
        
        decisionHandler(.allow)
    }
    
    
    private func responseWith(status: PaymentStatus) {
        self.delegate?.paytech(self, didFinishWithStatus: status)
        self.currentCallBack?(status.rawValue)
        self.navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
        self.currentCallBack = nil
    }
    
}


public protocol PaytechViewControllerDelegate: class {
    func paytech(_ controller: PaytechViewController, didFinishWithStatus status: PaymentStatus)
    func paytech(_ controller: PaytechViewController, isPaymentProcessing: Bool)
}
public extension PaytechViewControllerDelegate {
    func paytech(_ controller: PaytechViewController, isPaymentProcessing: Bool) {}
}


public enum PaymentStatus: String {
    case success
    case fail
    case cancel
}



extension NSMutableDictionary {
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


extension PaytechViewController: WKScriptMessageHandler {
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        
        if let event = WebEvent(rawValue: message.name) {
            switch event {
                
            case .onPaymentStart:
                _isPayementProcessing = true
                delegate?.paytech(self, isPaymentProcessing: _isPayementProcessing)
            case .openDial:
                let phone = "tel://\((message.body as? String) ?? "")"
                if let url = URL(string: (phone).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "") {
                    UIApplication.shared.openURL(url)
                } else {
                    print("PaytechViewController can't open URL ", message.body)
                }
                
            case .openUrl:
                if let url = URL(string: ((message.body as? String) ?? "").addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "") {
                    UIApplication.shared.openURL(url)
                } else {
                    print("PaytechViewController can't open URL ", message.body)
                }
            }
        }
    }
}
