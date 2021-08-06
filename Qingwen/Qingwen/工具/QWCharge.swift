//
//  QWCharge.swift
//  Qingwen
//
//  Created by mumu on 16/10/11.
//  Copyright © 2016年 iQing. All rights reserved.
//

import UIKit
import StoreKit

class QWCharge: NSObject {
    
    lazy var logic: QWChargeLogic = {
        return QWChargeLogic(operationManager: self.operationManager)
    }()
    
    func doCharge() {
        QWRouter.sharedInstance().rootVC.showLoading()
        self.logic.getPayTypeWithCompleteBlock { (aResponseObject, anError) in
            QWRouter.sharedInstance().rootVC.hideLoading()
            if let _ = anError {
                self.toIAP()
                return
            }
            
            if let dict = aResponseObject as? [String: AnyObject] {
//                if let code = dict["code"] as? Int , code == 0 {
//                    self.showMenu()
//                }
//                else {
                    self.toIAP()
//                }
            }
        }
    }
    func showMenu() {
        let actionSheet = UIActionSheet.bk_actionSheet(withTitle: "") as! UIActionSheet
        actionSheet.bk_addButton(withTitle: "") { () -> Void in
            self.toIAP()
        }
        
        actionSheet.bk_addButton(withTitle: "") { () -> Void in
//            self.to3rd()
        }
        
        actionSheet.bk_setCancelButton(withTitle: "取消") { () -> Void in
            
        }
        
        actionSheet.show(in: QWRouter.sharedInstance().rootVC.view)
    }
    
    func toIAP() {
//        if SKPaymentQueue.canMakePayments() == false {
//            self.showToast(withTitle: "该设备没有支付功能,无法充值", subtitle: nil, type: .alert)
//            return
//        }
        QWRouter.sharedInstance().router(withUrlString: NSString.getRouterVCUrlString(fromUrlString: "charge", andParams: nil))
    }
    
//    func to3rd() {
//        QWRouter.sharedInstance().router(withUrlString: NSString.getRouterVCUrlString(fromUrlString: "charge3", andParams: nil))
//    }
}
