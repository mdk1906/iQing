//
//  QWPayLogic.swift
//  Qingwen
//
//  Created by Aimy on 3/11/16.
//  Copyright © 2016 iQing. All rights reserved.
//

import UIKit
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


class QWPayLogic: QWBaseLogic {

    var products: ProductPageVO?
    var goldBill: GoldBillPageVO?

    func getPayTypeWithCompleteBlock(_ completeBlock: QWCompletionBlock?) {

        var params = [NSString: AnyObject]()
        params["version"] = QWTracker.sharedInstance().build as AnyObject?
        let url = "\(QWOperationParam.currentPayDomain())/app_version_check/"
        let param = QWInterface.getWithUrl(url, params: params) { (aResponseObject, anError) -> Void in
            if let anError = anError {
                completeBlock?(nil, anError)
                return ;
            }

            if let dict = aResponseObject as? [String: AnyObject] {
                completeBlock?(dict, anError)
            }
        }

        self.operationManager.request(with: param)
    }

    func getProductsUrlWithCompleteBlock(_ completeBlock: QWCompletionBlock?) {
        let url = "\(QWOperationParam.currentPayDomain())/gold/"
        let param = QWInterface.getWithUrl(url, params:[String: AnyObject]()) { (aResponseObject, anError) -> Void in
            if let anError = anError {
                completeBlock?(nil, anError)
                return ;
            }

            if let dict = aResponseObject as? [String: AnyObject] {
                let vo = ProductPageVO.vo(withDict: dict)
                self.products = vo
                completeBlock?(self.products, anError)
            }
        }

        self.operationManager.request(with: param)
    }

    func get3rdProductsUrlWithCompleteBlock(_ completeBlock: QWCompletionBlock?) {
        var params = [String: AnyObject]()
        params["platform"] = 1 as AnyObject?

        #if DEBUG
            params["debug"] = 2 as AnyObject?
        #endif
        let url = "\(QWOperationParam.currentPayDomain())/gold/"
        let param = QWInterface.getWithUrl(url, params:params) { (aResponseObject, anError) -> Void in
            if let anError = anError {
                completeBlock?(nil, anError)
                return ;
            }

            if let dict = aResponseObject as? [String: AnyObject] {
                let vo = ProductPageVO.vo(withDict: dict)
                self.products = vo
                completeBlock?(self.products, anError)
            }
        }

        self.operationManager.request(with: param)
    }

    func pay3rdProduct(_ id: String, completeBlock: QWCompletionBlock?) {
        var params = [String: String]()
        params["token"] = QWGlobalValue.sharedInstance().token
        let url = "\(QWOperationParam.currentPayDomain())/gold/\(id)/pay/"
        let param = QWInterface.getWithUrl(url, params:params) { (aResponseObject, anError) -> Void in
            if let anError = anError {
                completeBlock?(nil, anError)
                return ;
            }

            if let dict = aResponseObject as? [String: AnyObject] {
                completeBlock?(dict, anError)
            }
        }

        param?.requestType = .post
        self.operationManager.request(with: param)
    }
    
    func payPostToServer(_ id: String, completeBlock: QWCompletionBlock?) {
        var params = [String: String]()
        params["token"] = QWGlobalValue.sharedInstance().token
        params["goods_id"] = id;
        params["goods"] = "gold";
        let url = QWOperationParam.currentPayDomain() + "/apple/register_ticket/"
        let param = QWInterface.getWithUrl(url, params:params) { (aResponseObject, anError) -> Void in
            if let anError = anError {
                completeBlock?(nil, anError)
                return ;
            }
            
            if let dict = aResponseObject as? [String: AnyObject] {
                completeBlock?(dict, anError)
            }
        }
        
        param?.requestType = .post
        self.operationManager.request(with: param)
    }
    
    func pay3rdProduct(id: String, platform: String, completeBlock: QWCompletionBlock?) {
        var params = [String: AnyObject]()
        params["token"] = QWGlobalValue.sharedInstance().token as AnyObject?
        params["channel"] = platform as AnyObject?
        params["product_id"] = id as AnyObject?
        let url = "\(QWOperationParam.currentPayDomain())/ping_charge/"
        let param = QWInterface.getWithUrl(url, params:params) { (aResponseObject, anError) -> Void in
            if let anError = anError {
                completeBlock?(nil, anError)
                return ;
            }
            
            if let dict = aResponseObject as? [String: AnyObject] {
                completeBlock?(dict, anError)
            }
        }
        
        param?.requestType = .post
        self.operationManager.request(with: param)
    }

    func valifyReceipt(_ receipt: String ,ticket_uuid:String, completeBlock: QWCompletionBlock?) {
        var params = [String: AnyObject]()
        params["token"] = QWGlobalValue.sharedInstance().token as AnyObject?
        params["data"] = receipt as AnyObject?
        params["ticket_uuid"] = ticket_uuid  as AnyObject?
        
        let url = "\(QWOperationParam.currentPayDomain())/apple/receipt/"
        let param = QWInterface.getWithUrl(url, params:params) { (aResponseObject, anError) -> Void in
            if let anError = anError {
                completeBlock?(nil, anError)
                return ;
            }

            if let dict = aResponseObject as? [String: AnyObject] {
                completeBlock?(dict, anError)
            }
        }

        param?.requestType = .post
        self.operationManager.request(with: param)
    }

    func getHeavyWalletBillWithCompleteBlock(_ completeBlock: QWCompletionBlock?) {

        var params = [NSString: AnyObject]()
        params["token"] = QWGlobalValue.sharedInstance().token as AnyObject?

        let url = "\(QWOperationParam.currentDomain())/user/gold_record/"

        var currentUrl = url;
        if let next = self.goldBill?.next {
            currentUrl = next;
        }

        let param = QWInterface.getWithUrl(currentUrl, params: params) { (aResponseObject, anError) -> Void in
            if let anError = anError {
                completeBlock?(nil, anError)
                return ;
            }

            if let dict = aResponseObject as? [String: AnyObject] {
                let vo = GoldBillPageVO.vo(withDict: dict)
                if let vo = vo , self.goldBill?.results.count > 0 {
                    self.goldBill?.addResults(withNewPage: vo)
                }
                else {
                    self.goldBill = vo
                }

                completeBlock?(self.goldBill, anError)
            }
        }
        
        param?.requestType = .post
        self.operationManager.request(with: param)
    }
}
