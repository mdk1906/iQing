//
//  QWChargeLogic.swift
//  Qingwen
//
//  Created by Aimy on 11/13/15.
//  Copyright © 2015 iQing. All rights reserved.
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


class QWChargeLogic: QWBaseLogic {
    var users: UserPageVO?
    var bill: BillPageVO?

    var user: UserVO?

    var walletBill: WalletBillPageVO?
    var myWallet: MyWalletVO?

    enum BillType {
        case income
        case outlay
    }

    func getPayTypeWithCompleteBlock(_ completeBlock: QWCompletionBlock?) {

        var params = [NSString: String]()
        params["version"] = QWTracker.sharedInstance().build
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

    func getUserChargeWithUrl(_ url: String?, completeBlock: QWCompletionBlock?) {

        var params = [NSString: String]()
        params["token"] = QWGlobalValue.sharedInstance().token

        let param = QWInterface.getWithUrl(url, params: params) { (aResponseObject, anError) -> Void in
            if let anError = anError {
                completeBlock?(nil, anError)
                return ;
            }

            if let dict = aResponseObject as? [String: AnyObject] {
                let user = UserVO.vo(withDict: dict)
                self.user = user
                completeBlock?(self.user, anError)
            }
        }

        param!.requestType = .post
        self.operationManager.request(with: param)
    }

    func getAuthorRankListWithUrl(_ url: String?, useV4:Bool? = false, completeBlock: QWCompletionBlock?) {

        var currentUrl = url;
        if let next = self.users?.next {
            currentUrl = next;
        }

        let param = QWInterface.getWithUrl(currentUrl) { (aResponseObject, anError) -> Void in
            if let anError = anError {
                completeBlock?(nil, anError)
                return ;
            }
            

            
            
            if let dict = aResponseObject as? [String: AnyObject] {
                
                var vo:UserPageVO?
                if(useV4 == true){
                    let dictV4 = dict["data"] as? [String: AnyObject]
                    vo = UserPageVO.vo(withDict: dictV4)
                }else{
                    vo = UserPageVO.vo(withDict: dict)
                }
                if let vo = vo , self.users?.results.count > 0 {
                    self.users?.addResults(withNewPage: vo)
                }
                else {
                    self.users = vo
                }

                completeBlock?(self.users, anError)
            }
        }
        if(useV4 == true){
            param?.useV4 = true
        }
        self.operationManager.request(with: param)
    }

    func getBillWithCompleteBlock(_ completeBlock: QWCompletionBlock?) {

        var params = [NSString: String]()
        params["token"] = QWGlobalValue.sharedInstance().token

        var currentUrl = "\(QWOperationParam.currentDomain())/user/detail/";
        if let next = self.bill?.next {
            currentUrl = next;
        }

        let param = QWInterface.getWithUrl(currentUrl, params: params) { (aResponseObject, anError) -> Void in
            if let anError = anError {
                completeBlock?(nil, anError)
                return ;
            }

            if let dict = aResponseObject as? [String: AnyObject] {
                let vo = BillPageVO.vo(withDict: dict)
                if let vo = vo , self.bill?.results.count > 0 {
                    self.bill?.addResults(withNewPage: vo)
                }
                else {
                    self.bill = vo
                }

                completeBlock?(self.bill, anError)
            }
        }

        param!.requestType = .post
        self.operationManager.request(with: param)
    }

    func getMyWalletWithCompleteBlock(_ completeBlock: QWCompletionBlock?) {

        var params = [NSString: String]()
        params["token"] = QWGlobalValue.sharedInstance().token

        let url = "\(QWOperationParam.currentDomain())/user/wallet/"

        let param = QWInterface.getWithUrl(url, params: params) { (aResponseObject, anError) -> Void in
            if let anError = anError {
                completeBlock?(nil, anError)
                return ;
            }

            if let dict = aResponseObject as? [String: AnyObject] {
                self.myWallet = MyWalletVO.vo(withDict: dict)
                completeBlock?(aResponseObject, anError)
            }
        }

        param!.requestType = .post
        self.operationManager.request(with: param)
    }

    func getWalletBillWithCompleteBlock(_ month: String?,_ year: String?,_ completeBlock: QWCompletionBlock?) {

        var params = [NSString: String]()
        params["token"] = QWGlobalValue.sharedInstance().token
        params["year"] = year
        params["month"] = month
        params["balance"] = "1"
        let url = "\(QWOperationParam.currentDomain())/user/monthlybalance/"

        var currentUrl = url;
        if let next = self.walletBill?.next {
            currentUrl = next;
        }

        let param = QWInterface.getWithUrl(currentUrl, params: params) { (aResponseObject, anError) -> Void in
            if let anError = anError {
                completeBlock?(nil, anError)
                return ;
            }

            if let dict = aResponseObject as? [String: AnyObject] {
                let vo = WalletBillPageVO.vo(withDict: dict)
                if let vo = vo , self.walletBill?.results.count > 0 {
                    self.walletBill?.addResults(withNewPage: vo)
                }
                else {
                    self.walletBill = vo
                }

                completeBlock?(self.walletBill, anError)
            }
        }

        param!.requestType = .post
        self.operationManager.request(with: param)
    }
}
