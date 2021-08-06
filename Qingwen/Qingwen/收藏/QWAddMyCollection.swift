//
//  QWAddMyCollection.swift
//  Qingwen
//
//  Created by wei lu on 1/01/18.
//  Copyright © 2018 iQing. All rights reserved.
//

import UIKit
extension QWAddMyCollectionTVC{
    override static func registMapping() {
        let vo = QWMappingVO()
        vo.className = NSStringFromClass(self)
        vo.storyboardName = "QWAddMyCollection"
        vo.storyboardID = "QWAddMyCollection"
        QWRouter.sharedInstance().register(vo, withKey: "addCollection")
    }
}

class QWAddMyCollectionTVC: QWBaseListVC {
    var loginView: QWMessageLoginView?
    var lastSelectedIndexPath:IndexPath?
    var currentSelectIndexPath:IndexPath = IndexPath(item: 1, section: 1)
    var selectedIndexPath:IndexPath?
    var pop:QWWordsInputPopUp?
    var isDefaultCollection:NSNumber?
    let queue = DispatchGroup();
    
    @IBOutlet weak var footerView: UIView!
    override var listVO: PageVO? {
        return self.getLogic.myFavoritelistVO
    }
    lazy var defaultlogic:QWDetailLogic = {
        return QWDetailLogic(operationManager: self.operationManager)
    }()
    
    lazy var addlogic:QWAddBookCollectionLogic = {
        return QWAddBookCollectionLogic(operationManager: self.operationManager)
    }()
    
    lazy var getLogic:QWFavoriteBooksLogic = {
        return QWFavoriteBooksLogic(operationManager: self.operationManager)
    }()
    
    @IBAction func didTapFooterView(_ sender: Any) {
        
        
        if(QWGlobalValue.sharedInstance().created_favorite == 1){
            let alert2 = UIAlertView.bk_alertView(withTitle: "提示", message: "您已经有了一个书单，不能重复创建") as! UIAlertView
            alert2.bk_addButton(withTitle: "确定", handler: {
                
            })
            alert2.show()
            return
        }else if(QWGlobalValue.sharedInstance().created_favorite == 0 || QWGlobalValue.sharedInstance().created_favorite == nil){
            let alert1 = UIAlertView.bk_alertView(withTitle: "提示", message: "您只能创建一个书单，请小心使用创建功能") as! UIAlertView
            alert1.bk_setCancelButton(withTitle: "确定", handler: {
                var params = [String:String]()
                params["action"] = "create"
                QWRouter.sharedInstance().router(withUrlString: NSString.getRouterVCUrlString(fromUrlString: "CreateNewBooksList", andParams: params))
            })
            alert1.bk_setCancelButton(withTitle: "取消", handler: {
                
            })
            alert1.show()
        }
        
        
        
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.type = 1
        
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.tableView.rowHeight = 50;
        self.tableView.tableFooterView = self.footerView
        self.tableView.emptyView.errorImage = UIImage(named: "empty_4_none");
        self.tableView.emptyView.errorMsg = "你还没有收藏任何作品噢(>△<)";
        self.loginView = QWMessageLoginView.createWithNib()
        self.view.addSubview(self.loginView!)
        self.loginView?.isHidden = QWGlobalValue.sharedInstance().isLogin()

        self.loginView?.autoPinEdge(.top, to: .top, of: self.view)
        self.loginView?.autoPinEdge(.left, to: .left, of: self.view)
        self.loginView?.autoPinEdge(.right, to: .right, of: self.view)
        self.loginView?.autoPinEdge(.bottom, to: .bottom, of: self.view)
        
        self.pop = QWWordsInputPopUp.createWithNib()
        self.pop?.delegate = self
        
        self.isDefaultCollection = self.extraData?.objectForCaseInsensitiveKey("isCollection") as? NSNumber
        self.observeNotification(LOGIN_STATE_CHANGED) { [weak self] (tempSelf, notification) -> Void in
            guard let _ = notification else {
                return
            }

            if let weakSelf = self {
                weakSelf.getLogic.myFavoritelistVO = nil
                weakSelf.tableView.reloadData()
                weakSelf.loginView?.isHidden = QWGlobalValue.sharedInstance().isLogin()
                weakSelf.getData()
            }
        }
    }
    
    override func getData() {
        guard QWGlobalValue.sharedInstance().isLogin() else {
            return
        }
        if self.getLogic.isLoading {
            return
        }
        self.showLoading()
        self.getLogic.isLoading = true
        self.getLogic.myFavoritelistVO = nil
        self.tableView.emptyView.showError = false
        if let nid = self.extraData?.objectForCaseInsensitiveKey("id") as? NSNumber,let workType = self.extraData?.objectForCaseInsensitiveKey("type") as? String{
            let type:NSNumber = (workType == "book") ? 1 : 2
            self.getLogic.getFavoriteBooksWithFullParamsCompleteBlock(workId:nid, workType:type,listId: nil, isOwn: 1, { [weak self] (aResponseObject, anError) -> Void in
                if let weakSelf = self {
                    weakSelf.hideLoading()
                    weakSelf.getLogic.isLoading = false
                    if let anError = anError as NSError?{
                        weakSelf.showToast(withTitle: anError.userInfo[NSLocalizedDescriptionKey] as? String, subtitle: nil, type: .alert)
                    }else if(aResponseObject != nil){
                        weakSelf.tableView.emptyView.showError = true
                        weakSelf.tableView.reloadData()
                    }
                }
            })
        }
    }

