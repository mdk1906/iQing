//
//  QWBookListsDetailsLogic.swift
//  Qingwen
//
//  Created by wei lu on 22/12/17.
//  Copyright © 2017 iQing. All rights reserved.
//

import UIKit

class QWGetBookslistDetailsLogic: QWBaseLogic {
    var headerData:FavoriteBooksVO?
    var bookList: FavoriteBooksInListVO?
    var faithPointsPage:UserPageVO?
    var awardDymicPageVO:UserPageVO?
    var bfCount:NSNumber?
    var bfUpdate:NSDate?
    
    
    func setBookOrderWithCompleteBlock(listId:NSNumber!,order:String?, _ completeBlock: QWCompletionBlock?) {
        var params = [String: AnyObject]()
        if var req = order {
             params["order"] = req as AnyObject?
        }else{
            return self.showToast(withTitle: "排序失败", subtitle: nil, type: .alert)
        }
       
        let param = QWInterface.getWithUrl(QWOperationParam.currentFAVBooksDomain()+"/favorite/"+listId!.stringValue+"/order/", params: params) { (aResponseObject, anError) in
            guard let aResponseObject = aResponseObject as? [String: AnyObject], anError == nil else {
                completeBlock?(nil, anError)
                return
            }
            
            guard let code = aResponseObject["code"] as? Int , code == 0 else {
                guard let msg = aResponseObject["msg"] as? String else {
                    self.showToast(withTitle: "失败", subtitle: nil, type: .alert)
                    return
                }
                self.showToast(withTitle: msg, subtitle: nil, type: .alert)
                completeBlock?(nil, anError)
                return
            }
            self.showToast(withTitle: "排序成功", subtitle: nil, type: .alert)
            completeBlock?(aResponseObject, anError)
        }
        param?.useV4 = true
        param?.requestType = .post
        self.operationManager.request(with: param)
    }
    
    
    func getbookListDetailsWithCompleteBlock(listId:NSNumber!,_ completeBlock: QWCompletionBlock?) {
        let params = [String: AnyObject]()
        let param = QWInterface.getWithUrl(QWOperationParam.currentFAVBooksDomain()+"/favorite/"+listId!.stringValue+"/", params: params) { (aResponseObject, anError) in
            guard let aResponseObject = aResponseObject as? [String: AnyObject], anError == nil else {
                completeBlock?(nil, anError)
                return
            }
            
            guard let code = aResponseObject["code"] as? Int , code == 200 else {
                guard let msg = aResponseObject["msg"] as? String else {
                    self.showToast(withTitle: "失败", subtitle: nil, type: .alert)
                    return
                }
                self.showToast(withTitle: msg, subtitle: nil, type: .alert)
                completeBlock?(nil, anError)
                return
            }
            self.handleResponseObjectV4(aResponseObject, dataBlock: {data in
                if let vo = FavoriteBooksVO.vo(withDict: data as? [String : Any]){
                    self.headerData = vo
                }
                completeBlock?(self.headerData, anError)
            })
        }
        param?.useV4 = true
        self.operationManager.request(with: param)
    }
    
    func getbookListWithCompleteBlock(listId:NSNumber?,_ completeBlock: QWCompletionBlock?){
        if(listId == nil){
            completeBlock?(nil, nil)
            return
        }
        let params = [String: AnyObject]()
        var url = QWOperationParam.currentFAVBooksDomain() + "/favorite/"+listId!.stringValue+"/work/?offset=0&limit=10"
        if (self.bookList?.next != nil) {
            url = self.bookList!.next!;
        }
        let param = QWInterface.getWithUrl(url, params: params) { (aResponseObject, anError) in
            guard let aResponseObject = aResponseObject as? [String: AnyObject], anError == nil else {
                completeBlock?(nil, anError)
                return
            }
            
            guard let code = aResponseObject["code"] as? Int , code == 200 else {
                guard let msg = aResponseObject["msg"] as? String else {
                    self.showToast(withTitle: "失败", subtitle: nil, type: .alert)
                    return
                }
                self.showToast(withTitle: msg, subtitle: nil, type: .alert)
                completeBlock?(nil, anError)
                return
            }
            self.handleResponseObjectV4(aResponseObject, dataBlock: {data in
                if let vo = FavoriteBooksInListVO.vo(withDict: data as? [String : Any]),vo.results.count > 0{
                    if let list = self.bookList,list.results.count > 0{
                        self.bookList?.addResults(withNewPage: vo)
                    }else{
                        self.bookList = vo
                    }
                }
                
                completeBlock?(self.bookList, anError)
                
            })
        }
        param?.useV4 = true
        self.operationManager.request(with: param)
    }
    
