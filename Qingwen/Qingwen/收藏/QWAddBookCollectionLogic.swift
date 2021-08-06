//
//  QWAddBookCollectionLogic.swift
//  Qingwen
//
//  Created by wei lu on 1/01/18.
//  Copyright © 2018 iQing. All rights reserved.
//

import UIKit

class QWAddBookCollectionLogic: QWBaseLogic {
    var collections:FavoriteBooksListVO?
    func addtoMyCollectionLists(collectionID:NSNumber!,workType:NSNumber!,recommend:NSString!,workId:NSString!,_ completeBlock: QWCompletionBlock?) {
        if !QWGlobalValue.sharedInstance().isLogin() {
            completeBlock?(nil, not_login_error)
            return
        }
        
        var params =  [NSString: AnyObject]()
        params["work_type"] = workType
        params["recommend"] = recommend as NSString
        params["work_id"] = workId
        
        let param = QWInterface.getWithUrl(QWOperationParam.currentFAVBooksDomain()+"/favorite/"+collectionID.stringValue+"/add/", params: params) { (aResponseObject, anError) in
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
    
    func removeBookListsCollection(collectionID:NSNumber!,workId:NSString!,workType:NSNumber!,_ completeBlock: QWCompletionBlock?) {
        if !QWGlobalValue.sharedInstance().isLogin() {
            completeBlock?(nil, not_login_error)
            return
        }
        var params = [String: AnyObject]()
        params["work_type"] = workType
        params["work_id"] = workId
        
        var url = "/favorite/"+(collectionID.stringValue)
        url += "/remove/"
        
        let param = QWInterface.getWithUrl(QWOperationParam.currentFAVBooksDomain()+url, params: params) { (aResponseObject, anError) in
            guard let aResponseObject = aResponseObject as? [String: AnyObject], anError == nil else {
                completeBlock?(nil, anError)
                return
            }
            
            completeBlock?(aResponseObject, anError)
            
        }
        param?.useV4 = true
        param?.requestType = .post
        self.operationManager.request(with: param)
    }
    
    func modifyMyrecommend(recommend:NSString!,workId:NSNumber!,_ completeBlock: QWCompletionBlock?) {
        if !QWGlobalValue.sharedInstance().isLogin() {
            completeBlock?(nil, not_login_error)
            return
        }
        
        var params =  [NSString: AnyObject]()
        params["recommend"] = recommend as AnyObject
        
        let param = QWInterface.getWithUrl(QWOperationParam.currentFAVBooksDomain()+"/favorite/item/"+workId.stringValue+"/change/", params: params) { (aResponseObject, anError) in
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
    
    func deleteBookFormList(workId:NSNumber!,_ completeBlock: QWCompletionBlock?) {
        if !QWGlobalValue.sharedInstance().isLogin() {
            completeBlock?(nil, not_login_error)
            return
        }
        
        let params =  [NSString: AnyObject]()
        
        let param = QWInterface.getWithUrl(QWOperationParam.currentFAVBooksDomain()+"/favorite/item/"+workId.stringValue+"/delete/", params: params) { (aResponseObject, anError) in
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
