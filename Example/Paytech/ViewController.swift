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
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func pay(_ sender: Any) {
        
        let paytechController = PaytechViewController()
        paytechController.delegate = self
        paytechController.requestTokenUrl = URL(string: "https://sample.paytech.sn/paiement.php")
        paytechController.params["item_id"] = "567"
        paytechController.send()
        
        present(paytechController, animated: true, completion: nil)
        
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
        dismiss(animated: true, completion: nil)
    }
}

