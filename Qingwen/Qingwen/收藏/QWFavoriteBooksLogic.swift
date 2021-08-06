//
//  QWFavoriteBooksLogic.swift
//  Qingwen
//
//  Created by wei lu on 11/12/17.
//  Copyright © 2017 iQing. All rights reserved.
//

import Foundation
import UIKit

class QWFavoriteBooksLogic: QWBaseLogic {
    
    var recommendlistVO:RecommendsBooksListVO?
    var myFavoritelistVO: FavoriteBooksListVO?
    var myCollectionListVO: FavoriteBooksListVO?
    
    func getRecommendsWithCompleteBlock(_ completeBlock: QWCompletionBlock?) {
        let params = [String: AnyObject]()
        let param = QWInterface.getWithUrl(QWOperationParam.currentFAVBooksDomain()+"/favorite/recommend/", params: params) { (aResponseObject, anError) in
            guard let aResponseObject = aResponseObject as? [String: AnyObject], anError == nil else {
                completeBlock?(nil, anError)
                return
            }
            if let dict = aResponseObject["data"] as? [String: AnyObject]{
                let vo = RecommendsBooksListVO.vo(withDict: dict)
                if let vo = vo, let results = self.recommendlistVO?.results, results.count > 0 {
                    self.recommendlistVO?.addResults(withNewPage: vo)
                }
                else {
                    self.recommendlistVO = vo
                }
            }
            
            completeBlock?(self.recommendlistVO, anError)
        }
        param?.useV4 = true
        self.operationManager.request(with: param)
    }
    
    func getFavoriteBooksWithFullParamsCompleteBlock(workId:NSNumber?,workType:NSNumber?,listId:NSNumber?,isOwn:NSNumber?,_ completeBlock: QWCompletionBlock?) {
        var params = [String: AnyObject]()
//        var requestURL = (listId == nil) ? "":("user_id="+(listId?.stringValue)!)
//        requestURL += (isOwn == nil) ? "":("own="+(isOwn?.stringValue)!);
        params["user_id"] = listId
        params["own"] = isOwn
        params["work_id"] = workId
        params["work_type"] = workType
        var url = QWOperationParam.currentFAVBooksDomain() + "/favorite/?"
        if(self.myFavoritelistVO != nil || self.myCollectionListVO != nil)
        {
            if self.myFavoritelistVO?.next != nil{
                url = self.myFavoritelistVO!.next!
            }
            
            if self.myCollectionListVO?.next != nil{
                url = self.myCollectionListVO!.next!
            }
        }
        let param = QWInterface.getWithUrl(url, params: params) { (aResponseObject, anError) in
            if let aResponseObject = aResponseObject as? [String: AnyObject]{
                self.handleResponseObjectV4(aResponseObject, dataBlock: {data in
                    if let vo = FavoriteBooksListVO.vo(withDict: data as? [String : AnyObject]),vo.results.count > 0{
                        
                            if(isOwn == 1){//my book lists
                                if let favList = self.myFavoritelistVO,favList.results.count > 0{
                                    self.myFavoritelistVO?.addResults(withNewPage: vo)
                                }else{
                                    self.myFavoritelistVO = vo
                                }
                                completeBlock?(self.myFavoritelistVO, anError)
                            }else{//my collection
                                if let colList = self.myCollectionListVO,colList.results.count > 0{
                                    self.myCollectionListVO?.addResults(withNewPage: vo)
                                }else{
                                    self.myCollectionListVO = vo
                                }
                                completeBlock?(self.myCollectionListVO, anError)
                            }
                    }else{
                        
                        completeBlock?(nil, anError)
                        
                    }
                })
            }else{
                completeBlock?(nil, anError)
            }
            
        }
        param?.useV4 = true;
        self.operationManager.request(with: param)
    }
    
    func getFavoriteBooksWithCompleteBlock(listId:NSNumber?,isOwn:NSNumber?,_ completeBlock: QWCompletionBlock?) {
        self.getFavoriteBooksWithFullParamsCompleteBlock(workId: nil, workType: nil, listId: listId, isOwn: isOwn, completeBlock)
    }
    
    func isShow() -> Bool {
        return (self.recommendlistVO != nil) || (self.myFavoritelistVO != nil) || (self.myCollectionListVO != nil);
    }
}
