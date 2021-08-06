//
//  QWChargeVC.swift
//  Qingwen
//
//  Created by Aimy on 3/11/16.
//  Copyright © 2016 iQing. All rights reserved.
//

import UIKit

import StoreKit
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


extension QWChargeVC {
    override class func registMapping() {
        let vo = QWMappingVO()
        vo.className = NSStringFromClass(self)
        vo.storyboardName = "QWWallet"
        vo.storyboardID = "pay"
        QWRouter.sharedInstance().register(vo, withKey: "charge")
    }
}

class QWChargeVC: QWBaseVC {

    lazy var logic: QWPayLogic = {
        return QWPayLogic(operationManager: self.operationManager)
    }()

    @IBOutlet var contentView: UIView!
    @IBOutlet var scrollView: UIScrollView!

    var produtRequest: SKProductsRequest?

    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var accountLabel: UILabel!
    @IBOutlet var payView: UIView!

    @IBOutlet var priceLabel: UILabel!
    @IBOutlet var payBtn: UIButton!

    @IBOutlet var priceViews: [QWChargeButton]!
    var currentPriceView: QWChargeButton?
    
    var payKey: String?
    
    override func resize(_ size: CGSize) {
        var frame = self.contentView.frame
        frame.size.width = size.width
        self.contentView.frame = frame
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        var frame = self.contentView.frame
        frame.size.width = self.view.bounds.size.width
        self.contentView.frame = frame
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.resize(CGSize(width: QWSize.screenWidth(), height: QWSize.screenHeight()))
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        payKey = ""
        self.scrollView.addSubview(self.contentView)

        if SWIFT_IS_IPHONE_DEVICE {
            self.payView.autoSetDimension(.width, toSize: QWSize.screenWidth() / 320 * 300)
        }
        else {
            self.payView.autoSetDimension(.width, toSize: 400)
        }

        if self.contentView.bounds.size.height > self.view.bounds.size.height {
            self.scrollView.contentSize = CGSize(width: QWSize.screenWidth(), height: self.contentView.bounds.size.height)
        }
        else {
            self.scrollView.contentSize = CGSize(width: QWSize.screenWidth(), height: self.view.bounds.size.height)
        }

        self.fd_interactivePopDisabled = true

        if let username = QWGlobalValue.sharedInstance().username {
            self.nameLabel.text = "充值账户: \(username)"
        }
        
        if let gold = QWGlobalValue.sharedInstance().user?.gold {
            self.accountLabel.text = "账户余额: \(gold)重石"
        }

        priceViews = priceViews.sorted(by: { $0.tag < $1.tag })

        self.getData()
    }

    deinit {
        SKPaymentQueue.default().remove(self)
        produtRequest?.cancel()
    }

    override func getData() {
        self.showLoading()
        self.logic.getProductsUrlWithCompleteBlock { (aResponseObject, anError) -> Void in
            self.updateUI()
            self.hideLoading()
            SKPaymentQueue.default().add(self)
            if SKPaymentQueue.default().transactions.count > 0 {
                self.showLoading()
            }
        }
    }

    func updateUI() {
        for view in priceViews {
            if view.tag + 1 > self.logic.products?.results.count {
                view.updateWithProduct(nil)
            }
            else {
                view.updateWithProduct(self.logic.products?.results[view.tag] as? ProductVO)
            }
        }
    }

    func getProduct(_ id: String) {
        self.showLoading()
        produtRequest?.cancel()
        produtRequest = SKProductsRequest(productIdentifiers: Set([id]))
        produtRequest?.delegate = self
        produtRequest?.start()
    }

    @IBAction func onPressedPriceBtn(_ sender: QWChargeButton) {
        if let product = self.logic.products?.results[sender.tag] as? ProductVO {
            self.currentPriceView?.isSelected = false
            self.currentPriceView = sender
            self.currentPriceView?.isSelected = true
            self.priceLabel.text = product.currency?.stringValue
            self.payBtn.isEnabled = product.currency?.floatValue > 0
        }
    }

    @IBAction func onPressedPayBtn(_ sender: AnyObject) {
        if QWGlobalValue.sharedInstance().isLogin() == false {
            QWRouter.sharedInstance().routerToLogin()
            return;
        }

        guard let currentPriceView = self.currentPriceView else {
            return
        }

        guard let product = self.logic.products?.results[currentPriceView.tag] as? ProductVO, let nid = product.nid else {
            return
        }
        self.logic .payPostToServer(nid.stringValue) { (aResponseObject, anError) -> Void in
            if let dict = aResponseObject as? [String: AnyObject] {
                let code = dict["code"] as? Int
                if code == 0{
                    let data = dict["data"] as? [String : AnyObject]
                    self.payKey = data?["ticket_uuid"] as? String
                    print(self.payKey as? String)
                }
                
            }
        }
        
        self.getProduct(nid.stringValue)
    }

