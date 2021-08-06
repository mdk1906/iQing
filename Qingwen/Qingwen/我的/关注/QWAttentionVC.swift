//
//  QWAttentionVC.swift
//  Qingwen
//
//  Created by Aimy on 10/14/15.
//  Copyright © 2015 iQing. All rights reserved.
//

import UIKit

class QWAttentionVC: QWBaseListVC {

    var attentionUrl: String? {
        return nil
    }

    lazy var logic: QWAttentionLogic = {
        return QWAttentionLogic(operationManager: self.operationManager)
        }()

    override var listVO: PageVO? {
        if let list =  self.logic.friendListVO {
            return list
        }
        else {
            return self.logic.fanListVO
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        type = 1
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.rowHeight = 80

        getData()
    }

    override func getData() {

        if self.logic.isLoading {
            return
        }
        self.logic.isLoading = true
        
        self.tableView.emptyView.showError = false
        self.logic.friendListVO = nil
        self.logic.fanListVO = nil
        self.logic.getFriendWithUrl(attentionUrl) { [weak self] (aResponseObject, anError) -> Void in
            if let weakSelf = self {
                weakSelf.logic.isLoading = false
                weakSelf.tableView.reloadData()
                weakSelf.tableView.emptyView.showError = true
            }
        }
    }

    override func getMoreData() {
        self.tableView.emptyView.showError = false

        if self.logic.isLoading {
            return
        }
        self.logic.isLoading = true
        self.logic.getFriendWithUrl(attentionUrl) { [weak self] (aResponseObject, anError) -> Void in
            if let weakSelf = self {
                weakSelf.logic.isLoading = false
                weakSelf.tableView.reloadData()
                weakSelf.tableView.tableFooterView = nil
                weakSelf.tableView.emptyView.showError = true
            }
        }
    }

}

extension QWAttentionVC {
    override func updateWithTVCell(_ cell: QWBaseTVCell, indexPath: IndexPath) {
        if let item = self.listVO?.results[(indexPath as NSIndexPath).row] as? FriendItemVO, let user = item.friend, let cell = cell as? QWAttentionTVCell {
            cell.updateWithUser(user)
        }
    }

    override func didSelectedCellAtIndexPath(_ indexPath: IndexPath) {
        if let item = self.listVO?.results[(indexPath as NSIndexPath).row] as? FriendItemVO, let user = item.friend {
            var params = [String: String]()
            params["profile_url"] = user.profile_url
            params["username"] = user.username

            if let sex = user.sex {
                params["sex"] = sex.stringValue
            }

            if let avatar = user.avatar {
                params["avatar"] = avatar
            }

            QWRouter.sharedInstance().router(withUrlString: NSString.getRouterVCUrlString(fromUrlString: "user", andParams: params))
        }
    }
}




