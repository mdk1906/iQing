//
//  QWBookListCommentsTVC.swift
//  Qingwen
//
//  Created by wei lu on 7/01/18.
//  Copyright © 2018 iQing. All rights reserved.
//

import UIKit

class QWBookCommentsListTVC: QWBaseListVC {
    
    override static func registMapping() {
        let vo = QWMappingVO()
        vo.className = NSStringFromClass(self)
        vo.storyboardName = "QWBookListCommentsTVC"
        vo.storyboardID = "QWBookListCommentsTVC"
        QWRouter.sharedInstance().register(vo, withKey: "book_comments")
    }
    
    override var listVO: PageVO? {
        return self.logic.commentsVO
    }
    
    lazy var logic:QWBookCommentsLogic = {
        return QWBookCommentsLogic(operationManager: self.operationManager)
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.type = 1
        self.useSection = false
    }
    
    var work_id:NSNumber?
    var work_type:NSNumber?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.title = "书评"
        if let extraData = self.extraData {
            if let nid = extraData.objectForCaseInsensitiveKey("work_id") as? NSNumber {
                self.work_id = nid
            }
            
            if let workType = extraData.objectForCaseInsensitiveKey("work_type") as? NSNumber {
                self.work_type = workType
            }
        }
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 200.0
        
        self.tableView.mj_header = QWRefreshHeader(refreshingBlock: { [weak self] () -> Void in
            self?.getData()
        })
        self.getData()
    }
    
    override func getData() {
        if self.logic.isLoading {
            return
        }
        if(self.work_type == nil && self.work_id == nil){
            return
        }
        self.logic.isLoading = true
        self.logic.commentsVO = nil
        self.tableView.emptyView.showError = false
        self.logic.getCommentsWithCompleteBlock(self.work_id!, workType: self.work_type!, andComplete: {[weak self](aResopneseObject, anError) in
            if let weakSelf = self {
                weakSelf.tableView.emptyView.showError = true
                weakSelf.tableView.reloadData()
                weakSelf.logic.isLoading = false
                weakSelf.tableView.mj_header.endRefreshing()
            }
        })
    }
    override func getMoreData() {
        if self.logic.isLoading {
            return
        }
        self.logic.isLoading = true
        self.logic.getCommentsWithCompleteBlock (self.work_id!, workType: self.work_type!, andComplete:{ [weak self](aResopneseObject, anError) in
            if let weakSelf = self {
                weakSelf.tableView.reloadData()
                weakSelf.logic.isLoading = false
            }
        })
    }

    deinit {
        removeAllObservations(of: QWReachability.sharedInstance())
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.observe(QWReachability.sharedInstance(), property: "currentNetStatus") { [weak self] (tempSelf, object, old, newVal) -> Void in
            if let weakSelf = self {
                if QWReachability.sharedInstance().isConnectedToNet && weakSelf.logic.commentsVO == nil {
                    weakSelf.getData()
                }
            }
        }
    }
    
}

extension QWBookCommentsListTVC{
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return PX1_LINE
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1
    }
    
    override func updateWithTVCell(_ cell: QWBaseTVCell, indexPath: IndexPath) {
        if let vo = self.listVO?.results[indexPath.item] as? BookCommentsVO{
            let cell = cell as! QWBookListCommentsCell
            if(vo.favorite_id == nil || vo.author == nil){
                return
            }
            cell.updateWithVO(vo)
        }
    }
    
    override func didSelectedCellAtIndexPath(_ indexPath: IndexPath) {
        if let cell = self.tableView.cellForRow(at: indexPath) as? QWBookListCommentsCell{
            let actionSheet = UIActionSheet.bk_actionSheet(withTitle: "更多") as! UIActionSheet
            actionSheet.bk_addButton(withTitle: "查看https://www.iqing.in") { () -> Void in
                QWRouter.sharedInstance().router(withUrlString: NSString.getRouterVCUrlString(fromUrlString:"www.iqing.in")!)
            }
            
            if let book = self.listVO?.results[indexPath.item] as? BookCommentsVO{
                if let author = book.author,let profile_url = author.profile_url{
                    var url = "myself"
                    var params = [String: String]()
                    if let me = QWGlobalValue.sharedInstance().user, me.nid != author.nid{
                            params["profile_url"] = profile_url
                            url = "user"
                        }
                    actionSheet.bk_addButton(withTitle: "查看作者:"+author.username!) { () -> Void in
                        QWRouter.sharedInstance().router(withUrlString: NSString.getRouterVCUrlString(fromUrlString: url, andParams: params))
                    }

                }
                
                if let title = book.favorite_title,let fav_id = cell.fav_id{
                    actionSheet.bk_addButton(withTitle: "查看<<"+title+">>书单") { () -> Void in
                        var params = [String: Any]()
                        params["id"] = fav_id
                        QWRouter.sharedInstance().router(withUrlString: NSString.getRouterVCUrlString(fromUrlString: "favorite", andParams: params))
                    }
                }
            }
                
            actionSheet.bk_setCancelButton(withTitle: "取消") { () -> Void in
                
            }
            
            actionSheet.show(in: QWRouter.sharedInstance().rootVC.view)
        }
    }
    

}