    deinit {
        removeAllObservations(of: QWReachability.sharedInstance())
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.loginView?.isHidden = QWGlobalValue.sharedInstance().isLogin()
        self.observe(QWReachability.sharedInstance(), property: "currentNetStatus") { [weak self] (tempSelf, object, old, newVal) -> Void in
            if let weakSelf = self {
                if QWReachability.sharedInstance().isConnectedToNet && weakSelf.getLogic.myFavoritelistVO == nil {
                    weakSelf.getData()
                }
            }
        }
        if QWGlobalValue.sharedInstance().isLogin()  {
            self.getData()
        }
    }
    
    func removeFromCollection(indexPath: IndexPath){
        if ((self.listVO?.results) != nil){
            if let extraData = self.extraData {
                let cell = self.tableView.cellForRow(at: indexPath) as! QWAddBookCollectionCell
                if let nid = extraData.objectForCaseInsensitiveKey("id") as? NSNumber,let workType = extraData.objectForCaseInsensitiveKey("type") as? String{
                    let type:NSNumber = (workType == "book") ? 1 : 2
                self.showLoading()
                self.addlogic.removeBookListsCollection(collectionID:cell.listId,workId:nid.stringValue as NSString,workType:type, { [weak self] (aResponseObject, anError) in
                        if let weakSelf = self{
                            weakSelf.hideLoading()
                            weakSelf.pop?.dissmiss()
                            if let anError = anError as NSError?{
                                weakSelf.showToast(withTitle: anError.userInfo[NSLocalizedDescriptionKey] as? String, subtitle: nil, type: .alert)
                            }else if let rep = aResponseObject as? [String: AnyObject]{
                                if let code = rep["code"] as? Int,code == 0{
                                    weakSelf.showToast(withTitle: "取消收藏成功", subtitle: nil, type: .alert)
                                }else{
                                    if let msg = rep["msg"] as? String{
                                        weakSelf.showToast(withTitle: msg, subtitle: nil, type: .alert)
                                    }else{
                                        weakSelf.showToast(withTitle: "取消收藏失败", subtitle: nil, type: .alert)
                                    }
                                }
                            }
                            weakSelf.getData()
                        }
                    })
                }
            }
        }
    }
    
