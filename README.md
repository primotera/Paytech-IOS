# Paytech

[![CI Status](https://img.shields.io/travis/primotera/Paytech.svg?style=flat)](https://travis-ci.org/primotera/Paytech)
[![Version](https://img.shields.io/cocoapods/v/Paytech.svg?style=flat)](https://cocoapods.org/pods/Paytech)
[![License](https://img.shields.io/cocoapods/l/Paytech.svg?style=flat)](https://cocoapods.org/pods/Paytech)
[![Platform](https://img.shields.io/cocoapods/p/Paytech.svg?style=flat)](https://cocoapods.org/pods/Paytech)


## Installation

Paytech is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'Paytech'
```

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.


Import Paytech Module
`import Paytech`

Use `PaytechViewController`  to make a payment.
```swift
let paytechController = PaytechViewController()
paytechController.delegate = self
paytechController.requestTokenUrl = URL(string: "https://sample.paytech.sn/paiement.php")
paytechController.params["item_id"] = 7
paytechController.send() // you can also use send(withCallback:) method
//show The PaytechViewController
present(paytechController, animated: true, completion: nil)
```


## Requirements

IOS 9 +
Swift 4+


## Author

primotera, adiop600@gmail.com

## License

Paytech is available under the MIT license. See the LICENSE file for more info.
