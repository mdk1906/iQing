//
//  QWPayManager.swift
//  Qingwen
//
//  Created by Aimy on 3/17/16.
//  Copyright © 2016 iQing. All rights reserved.
//

import UIKit
import StoreKit

class QWPayManager: NSObject {

    private static var __once: () = {
            Static.staticInstance = QWPayManager()
        }()
    
    struct Static {
        static var onceToken : Int = 0
        static var staticInstance : QWPayManager? = nil
    }
    
    class var sharedManager : QWPayManager {

        _ = QWPayManager.__once

        return Static.staticInstance!
    }

    lazy var logic: QWPayLogic = {
        return QWPayLogic(operationManager: self.operationManager)
    }()

    var produtRequest: SKProductsRequest?

    fileprivate override init() {
        super.init()
        SKPaymentQueue.default().add(self)
    }

    deinit {
        SKPaymentQueue.default().remove(self)
        produtRequest?.cancel()
    }

    func checkOrder() {

    }
}

extension QWPayManager: SKProductsRequestDelegate {
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        let skProducts = response.products
        for skProduct in skProducts {
            NSLog("\(skProduct.localizedTitle), \(skProduct.localizedDescription), \(skProduct.price), \(skProduct.productIdentifier)")
            let payment = SKMutablePayment(product: skProduct)
            if let userId = QWGlobalValue.sharedInstance().user?.nid {
                payment.applicationUsername = userId.stringValue
            }
            SKPaymentQueue.default().add(payment)
            return
        }
        self.showToast(withTitle: "获取商品失败", subtitle: nil, type: .error)
    }
}

extension QWPayManager: SKPaymentTransactionObserver {

    func completeTransaction(_ transaction: SKPaymentTransaction) {
        self.valifyReceipt(transaction)
        NSLog("applicationUsername = \(String(describing: transaction.payment.applicationUsername))")
    }

    func valifyReceipt(_ transaction:SKPaymentTransaction) {
        // 验证凭据，获取到苹果返回的交易凭据
        // appStoreReceiptURL iOS7.0增加的，购买交易完成后，会将凭据存放在该地址
        let receiptURL = Bundle.main.appStoreReceiptURL
        // 从沙盒中获取到购买凭据
        let receiptData = try? Data(contentsOf: receiptURL!)

        if let encodeStr = (receiptData as NSData?)?.base64EncodedString() {
            //            requestPaymentValifyreceipt(encodeStr)
            NSLog("encodeStr = \(encodeStr)")
        } else {
            /* No local receipt -- handle the error. */

        }

//        SKPaymentQueue.defaultQueue().finishTransaction(transaction)
    }

    //回执验证
    func requestPaymentValifyreceipt(_ receipt:String!){
        let queue = DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.background)
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        queue.async(execute: {
            () -> Void in
            autoreleasepool{
                () -> () in

                //测试直接向苹果服务器发送数据
                let dic = NSDictionary(object: receipt, forKey: "receipt-data" as NSCopying)
                let sendData = try? JSONSerialization.data(withJSONObject: dic, options: JSONSerialization.WritingOptions())
                let sendDataString = String(data: sendData!, encoding: String.Encoding.utf8)
                print("sendDataString == \(String(describing: sendDataString))")
                let request = NSMutableURLRequest(url: URL(string: "https://sandbox.itunes.apple.com/verifyReceipt")!)
                request.httpMethod = "POST"
                request.httpBody = sendData
                let data = try? NSURLConnection.sendSynchronousRequest(request as URLRequest, returning: nil)

                if let data = data {
                    let returnStr = (data as NSData).base64EncodedString()
                    NSLog("returnStr = \(returnStr)")
                }
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        })
    }

    func recordTransaction(_ product: String) {

    }

    func provideContent(_ product: String) {

    }

    func failedTransaction(_ transaction: SKPaymentTransaction) {
        if let error = transaction.error {
            NSLog(error.localizedDescription)
        }
        SKPaymentQueue.default().finishTransaction(transaction)
    }

    func restoreTransaction(_ transaction: SKPaymentTransaction) {
        SKPaymentQueue.default().finishTransaction(transaction)
    }

    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchasing:
                NSLog("Purchasing")
                break
            case .purchased:
                NSLog("Purchased")
                self.completeTransaction(transaction)
                break
            case .failed:
                NSLog("Failed")
                self.failedTransaction(transaction)
                break
            case .restored:
                NSLog("Restored")
                self.restoreTransaction(transaction)
                break
            default:
                NSLog("\(transaction.transactionState)")
                break
            }
        }
    }

    func paymentQueue(_ queue: SKPaymentQueue, removedTransactions transactions: [SKPaymentTransaction]) {
        NSLog("queue \(queue), removedTransactions \(transactions)")
    }
}
