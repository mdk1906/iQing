//
//  QWSearchUserVC.swift
//  Qingwen
//
//  Created by mumu on 2017/7/26.
//  Copyright © 2017年 iQing. All rights reserved.
//

import UIKit

class QWSearchUserVC: QWBaseListVC {

    var keyWords: String?
    var change = false
    
    
    lazy var logic: QWSearchLogic = {
        return QWSearchLogic(operationManager: self.operationManager)
    }()
    
    override var listVO: PageVO? {
        return self.logic.searchUserListVO
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.useSection = true
        self.type = 1
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.tableFooterView = UIView()

        self.tableView.rowHeight = 110
        self.tableView.emptyView.errorImage = UIImage(named: "empty_6_none")
        self.tableView.emptyView.errorMsg = "没有搜索到该人"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.getData()
    }
    
    override func getData() {
        if self.logic.isLoading {
            return
        }
        if self.change == false {
            return
        }
        
        self.logic.isLoading = true
        self.tableView.emptyView.showError = false
        self.logic.searchUserListVO = nil
        self.logic.searchUser(withKeywords: keyWords, andComplete: { (_, _) in
            self.tableView.emptyView.showError = true
            self.logic.isLoading = false
            self.tableView.reloadData()
            self.change = false
        })
    }
    
    override func getMoreData() {
        if self.logic.isLoading {
            return
        }
        self.logic.isLoading = true
        self.tableView.emptyView.showError = false
        self.logic.searchUser(withKeywords: keyWords, andComplete: { (_, _) in
            self.tableView.emptyView.showError = true
            self.logic.isLoading = false
            self.tableView.reloadData()
        })
    }
    
    override func update() {
        self.change = true
        self.getData()
    }
}

extension QWSearchUserVC {
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return PX1_LINE
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return PX1_LINE
    }
    
    override func updateWithTVCell(_ cell: QWBaseTVCell, indexPath: IndexPath) {
        
        if let vo = listVO?.results[indexPath.section] as? UserVO{
            let cell = cell as! QWSearchUserCell
            cell.updateCell(withUser: vo)
        }
    }
    
    override func didSelectedCellAtIndexPath(_ indexPath: IndexPath) {
        if let user = listVO?.results[indexPath.section] as? UserVO, let profile_url = user.profile_url {
            
            var params = [String: String]()
            params["profile_url"] = profile_url
            
            QWRouter.sharedInstance().router(withUrlString: NSString.getRouterVCUrlString(fromUrlString: "user", andParams: params))
        }
    }
}
