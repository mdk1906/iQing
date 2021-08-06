//
//  QWUserLogic.swift
//  Qingwen
//
//  Created by Aimy on 10/23/15.
//  Copyright © 2015 iQing. All rights reserved.
//

import UIKit

class QWUserLogic: QWBaseLogic {

    var friendCount = 0
    var fanCount = 0
    var workCount = 0
    
    var follow: NSNumber?
    var myself: NSNumber?
    var userVO: UserVO?

    func getWithUrl(_ url: String?, completeBlock: QWCompletionBlock?) {
        if !QWGlobalValue.sharedInstance().isLogin() {
            completeBlock?(nil, not_login_error)
            return
        }

        var params = [String: String]()
        params["token"] = QWGlobalValue.sharedInstance().token

        let param = QWInterface.getWithUrl(url, params: params) { (aResponseObject, anError) -> Void in
            completeBlock?(aResponseObject, nil)
        }

        param!.requestType = .post
        self.operationManager.request(with: param)
    }

    func getUserWithUrl(_ url: String?, completeBlock: QWCompletionBlock?) {
        let param = QWInterface.getWithUrl(url) { (aResponseObject, anError) -> Void in
            if let anError = anError {
                completeBlock?(nil, anError)
                return ;
            }

            if let dict = aResponseObject as? [String: AnyObject] {
                self.userVO = UserVO.vo(withDict: dict)
                if let user = dict["user"] as? [String: AnyObject] {
                    if let username = user["username"] as? String {
                        self.userVO?.username = username
                    }

                    if let profile_url = user["profile_url"] as? String {
                        self.userVO?.profile_url = profile_url
                    }
                }
            }

            completeBlock?(self.userVO, nil)
        }

        self.operationManager.request(with: param)
    }
    func getUserWithUserName(_ username: String?, completeBlock: QWCompletionBlock?) {
        var params = [String: String]()
        params["username"] = username

        let param = QWInterface.getWithDomainUrl("user/match/", params: params) { (aResponseObject, anError) -> Void in
            if let anError = anError {
                completeBlock?(nil, anError)
                return ;
            }

            if let dict = aResponseObject as? [String: AnyObject] {
                self.userVO = UserVO.vo(withDict: dict)
                if let user = dict["user"] as? [String: AnyObject] {
                    if let username = user["username"] as? String {
                        self.userVO?.username = username
                    }

                    if let profile_url = user["profile_url"] as? String {
                        self.userVO?.profile_url = profile_url
                    }
                }
            }

            completeBlock?(self.userVO, nil)
        }

        self.operationManager.request(with: param)
    }

    func getUserRelationWithUrl(_ url: String?, completeBlock: QWCompletionBlock?) {
        if !QWGlobalValue.sharedInstance().isLogin() {
            completeBlock?(nil, not_login_error)
            return
        }

        var params = [String: String]()
        params["token"] = QWGlobalValue.sharedInstance().token
        let param = QWInterface.getWithUrl(url, params: params) { (aResponseObject, anError) -> Void in
            if let anError = anError {
                completeBlock?(nil, anError)
                return ;
            }

            if let dict = aResponseObject as? [String: AnyObject] {
                self.follow = dict["follow"] as? NSNumber
                self.myself = dict["myself"] as? NSNumber
                completeBlock?(self.myself, anError)
            }
        }

        param!.requestType = .post
        self.operationManager.request(with: param)
    }

    func doFriendAttentionWithCompleteBlock(_ completeBlock: QWCompletionBlock?) {
        if !QWGlobalValue.sharedInstance().isLogin() {
            completeBlock?(nil, not_login_error)
            return
        }

        let url = (self.follow?.boolValue == true) ? self.userVO?.unfollow_url : self.userVO?.follow_url

        var params = [String: String]()
        params["token"] = QWGlobalValue.sharedInstance().token
        let param = QWInterface.getWithUrl(url, params: params) { (aResponseObject, anError) -> Void in
            if let anError = anError {
                completeBlock?(nil, anError)
                return ;
            }

            if let dict = aResponseObject as? [String: AnyObject] {
                if let code = dict["code"] as? NSNumber {
                    if code.isEqual(to: 0) {
                        if self.follow?.boolValue == true {
                            self.follow = 0
                        }
                        else {
                            self.follow = 1
                        }
                    }
                }

                completeBlock?(aResponseObject, anError)
            }
        }

        param!.requestType = .post
        self.operationManager.request(with: param)
    }

    func modifySignature(_ signature: String, completeBlock: QWCompletionBlock?) {
        if !QWGlobalValue.sharedInstance().isLogin() {
            completeBlock?(nil, not_login_error)
            return
        }

        var params = [String: String]()
        params["token"] = QWGlobalValue.sharedInstance().token
        params["signature"] = signature

        let param = QWInterface.getWithDomainUrl("update_user/", params: params) { (aResponseObject, anError) -> Void in
            completeBlock?(aResponseObject, anError)
        }

        param!.requestType = .post
        self.operationManager.request(with: param)
    }
    func modifynName(_ nName: String, completeBlock: QWCompletionBlock?) {
        if !QWGlobalValue.sharedInstance().isLogin() {
            completeBlock?(nil, not_login_error)
            return
        }
        
        var params = [String: String]()
        params["token"] = QWGlobalValue.sharedInstance().token
        params["username"] = nName
        
        let param = QWInterface.getWithDomainUrl("update_user/", params: params) { (aResponseObject, anError) -> Void in
            completeBlock?(aResponseObject, anError)
        }
        
        param!.requestType = .post
        self.operationManager.request(with: param)
    }
    
}
