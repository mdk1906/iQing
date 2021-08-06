//
//  QWRankingLogic.swift
//  Qingwen
//
//  Created by mumu on 16/8/24.
//  Copyright © 2016年 iQing. All rights reserved.
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


class QWRankingLogic: QWBaseLogic {
    
    var listVO: ListVO?
    
    var channel: QWChannelType?
    
    var rankType: NSNumber? // 1.轻石榜 2.重石榜  3.收藏榜 4.信仰榜 5.战力榜
    var period: NSNumber? //0.日 1.周  2.月
    var category: NSNumber? //1.全站 0.新书
    
    func changeToDay() {
        period = 0
    }
    func changeToWeek() {
        period = 1
    }
    
    func getListWithCompleteBlock(_ completeBlock: QWCompletionBlock?) -> Void {
        
        var params = [String: AnyObject]()
        
        if let channel = self.channel , channel.rawValue > 0{
            params["channel"] = channel.rawValue as AnyObject?
        }
        
            if let period = period {
                params["period"] = period
            } else {
                params["period"] = 0 as AnyObject?
            }
            
            if let category = category {
                params["category"] = category
            }else {
                params["category"] = 1 as AnyObject?
            }
            
            
            if let type = self.rankType{
                params["type"] = type
            } else {
                params["type"] = 4 as AnyObject?
            }
        
        
        
        var url = "\(QWOperationParam.currentDomain())/statistic/book/book_rank/"
        if let next = self.listVO?.next {
            url = next
        }
        
        let param = QWInterface.getWithUrl(url, params: params) { (aResponseObject, anError) in
            if let anError = anError {
                completeBlock?(nil, anError)
                return
            }
            if let aResponseObject = aResponseObject as? [String: AnyObject] {
                let vo = ListVO.vo(withDict: aResponseObject)
                if let vo = vo , self.listVO?.results.count > 0 {
                    self.listVO?.addResults(withNewPage: vo)
                } else {
                    self.listVO = vo
                }
                
                completeBlock?(self.listVO, anError)
            }
            else {
                completeBlock?(nil, anError)
            }
        }
        self.operationManager.request(with: param)

    }
    
}

