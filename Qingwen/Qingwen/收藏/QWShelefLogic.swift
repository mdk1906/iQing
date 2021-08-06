//
//  QWAttentionLogic.swift
//  Qingwen
//
//  Created by mumu on 17/4/1.
//  Copyright © 2017年 iQing. All rights reserved.
//

import UIKit

class QWShelefLogic: QWBaseLogic {
    
    var listVO: AttentionListVO?
    
    func getAttentionWithCompleteBlock(_ completeBlock: QWCompletionBlock?) {
        guard var bookShelfUrl = QWGlobalValue.sharedInstance().user?.bookshelf_url else {
            return
        }
        var params = [String: AnyObject]()
        params["new"] = 1 as AnyObject
        if let next = self.listVO?.next {
            bookShelfUrl = next
        }
        
        let param = QWInterface.getWithUrl(bookShelfUrl, params: params) { (aResponseObject, anError) in
            guard let aResponseObject = aResponseObject as? [String: AnyObject], anError == nil else {
                completeBlock?(nil, anError)
                return
            }
            let vo = AttentionListVO.vo(withDict: aResponseObject)
            if let vo = vo, let results = self.listVO?.results, results.count > 0 {
                self.listVO?.addResults(withNewPage: vo)
            }
            else {
                self.listVO = vo
            }
            
            completeBlock?(self.listVO, anError)
        }
        param?.useOrigin = true
        self.operationManager.request(with: param)
    }
}
