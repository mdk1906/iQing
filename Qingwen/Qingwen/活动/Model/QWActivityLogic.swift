//
//  QWActivityLogic.swift
//  Qingwen
//
//  Created by mumu on 2017/4/25.
//  Copyright © 2017年 iQing. All rights reserved.
//

import UIKit

class QWActivityLogic: QWBaseLogic {

    var activityList: ActivityListVO?
    
    var activityWorkList: ActivityWorkListVO?
    
    var activityDetail: ActivityVO?
    var order:String?
    
    var topic: NSNumber? // 0: 活动  1:专题
    func getActivityListWithCompleteBlock(_ completeBlock: QWCompletionBlock?) {
        var url = "\(QWOperationParam.currentDomain())/activity/"
        if self.topic?.intValue == 1 {
            url = "\(QWOperationParam.currentDomain())/topikku/"
        }
        if let next = self.activityList?.next{
            url = next
        }
        let param = QWInterface.getWithUrl(url) {(aResponseObject, anError) in
            if let anError = anError {
                completeBlock?(nil, anError)
                return
            }
            if let aResponseObject = aResponseObject as? [String: AnyObject] {
                
                let listVO = ActivityListVO.vo(withDict: aResponseObject)
                if let activityList = self.activityList, let vo = listVO {
                    activityList.addResults(withNewPage: vo)
                }
                else {
                    self.activityList = listVO
                }
                completeBlock?(aResponseObject, anError)
            }
            else {
                completeBlock?(nil, anError)
            }
        }
        self.operationManager.request(with: param)
    }
    
    func getWorkListWithUrl(_ url: String, completeBlock: QWCompletionBlock?) {
        var params = [String : AnyObject]()
        if let order = self.order {
            params["order"] = order as AnyObject
        }
        else {
            params["order"] = "belief" as AnyObject
        }
        var url = url
        if let next = self.activityWorkList?.next{
            url = next
        }
        let param = QWInterface.getWithUrl(url, params:params) {(aResponseObject, anError) in
            if let anError = anError {
                completeBlock?(nil, anError)
                return
            }
            if let aResponseObject = aResponseObject as? [String: AnyObject] {
                
                let listVO = ActivityWorkListVO.vo(withDict: aResponseObject)
                if let workList = self.activityWorkList, let vo = listVO {
                    workList.addResults(withNewPage: vo)
                }
                else {
                    self.activityWorkList = listVO
                }
                completeBlock?(aResponseObject, anError)
            }
            else {
                completeBlock?(nil, anError)
            }
        }
        self.operationManager.request(with: param)
    }
    
    func getActivityDetailWithUrl(_ url: String, completeBlock: QWCompletionBlock?) {
        let param = QWInterface.getWithUrl(url) {(aResponseObject, anError) in
            if let anError = anError {
                completeBlock?(nil, anError)
                return
            }
            if let aResponseObject = aResponseObject as? [String: AnyObject] {
                
                let vo = ActivityVO.vo(withDict: aResponseObject)
                self.activityDetail = vo
                completeBlock?(aResponseObject, anError)
            }
            else {
                completeBlock?(nil, anError)
            }
        }
        self.operationManager.request(with: param)
    }
}