    func addBookListsCollectionWithCompleteBlock(listId:NSNumber?,_ completeBlock: QWCompletionBlock?) {
        if(listId == nil || self.headerData?.can_add == nil){
            self.showToast(withTitle: "找不到相关信息", subtitle: nil, type: .alert)
            return
        }
        if (self.headerData?.can_add!.boolValue == false){
            self.showToast(withTitle: "不能添加此书单", subtitle: nil, type: .alert)
            return
        }
        let params = [String: AnyObject]()
        
        var url = "/favorite/"+listId!.stringValue
        url += (self.headerData!.subscribe!.boolValue == false) ? "/subscribe/" : "/unsubscribe/"
        
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
    
    func getFaithPointBlock(listId:NSNumber?,_ completeBlock: QWCompletionBlock?){
        if(listId == nil){
            completeBlock?(nil, nil)
            return
        }
        let params = [String: AnyObject]()
        let url = "/favorite/"+listId!.stringValue+"/points/"
        let param = QWInterface.getWithUrl(QWOperationParam.currentFAVBooksDomain()+url, params: params) { (aResponseObject, anError) in
            guard let aResponseObject = aResponseObject as? [String: AnyObject], anError == nil else {
                completeBlock?(nil, anError)
                return
            }
            
            if let dict = aResponseObject["data"] as? [String: AnyObject]{
                let vo = UserPageVO.vo(withDict: dict)
                if let vo = vo , let cnt = self.faithPointsPage?.results?.count,cnt > 0 {
                    self.faithPointsPage?.addResults(withNewPage: vo)
                }
                else {
                    self.faithPointsPage = vo
                }
                
                completeBlock?(self.faithPointsPage, anError)
            }
            
        }
        param?.useV4 = true
        self.operationManager.request(with: param)
    }
    
    func getAwardsLatestBlock(listId:NSNumber?,_ completeBlock: QWCompletionBlock?){
        if(listId == nil){
            completeBlock?(nil, nil)
            return
        }
        let params = [String: AnyObject]()
        let url = "/favorite/"+listId!.stringValue+"/award_new_feed/"
        let param = QWInterface.getWithUrl(QWOperationParam.currentFAVBooksDomain()+url, params: params) { (aResponseObject, anError) in
            guard let aResponseObject = aResponseObject as? [String: AnyObject], anError == nil else {
                completeBlock?(nil, anError)
                return
            }
            
            if let dict = aResponseObject["data"] as? [String: AnyObject]{
                let vo = UserPageVO.vo(withDict: dict)
                if let vo = vo , let cnt = self.awardDymicPageVO?.results?.count,cnt > 0 {
                    self.awardDymicPageVO?.addResults(withNewPage: vo)
                }
                else {
                    self.awardDymicPageVO = vo
                }
                
                completeBlock?(self.awardDymicPageVO, anError)
            }
            
        }
        param?.useV4 = true
        self.operationManager.request(with: param)
    }
    
    func getBFDetailsBlock(bf_url:NSString?,_ completeBlock: QWCompletionBlock?){
        if(bf_url == nil){
            completeBlock?(nil, nil)
            return
        }
        let params = [String: AnyObject]()
        let param = QWInterface.getWithUrl(bf_url! as String, params: params) { (aResponseObject, anError) in
            guard let aResponseObject = aResponseObject as? [String: AnyObject], anError == nil else {
                completeBlock?(nil, anError)
                return
            }
            if aResponseObject["bf_count"] == nil {
                
            }
            else{
                self.bfCount = aResponseObject["bf_count"] as? NSNumber
            }
            if  aResponseObject["last_post"] == nil  {
                
            }
            else{
                let date = aResponseObject["last_post"] as! NSNumber
                self.bfUpdate = NSDate(timeIntervalSince1970: TimeInterval(date.intValue))
            }
            
            
            completeBlock?(aResponseObject, anError)
        }
        self.operationManager.request(with: param)
    }
    
    func isShow() -> Bool {
        return  (self.bookList != nil)&&(self.headerData != nil);
    }
}