    func doCharge(_ receipt: String, _ transaction: SKPaymentTransaction) {
        self.logic.valifyReceipt(receipt ,ticket_uuid: self.payKey!) { (aResponseObject, anError) -> Void in
            self.hideLoading()
            if let _ = anError {
                self.reValifyReceipt(transaction)
                return ;
            }

            if let dict = aResponseObject as? [String: AnyObject] {
                guard let code = dict["code"] as? Int , code == 0 else {
                    guard let data = dict["data"] as? String else {
                        self.reValifyReceipt(transaction)
                        return
                    }
                    self.showToast(withTitle: data, subtitle: nil, type: .alert)
                    self.reValifyReceipt(transaction)
                    return
                }
            }

            self.performSegue(withIdentifier: "success", sender: transaction)
            SKPaymentQueue.default().finishTransaction(transaction)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "success" {
            let vc = segue.destination as! QWPaySuccessVC
            guard let transaction = sender as? SKPaymentTransaction else {
                return
            }

            guard let products = self.logic.products?.results as? [ProductVO] else {
                return
            }

            let product = products.filter({ (product) -> Bool in
                 return product.nid!.stringValue == transaction.payment.productIdentifier
            }).first

            vc.product = product;
        }
    }

    func reValifyReceipt(_ transaction: SKPaymentTransaction) {
        let alertView = UIAlertView.bk_alertView(withTitle: "验证购买回执失败, 是否重试?") as! UIAlertView
        alertView.bk_setCancelButton(withTitle: "取消") { () -> Void in

        }

        alertView.bk_addButton(withTitle: "重试") { () -> Void in
            self.showLoading()
            self.valifyReceipt(transaction)
        }
        alertView.show()
    }
}

extension QWChargeVC: SKProductsRequestDelegate {
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        guard let currentPriceView = self.currentPriceView else {
            return
        }

        guard let product = self.logic.products?.results[currentPriceView.tag] as? ProductVO, let nid = product.nid else {
            return
        }

        let skProducts = response.products
        for skProduct in skProducts {
            NSLog("localizedTitle \(skProduct.localizedTitle), localizedDescription \(skProduct.localizedDescription), price \(skProduct.price), productIdentifier \(skProduct.productIdentifier)")
            if skProduct.productIdentifier == nid.stringValue {
                let payment = SKMutablePayment(product: skProduct)
                if let userId = QWGlobalValue.sharedInstance().user?.nid {
                    payment.applicationUsername = userId.stringValue
                }
                SKPaymentQueue.default().add(payment)
                return
            }
        }
        self.showToast(withTitle: "获取商品失败", subtitle: nil, type: .error)
        self.hideLoading()
    }
}

extension QWChargeVC: SKPaymentTransactionObserver {

    func completeTransaction(_ transaction: SKPaymentTransaction) {
        self.valifyReceipt(transaction)
        NSLog("applicationUsername = \(String(describing: transaction.payment.applicationUsername))")
    }

    func valifyReceipt(_ transaction: SKPaymentTransaction) {
        // 验证凭据，获取到苹果返回的交易凭据
        // appStoreReceiptURL iOS7.0增加的，购买交易完成后，会将凭据存放在该地址
        let receiptURL = Bundle.main.appStoreReceiptURL
        // 从沙盒中获取到购买凭据
        let receiptData = try? Data(contentsOf: receiptURL!)

        if let encodeStr = (receiptData as NSData?)?.base64EncodedString() {
            self.doCharge(encodeStr, transaction)
//            #if DEBUG
//                self.requestPaymentValifyreceipt(encodeStr);
//            #endif
            NSLog("encodeStr = \(encodeStr)")
        }
        else {
            self.hideLoading()
            self.reValifyReceipt(transaction)
        }
    }

    //回执验证
    func requestPaymentValifyreceipt(_ receipt: String!){
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
                #if DEBUG
                    let url = "https://sandbox.itunes.apple.com/verifyReceipt"
                #else
                    let url = "https://buy.itunes.apple.com/verifyReceipt"
                #endif
                let request = NSMutableURLRequest(url: URL(string: url)!)
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
        self.hideLoading()
        if let error = transaction.error as NSError?{
            NSLog(error.description)
        }
        SKPaymentQueue.default().finishTransaction(transaction)
    }

    func restoreTransaction(_ transaction: SKPaymentTransaction) {
        self.hideLoading()
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

