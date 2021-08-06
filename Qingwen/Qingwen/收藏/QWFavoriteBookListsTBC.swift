//
//  QWFavoriteBookListsTBC.swift
//  Qingwen
//
//  Created by wei lu on 10/02/18.
//  Copyright © 2018 iQing. All rights reserved.
//


import UIKit
extension QWFavoriteListTBC{
    override static func registMapping() {
        let vo = QWMappingVO()
        vo.className = NSStringFromClass(self)
        vo.storyboardName = "QWFavoriteListTB"
        vo.storyboardID = "QWFavoriteListTBC"
        QWRouter.sharedInstance().register(vo, withKey: "relative_favorite")
    }
}
class QWFavoriteListTBC: QWBaseListVC {
    var isUserId = false
    
    lazy var logic: QWBookCommentsLogic = {
        return QWBookCommentsLogic(operationManager: self.operationManager)
    }()
    
    lazy var myBooksLogic: QWFavoriteBooksLogic = {
        return QWFavoriteBooksLogic(operationManager: self.operationManager)
    }()
    
    override var listVO:FavoriteBooksListVO? {
        return self.logic.relatetiveFavoritesVO
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.tableFooterView = UIView()
        self.tableView.backgroundColor = UIColor(hex:0xf1f1f1)
        self.useSection = false
        self.tableView.rowHeight = 120
//        self.tableView.register(QWBookListsTVCell.self, forCellReuseIdentifier: "cell")
        self.tableView.emptyView.errorImage = UIImage(named: "empty_6_none")
        self.tableView.emptyView.errorMsg = "没有该书单"
        if let extraData = self.extraData {
            if(extraData.objectForCaseInsensitiveKey("user_id") != nil){
                self.isUserId = true
            }else{
                self.isUserId = false
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.getData()
    }
    
    override func getData() {
//        if self.logic.isLoading {
//            return
//        }
        
        if let extraData = self.extraData {
            self.logic.isLoading = true
            self.tableView.emptyView.showError = false
            self.logic.relatetiveFavoritesVO = nil
            self.myBooksLogic.myFavoritelistVO = nil
            if let nid = extraData.objectForCaseInsensitiveKey("work_id") as? NSNumber {
                self.logic.getRelativeFavorite(withCompleteBlock: nid, workType: 1, andComplete: { [weak self] (aResponseObject, anError) in
                    if let weakSelf = self{
                        weakSelf.logic.isLoading = false
                        if let anError = anError as NSError?{
                            weakSelf.showToast(withTitle: anError.userInfo[NSLocalizedDescriptionKey] as? String, subtitle: nil, type: .alert)
                        }else if(aResponseObject != nil){
                            weakSelf.tableView.reloadData()
                        }
                    }
                })
            }
            else if let uid = extraData.objectForCaseInsensitiveKey("user_id") as? NSNumber{
                self.myBooksLogic.getFavoriteBooksWithCompleteBlock(listId: uid, isOwn: 1, { [weak self] (aResponseObject, anError) -> Void in
                    if let weakSelf = self{
                        weakSelf.logic.isLoading = false
                        if let anError = anError as NSError?{
                            weakSelf.showToast(withTitle: anError.userInfo[NSLocalizedDescriptionKey] as? String, subtitle: nil, type: .alert)
                        }else if(aResponseObject != nil){
                            weakSelf.logic.relatetiveFavoritesVO = weakSelf.myBooksLogic.myFavoritelistVO
                            weakSelf.tableView.reloadData()
                        }
                    }
                })
            }
            self.logic.isLoading = false
            self.hideLoading()
        }else{
            self.logic.isLoading = false
            self.hideLoading()
        }

        
        
    }
    
    override func getMoreData() {
        if self.logic.isLoading {
            return
        }
        self.logic.isLoading = true
        self.tableView.emptyView.showError = false
        if let nid = self.extraData?.objectForCaseInsensitiveKey("work_id") as? NSNumber {
            self.logic.getRelativeFavorite(withCompleteBlock: nid, workType: 1, andComplete: { [weak self] (aResponseObject, anError) in
                if let weakSelf = self{
                    weakSelf.logic.isLoading = false
                    if let anError = anError as NSError?{
                        weakSelf.showToast(withTitle: anError.userInfo[NSLocalizedDescriptionKey] as? String, subtitle: nil, type: .alert)
                    }else if(aResponseObject != nil){
                        weakSelf.tableView.reloadData()
                    }
                }
            })
        }
        if let uid = extraData?.objectForCaseInsensitiveKey("user_id") as? NSNumber{
            self.myBooksLogic.getFavoriteBooksWithCompleteBlock(listId: uid, isOwn: 1, { [weak self] (aResponseObject, anError) -> Void in
                if let weakSelf = self{
                    weakSelf.logic.isLoading = false
                    if let anError = anError as NSError?{
                        weakSelf.showToast(withTitle: anError.userInfo[NSLocalizedDescriptionKey] as? String, subtitle: nil, type: .alert)
                    }else if(aResponseObject != nil){
                        weakSelf.logic.relatetiveFavoritesVO = weakSelf.myBooksLogic.myFavoritelistVO
                        weakSelf.tableView.reloadData()
                    }
                }
            })
        }
        
    }
    
    override func update() {
        self.getData()
    }
}

extension QWFavoriteListTBC {

    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return PX1_LINE
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return PX1_LINE
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    override func updateWithTVCell(_ cell: QWBaseTVCell, indexPath: IndexPath) {
        
        if let vo = listVO?.results[indexPath.row] as? FavoriteBooksVO{
            let cell = cell as! QWBookListsTVCell
            cell.updateWithFavItem(vo)
        }
    }
    
    
    override func didSelectedCellAtIndexPath(_ indexPath: IndexPath) {
        if let data = listVO?.results[indexPath.row] as? FavoriteBooksVO{
            var params = [String: Any]()
            params["title"] = data.title
            params["intro"] = data.intro
            params["id"] = data.nid
            QWRouter.sharedInstance().router(withUrlString: NSString.getRouterVCUrlString(fromUrlString: "favorite", andParams: params))
        }
    }
}

