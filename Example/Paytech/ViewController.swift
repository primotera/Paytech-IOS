//
//  ViewController.swift
//  Paytech
//
//  Created by primotera on 04/01/2020.
//  Copyright (c) 2020 primotera. All rights reserved.
//

import UIKit
import Paytech

class ViewController: UIViewController, PaytechViewControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.title = "Paytech Example"
        //navigationController?.isNavigationBarHidden = true
    }

    @IBOutlet weak var statusLabel: UILabel!
    
    @IBOutlet weak var paymentIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var paymentTypeSegmentControl: UISegmentedControl!
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    var isPaymentLoading: Bool {
        set {
            if newValue {
                paymentIndicator.startAnimating()
                statusLabel.text = "En Cours..."
            } else {
                paymentIndicator.stopAnimating()
                statusLabel.text = ""
            }
        }
        
        get {
            return paymentIndicator.isAnimating
        }
        
    }
    
    
    @IBAction func pay(_ sender: Any) {
        
        let paytechController = PaytechViewController()
        paytechController.delegate = self
        paytechController.requestTokenUrl = URL(string: "https://sample.paytech.sn/paiement.php")
        paytechController.params["item_id"] = "567"
        paytechController.send()
        
        if paymentTypeSegmentControl.selectedSegmentIndex == 0 {
            present(paytechController, animated: true, completion: nil)
        } else {
            navigationController?.pushViewController(paytechController, animated: true)
        }
        
        
    }
    
    
    func paytech(_ controller: PaytechViewController, didFinishWithStatus status: PaymentStatus) {
        switch status {
        case .cancel:
            print("Opération annulée")
        case .fail:
            print("Opération échouée")
        case .success:
            print("Opération réussie")
        }
        isPaymentLoading = false
        statusLabel.text = "\(status)"
    }
    
    
    
    func paytech(_ controller: PaytechViewController, isPaymentProcessing: Bool) {
        isPaymentLoading = isPaymentProcessing
    }
    
}


