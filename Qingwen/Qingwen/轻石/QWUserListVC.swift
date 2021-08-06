//
//  QWUserListVC.swift
//  Qingwen
//
//  Created by Aimy on 11/13/15.
//  Copyright © 2015 iQing. All rights reserved.
//

import UIKit

class QWUserListVC: QWBaseListVC {

    override class func registMapping() {
        let vo = QWMappingVO()
        vo.className = NSStringFromClass(self)
        vo.storyboardName = "QWCoin"
        vo.storyboardID = "userlist"
        QWRouter.sharedInstance().register(vo, withKey: "userlist")
    }

    var url: String?
    var user_url: String?
    var gold:NSNumber = 0 //0 轻石 1重石 2信仰
    var v4:Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        type = 1
    }

    lazy var logic: QWChargeLogic = {
        return QWChargeLogic(operationManager: self.operationManager)
    }()

    override var listVO: PageVO? {
        return self.logic.users
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        self.tableView.rowHeight = 80
        
        if let extraData = self.extraData {
            if let title = extraData.objectForCaseInsensitiveKey("title") as? String {
                self.title = title
            }

            if let url = extraData.objectForCaseInsensitiveKey("url") as? String {
                self.url = url
            }

            if let userUrl = extraData.objectForCaseInsensitiveKey("user_url") as? String {
                self.user_url = userUrl
            }

            if let gold = extraData.objectForCaseInsensitiveKey("gold") as? NSNumber {
                self.gold = gold
            }
            
            if let requestType = extraData.objectForCaseInsensitiveKey("v4") as? Bool {
                self.v4 = requestType
            }else{
                self.v4 = false
            }
        }

        self.getData()
    }

    override func updateWithTVCell(_ cell: QWBaseTVCell, indexPath: IndexPath) {
        let index = self.type == 0 ? (indexPath as NSIndexPath).item : (indexPath as NSIndexPath).row
        if let vo = self.listVO?.results[index] as? UserVO {
            let cell = cell as! QWUserListTVCell
            cell.updateWithUser(vo)
            cell.updateWithIndexPath(indexPath)
            switch gold {
            case 0: //轻石
                cell.updateWithUserCoin(vo)
            case 1: //重石
                cell.updateWithUserGold(vo)
            case 2: //信仰
                cell.updateWithUserFaith(vo)
            default:
                break
            }
        }
    }

    override func getData() {

        if self.logic.isLoading {
            return
        }

        self.logic.isLoading = true

        self.logic.users = nil;
        self.tableView.emptyView.showError = false
        self.collectionView.emptyView.showError = false

        self.logic.getAuthorRankListWithUrl(self.url,useV4: self.v4) { [weak self] (aResponseObject, anError) -> Void in
            if let weakSelf = self {
                weakSelf.tableView.reloadData()
                weakSelf.tableView.emptyView.showError = true
                weakSelf.logic.isLoading = false
                weakSelf.hideLoading()
            }
        }

        if let _ = self.user_url , QWGlobalValue.sharedInstance().isLogin() {
            self.logic.getUserChargeWithUrl(self.user_url, completeBlock: { (aResponseObject, anError) -> Void in
                if let _ = anError {
                    return
                }

                self.tableView.reloadData()
            })
        }
    }

    override func getMoreData() {
        if self.logic.isLoading {
            return
        }

        self.logic.isLoading = true

        self.tableView.emptyView.showError = false
        self.collectionView.emptyView.showError = false

        self.logic.getAuthorRankListWithUrl(self.url,useV4: self.v4) { [weak self] (aResponseObject, anError) -> Void in
            if let weakSelf = self {
                weakSelf.tableView.reloadData()
                weakSelf.tableView.emptyView.showError = true
                weakSelf.logic.isLoading = false
            }
        }
    }

    override func didSelectedCellAtIndexPath(_ indexPath: IndexPath) {
        if let user = self.listVO?.results[(indexPath as NSIndexPath).row] as? UserVO {
            if let user = user.user {
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
            else {

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
}

extension QWUserListVC {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if self.gold.intValue == 1 {
            if let _ = self.logic.user?.gold {
                return 30
            }
            else {
                return 0
            }
        }
        else {
            if let _ = self.logic.user?.coin {
                return 30
            }
            else {
                return 0
            }
        }
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = UIColor(hex: 0x505050)
        label.backgroundColor = self.tableView.backgroundColor
        if self.gold.intValue == 1 {
            if let gold = self.logic.user?.gold {
                label.text = "  我对当前作品的投石: \(gold)重石"
            }
        }
        else {
            if let coin = self.logic.user?.coin {
                label.text = "  我对当前作品的投石: \(coin)轻石"
            }
        }
        return label
    }
}

