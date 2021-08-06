//
//  QWShopLogic.swift
//  Qingwen
//
//  Created by mumu on 16/10/26.
//  Copyright © 2016年 iQing. All rights reserved.
//

import UIKit

class QWShopLogic: QWBaseLogic {

    var goodList: GoodsListVO?
    var propsList:PageVO?
    
    var canuseCount: NSInteger?
    
    var sigelePropsList: SinglePropsList?
    func getGoodsListWithCompleteBlock(completeBlock: QWCompletionBlock?) {
        
        let param = QWInterface.getWithDomainUrl("shop/shop/", params: nil) { (aResponseObject, anError) in
            if let anError = anError {
                completeBlock?(nil, anError)
                
                return
            }
            if let aResponseObject = aResponseObject as? [String: AnyObject]{
                let listVO = GoodsListVO.vo(withDict: aResponseObject)
                self.goodList = listVO
                completeBlock?(self.goodList, anError)
            }
        }
        self.operationManager.request(with: param)
    }
    
    func buyTicketWithGoods(_ goods: GoodsVO, count: NSNumber, completeBlock: QWCompletionBlock?) {
        
        if !QWGlobalValue.sharedInstance().isLogin() {
            completeBlock?(nil, not_login_error)
            return
        }
        var params = [String: AnyObject]()
        params["token"] = QWGlobalValue.sharedInstance().token as AnyObject?
        params["quantity"] = count.stringValue as AnyObject?
        let param = QWInterface.getWithDomainUrl("shop/shop/\(goods.nid!)/buy/", params: params) { (aResponseObject, anError) in
            if let anError = anError {
                completeBlock?(nil, anError)
                return
            }
            if let aResponseObject = aResponseObject {
                completeBlock?(aResponseObject, anError)
            }
        }
        param?.requestType = .post
        self.operationManager.request(with: param)
    }
    
    func getMyPropsListWithCompleteBlock(completeBlock: QWCompletionBlock?) {
        
        var params = [String: AnyObject]()
        params["token"] = QWGlobalValue.sharedInstance().token as AnyObject?
        
        let param = QWInterface.getWithDomainUrl("shop/store/info/", params: params) { (aResponseObject, anError) in
            if let anError = anError {
                completeBlock?(nil, anError)
                
                return
            }
            if let aResponseObject = aResponseObject as? [AnyObject]{
                
                do {
                    let listVO =  try PropsVO.arrayOfModels(fromDictionaries: aResponseObject, error: ())
                    self.propsList = PageVO()
                    self.propsList!.results = listVO as [AnyObject]
                    self.propsList!.count = NSNumber(value: listVO.count)
                    completeBlock?(self.propsList, anError)
                }catch _ {
                    
                }
            }
        }
        param?.requestType = .post
        self.operationManager.request(with: param)
    }
    
    func getMyDetailPropsListWithUrl(url: String, completeBlock: QWCompletionBlock?) {
        if !QWGlobalValue.sharedInstance().isLogin() {
            completeBlock?(nil, not_login_error)
            return
        }
        var params = [String: AnyObject]()
        params["token"] = QWGlobalValue.sharedInstance().token as AnyObject?
        
        var currentUrl = url;
        
        if let next = self.sigelePropsList?.next , next.length > 0 {
            currentUrl = next;
        }
        let param = QWInterface.getWithUrl(currentUrl, params: params) { (aResponseObject, anError) in
            if let anError = anError {
                completeBlock?(nil, anError)
                return
            }
            if let aResponseObject = aResponseObject as? [String: AnyObject] {
                let listVO = SinglePropsList.vo(withDict: aResponseObject)
                
                if let listVO = listVO , self.sigelePropsList != nil {
                    self.sigelePropsList?.addResults(withNewPage: listVO)
                } else {
                    self.sigelePropsList = listVO
                }
                
                completeBlock?(self.sigelePropsList, anError)
            }
        }
        param?.requestType = .post
        self.operationManager.request(with: param)
    }
    
    func getCanUseCountWithCompletBlock(_ completeBlock: QWCompletionBlock?) {
        var params = [String: AnyObject]()
        params["token"] = QWGlobalValue.sharedInstance().token as AnyObject?
        
        let param = QWInterface.getWithDomainUrl("shop/store/can_use_count/", params: params) { (aResponseObject, anError) in
            if let anError = anError {
                completeBlock?(nil, anError)
                return
            }
            if let aResponseObject = aResponseObject as? [String: AnyObject] {
                self.canuseCount = aResponseObject.objectForCaseInsensitiveKey("count")?.integerValue
                completeBlock?(self.canuseCount, anError)
            } else {
                completeBlock?(nil, anError);
            }
        }
        
        param?.requestType = .post
        self.operationManager.request(with: param)
        
    }
}