    func addtoCollections(text:NSString){
        if ((self.listVO?.results) != nil), let path = self.selectedIndexPath{
            let cell = self.tableView.cellForRow(at: path) as! QWAddBookCollectionCell
            if let extraData = self.extraData {
                if let nid = extraData.objectForCaseInsensitiveKey("id") as? NSNumber,let workType = extraData.objectForCaseInsensitiveKey("type") as? String{
                    let type:NSNumber = (workType == "book") ? 1 : 2
                    self.showLoading()
                    self.addlogic.addtoMyCollectionLists(collectionID:cell.listId, workType: type, recommend: text, workId: nid.stringValue as NSString, { [weak self] (aResponseObject, anError) in
                        if let weakSelf = self{
                            weakSelf.hideLoading()
                            weakSelf.pop?.dissmiss()
                            if let anError = anError as NSError?{
                                weakSelf.showToast(withTitle: anError.userInfo[NSLocalizedDescriptionKey] as? String, subtitle: nil, type: .alert)
                            }else if let rep = aResponseObject as? [String: AnyObject]{
                                if let code = rep["code"] as? Int,code == 0{
                                    weakSelf.singlelCheckBoxAction(weakSelf.currentSelectIndexPath)
                                    weakSelf.showToast(withTitle: "收藏成功", subtitle: nil, type: .alert)
                                }else{
                                    if let msg = rep["msg"] as? String{
                                        weakSelf.showToast(withTitle: msg, subtitle: nil, type: .alert)
                                    }else{
                                        weakSelf.showToast(withTitle: "收藏失败", subtitle: nil, type: .alert)
                                    }
                                }
                            }
                            weakSelf.getData()
                        }
                    })
                }
            }
        }
    }
}
extension QWAddMyCollectionTVC:QWWordsInputPopDelegate{
    func didConfirmWordsInput(text:NSString){
        self.addtoCollections(text:text);
    }
}
extension QWAddMyCollectionTVC {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(section == 0){//default collection list
            return 1
        }else{
            if let vos = self.listVO?.results {
                if(vos.count > 0){
                    QWGlobalValue.sharedInstance().created_favorite = 1
                    QWGlobalValue.sharedInstance().save()
                }
                return vos.count
            }
        }
        return 0
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }

    override func updateWithTVCell(_ cell: QWBaseTVCell, indexPath: IndexPath) {
            let vo = self.listVO?.results[indexPath.item] as? FavoriteBooksVO
            
            let cell = cell as! QWAddBookCollectionCell
            cell.accessoryView = UIImageView(image: UIImage(named: "btn_bg_19"))

            if let isDefCollected = self.isDefaultCollection,isDefCollected.boolValue == true && indexPath.section == 0{
                cell.tag = 1//selected
            }
            else if(vo?.can_add?.boolValue == false && indexPath.section != 0){
                cell.tag = 1//selected
                self.lastSelectedIndexPath = indexPath
            }
            else{
                cell.tag = 0
                cell.accessoryView = UIImageView(image: UIImage(named: "btn_bg_20"))
            }
            cell.updateWithVO(vo,Section: indexPath.section)
    }
    
    override func didSelectedCellAtIndexPath(_ indexPath: IndexPath) {
        
        if(indexPath.section == 0 && indexPath.item == 0){
            guard let cell = self.tableView.cellForRow(at: indexPath) else{
                return
            }
            if self.isDefaultCollection != nil {
                cell.accessoryView = (cell.tag == 1) ? UIImageView(image: UIImage(named: "btn_bg_20")) : UIImageView(image: UIImage(named: "btn_bg_19"))
                cell.tag = (cell.tag == 1) ? 0:1
                self.addtoDefaultCollection()
            }
            return
        }
        
        guard let cell = self.tableView.cellForRow(at: indexPath) else{
            return
        }
        
        if(cell.tag == 1){
            cell.accessoryView = UIImageView(image: UIImage(named: "btn_bg_20"))
            cell.tag = 0
            self.removeFromCollection(indexPath: indexPath)
            return
        }
        self.pop?.show()
        self.selectedIndexPath = indexPath
        self.currentSelectIndexPath = indexPath
    }
    
    func addtoDefaultCollection(){
        self.showLoading()
        let subscribeUrl = self.extraData?.objectForCaseInsensitiveKey("surl") as? String
        
        self.defaultlogic.doAttention(withParams: subscribeUrl, andComplete: { [weak self] (aResponseObject, anError) in
            if let weakSelf = self{
                weakSelf.hideLoading()
                if let anError = anError as NSError?{
                    weakSelf.showToast(withTitle: anError.userInfo[NSLocalizedDescriptionKey] as? String, subtitle: nil, type: .alert)
                }else if let rep = aResponseObject as? [String: AnyObject]{
                    if let code = rep["code"] as? Int,code == 0{
                        weakSelf.showToast(withTitle: rep["msg"] as? String, subtitle: nil, type: .alert)
                        weakSelf.isDefaultCollection = (weakSelf.isDefaultCollection!.boolValue) ? 0:1
                    }else{
                        if let msg = rep["msg"] as? String{
                            weakSelf.showToast(withTitle: msg, subtitle: nil, type: .alert)
                        }else{
                            weakSelf.showToast(withTitle: "收藏失败", subtitle: nil, type: .alert)
                        }
                    }
                }
                weakSelf.tableView.reloadData()
            }
        })
    }
    
    func singlelCheckBoxAction(_ indexPath: IndexPath){
        let newRow = indexPath.row;
        var oldRow: Int?
        guard let newCell = self.tableView.cellForRow(at: indexPath) else{
            return
        }
        var setFlag = false
        
        if let lastIndexPath = self.lastSelectedIndexPath {
            oldRow = lastIndexPath.row;
            guard let oldCell = self.tableView.cellForRow(at: lastIndexPath) else{
                return
            }
            
            if(oldRow == newRow && lastIndexPath.section == indexPath.section){
                setFlag = true
            }else if(lastIndexPath.section != indexPath.section && newRow == oldRow){
                setFlag = true
            }else{
                oldCell.accessoryView = UIImageView(image: UIImage(named: "btn_bg_20"))
            }
            
            if(setFlag){
                if(oldCell.tag == 0){
                    oldCell.accessoryView = UIImageView(image: UIImage(named: "btn_bg_19"))
                }else{
                    oldCell.accessoryView = UIImageView(image: UIImage(named: "btn_bg_20"))
                }
            }
            
            oldCell.tag = oldCell.tag == 1 ? 0:1//~oldCell.tag
        }
        
        if (newRow != oldRow) {
             setFlag = true
        }
//        }else{
//            setFlag = false//双击取消勾选
//        }
        
        if(setFlag){
            newCell.accessoryView = UIImageView(image: UIImage(named: "btn_bg_19"))
            newCell.tag = 1//selected
            self.lastSelectedIndexPath = indexPath
        }
        
        self.selectedIndexPath = indexPath
    }
}
