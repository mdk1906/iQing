//
//  QWUpLogic.swift
//  Qingwen
//
//  Created by mumu on 17/3/30.
//  Copyright © 2017年 iQing. All rights reserved.
//

import UIKit

class QWUpLogic: QWBaseLogic {
    var listVO: ListVO?
    var category: NSNumber? //1.全站 0.新书
    var channel: QWChannelType?
    //MARK: Up区
    func getUpListWithCompleteBlock(_ completeBlock: QWCompletionBlock?) -> Void {
        
        var params = [String: AnyObject]()
        var url = ""
        
        if let channel = self.channel {
            switch channel {
            case .type10, .type11, .type12,.type13,.type14: //书
                params["channel"] = channel.rawValue as AnyObject
                if let category = category, category.intValue == 0 {
                    url = "book/new_book_rally/" //新书上升
                }
                else {
                    url = "book/gold_book_rally/"//书上升
                }
            case .type99:
//                params["channel"] = channel.rawValue as AnyObject
                if let category = category, category.intValue == 0 {
                    url = "game/lastmonth/" //演绘新作上升
                }
                else {
                    url = "game/awardrallyrank/"//演绘上升
                }
            case .typeNone:
                if let category = category, category.intValue == 0 {
                    url = "book/new_book_rally/" //新书上升
                }
                else {
                    url = "book/gold_book_rally/"//书上升
                }
            }
        }
        else {
            url = "book/gold_book_rally/"
        }
        url =  "\(QWOperationParam.currentDomain())/\(url)"
        
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
                if let vo = vo , let count = self.listVO?.results.count, count > 0 {
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
