//
//  QWMyAttentionPeopleVC.swift
//  Qingwen
//
//  Created by Aimy on 10/12/15.
//  Copyright © 2015 iQing. All rights reserved.
//

import UIKit

extension QWMyAttentionPeopleVC {
    override class func registMapping() {
        let vo = QWMappingVO()
        vo.className = NSStringFromClass(self)
        vo.storyboardName = "QWAttention"
        QWRouter.sharedInstance().register(vo, withKey: "myattention")
    }
}

class QWMyAttentionPeopleVC: QWAttentionVC {

    var searchForName = false

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.emptyView.errorImage = UIImage(named: "empty_4_none");
        self.tableView.emptyView.errorMsg = "你还没有关注任何人噢(>△<)";

        if let extraData = self.extraData {
            if let searchForName = extraData.objectForCaseInsensitiveKey("searchusername") as? Bool {
                self.searchForName = searchForName
            }
        }
    }

    override func updateWithTVCell(_ cell: QWBaseTVCell, indexPath: IndexPath) {
        super.updateWithTVCell(cell, indexPath: indexPath)
        let tempCell = cell as! QWAttentionTVCell
        tempCell.attentionBtn?.isHidden = self.searchForName
    }

    override func didSelectedCellAtIndexPath(_ indexPath: IndexPath) {
        if self.searchForName {
            if let item = self.listVO?.results[(indexPath as NSIndexPath).row] as? FriendItemVO, let user = item.friend, let username = user.username {
                if let extraData = self.extraData {
                    if let p_block = extraData.objectForCaseInsensitiveKey(QWRouterCallbackKey) {
                        let block = unsafeBitCast(p_block, to: QWNativeFuncVOBlockType.self)
                        _ = block(["nickname": username as AnyObject])
                    }
                }
                self.leftBtnClicked(nil)
            }
        }
        else {
            super.didSelectedCellAtIndexPath(indexPath)
        }
    }

    override var attentionUrl: String? {
        return QWGlobalValue.sharedInstance().user?.friend_url
    }

    @IBAction func onPressedAttentionBtn(_ sender: UIButton, event: UIEvent) {
        if let touch = event.allTouches?.first {
            let point = touch.location(in: self.tableView)
            if let indexPath = self.tableView.indexPathForRow(at: point),
                let item = self.logic.friendListVO?.results?[(indexPath as NSIndexPath).row] as? FriendItemVO,
                let user = item.friend {
                    self.showLoading()
                    self.logic.unfollowFriend(withUrl: user.unfollow_url, andComplete: { [weak self] (aResponseObject, anError) -> Void in
                        if let weakSelf = self {
                            if anError == nil {
                                if let aResponseObject = aResponseObject as? [String: AnyObject] {
                                    if let code = aResponseObject["code"] as? NSNumber , code.isEqual(to: NSNumber(value: 0 as Int32)) {
                                        weakSelf.logic.friendListVO = nil
                                        weakSelf.tableView.tableFooterView = UIView()
                                        self?.tableView.tableFooterView?.backgroundColor = UIColor.clear
                                        weakSelf.tableView.reloadData()
                                        weakSelf.getData()
                                    }
                                    else {
                                        if let message = aResponseObject["data"] as? String {
                                            weakSelf.showToast(withTitle: message, subtitle: nil, type: ToastType.alert)
                                        }
                                        else {
                                            weakSelf.showToast(withTitle: "失败", subtitle: nil, type: ToastType.alert)
                                        }
                                    }
                                }
                            }
                            else {
                                if let anError = anError as NSError? {
                                weakSelf.showToast(withTitle: anError.userInfo[NSLocalizedDescriptionKey] as? String, subtitle: nil, type: ToastType.error)
                                }
                               
                            }
                            weakSelf.hideLoading()
                        }
                })
            }
        }
    }
}

