//
//  QWBooksListCreateLogic.swift
//  Qingwen
//
//  Created by wei lu on 15/12/17.
//  Copyright © 2017 iQing. All rights reserved.
//

import UIKit

class QWCreateBooksListLogic: QWBaseLogic {
    func postNewBooksListWithCompleteBlock(title:String!,intro:String!,url:String,_ completeBlock: QWCompletionBlock?) {
        if !QWGlobalValue.sharedInstance().isLogin() {
            completeBlock?(nil, not_login_error)
            return
        }
        var params =  [NSString: AnyObject]()
        params["title"] = title as AnyObject
        params["intro"] = intro as AnyObject
        let param = QWInterface.getWithUrl(QWOperationParam.currentFAVBooksDomain()+url, params: params) { (aResponseObject, anError) in
            guard let aResponseObject = aResponseObject as? [String: AnyObject], anError == nil else {
                completeBlock?(nil, anError)
                return
            }
            completeBlock?(aResponseObject, anError)
        }
        param!.useV4 = true
        param!.requestType = .post
        self.operationManager.request(with: param)
    }

}

