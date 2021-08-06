//
//  QWLocalPictures.swift
//  Qingwen
//
//  Created by mumu on 2017/9/22.
//  Copyright © 2017年 iQing. All rights reserved.
//

import UIKit

class QWOtherLogic:QWBaseLogic  {
    func getMaskTypeWithCompleteBlock(_ completeBlock: QWCompletionBlock?) {
        
        var params = [NSString: AnyObject]()
        params["version"] = QWTracker.sharedInstance().build as AnyObject?
        let url = "\(QWOperationParam.currentPayDomain())/app_version_check/"
        let param = QWInterface.getWithUrl(url, params: params) { (aResponseObject, anError) -> Void in
            if let anError = anError {
                completeBlock?(nil, anError)
                return ;
            }
            
            if let dict = aResponseObject as? [String: AnyObject] {
                completeBlock?(dict, anError)
            }
        }
        
        self.operationManager.request(with: param)
    }
}

class QWLocalPictures: NSObject {
    static let sharedInstance = QWLocalPictures()
    
    private var mask = false
    private var pictureUrl = [String]()
    let loacalUrl = "https://image.iqing.in/cover/ccf22d64-c381-487e-890d-bdde38d7ec58.jpg?"
    
    lazy var logic: QWOtherLogic = {
        return QWOtherLogic(operationManager: self.operationManager)
    }()
    
    func checkBuildVersion() {
        self.logic.getMaskTypeWithCompleteBlock { (aResponseObject, anError) in
            if let _ = anError {
                self.mask = false
                return
            }
            
            if let dict = aResponseObject as? [String: AnyObject] {
                if let code = dict["code"] as? Int , code == 0 {
                    self.mask = false
                }
                else {
                    self.mask = true
                }
            }
        }
        self.getPictureList()
    }
    
    func getPictureList() {
        if let path = Bundle.main.path(forResource: "pictures", ofType: "txt"){
            let picturesString = try! String(contentsOfFile: path)
            pictureUrl = picturesString.components(separatedBy: "\n")
        }
    }
    
    var needMask: Bool {
        return self.mask
    }
    
    var randomCover: String {
        let randomInt = Int.random(lower: 0, 48)
        if self.pictureUrl.count < randomInt + 1 {
            return ""
        }
       return self.pictureUrl[randomInt].replacingOccurrences(of: "\r", with: "")
    }
}
