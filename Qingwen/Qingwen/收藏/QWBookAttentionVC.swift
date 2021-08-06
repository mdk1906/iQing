//
//  QWBookAttentionVC.swift
//  Qingwen
//
//  Created by Aimy on 10/14/15.
//  Copyright © 2015 iQing. All rights reserved.
//

import UIKit

class QWBookAttentionVC: QWBaseListVC {

    enum attentionType: Int {
        case cell = 0
        case adcell
        
        case none = 999
        
        init(section: Int) {
            if let type = attentionType(rawValue: section) {
                self = type
            }
            else {
                self = .none
            }
        }
    }
    
    var loginView: QWMessageLoginView?
    var attentionView:QWbannerAdView?
    @IBOutlet var rightBarBtn: UIBarButtonItem!
    
    override var listVO: PageVO? {
        return self.logic.listVO
    }
    
    lazy var logic:QWShelefLogic = {
        return QWShelefLogic(operationManager: self.operationManager)
    }()
    override func awakeFromNib() {
        super.awakeFromNib()
        self.type = 1
        self.useSection = false
    }

    override func viewDidLoad() {
        
        super.viewDidLoad()
//        if SWIFT_ISIPHONE9_7 {
//            <#code#>
//        }
        self.tableView.emptyView.errorImage = UIImage(named: "empty_4_none");
        self.tableView.emptyView.errorMsg = "你还没有收藏任何作品噢(>△<)";

        self.loginView = QWMessageLoginView.createWithNib()
        self.view.addSubview(self.loginView!)
        self.loginView?.isHidden = QWGlobalValue.sharedInstance().isLogin()
        
        self.loginView?.autoPinEdge(.top, to: .top, of: self.view)
        self.loginView?.autoPinEdge(.left, to: .left, of: self.view)
        self.loginView?.autoPinEdge(.right, to: .right, of: self.view)
        self.loginView?.autoPinEdge(.bottom, to: .bottom, of: self.view)
        let favorite_ad:String = QWGlobalValue.sharedInstance().favorite_ad!
        if favorite_ad == "2" {
            
        }
        else if favorite_ad == "0"{
            self.createAttentionView()
        }
        else if favorite_ad == "1"{
            self.createAttentionDefaultView()
        }
        self.observeNotification(LOGIN_STATE_CHANGED) { [weak self] (tempSelf, notification) -> Void in
            guard let _ = notification else {
                return
            }

            if let weakSelf = self {
                weakSelf.logic.listVO = nil
                weakSelf.tableView.reloadData()
//                weakSelf.book_url = QWGlobalValue.sharedInstance().user?.bookshelf_url
                weakSelf.loginView?.isHidden = QWGlobalValue.sharedInstance().isLogin()
                weakSelf.getData()
                
            }
        }
        self.tableView.mj_header = QWRefreshHeader(refreshingBlock: { [weak self] () -> Void in
            self?.getData()
        })
        if #available(iOS 11.0, *) {
            let guide = self.view.safeAreaLayoutGuide.topAnchor;
            self.tableView.topAnchor.constraint(equalTo: guide).isActive = true
        }
        
        
    }
    
    override func getData() {
        guard QWGlobalValue.sharedInstance().isLogin() else {
            return
        }
        if self.logic.isLoading {
            return
        }
        self.logic.isLoading = true
        self.logic.listVO = nil
        self.tableView.emptyView.showError = false
        self.logic.getAttentionWithCompleteBlock { [weak self](aResopneseObject, anError) in
            if let weakSelf = self {
                weakSelf.tableView.emptyView.showError = true
                weakSelf.tableView.reloadData()
                weakSelf.logic.isLoading = false
                weakSelf.tableView.mj_header.endRefreshing()
            }
        }
        self.logic.getAchievementInfo{ [weak self](aResponseObject, anError) in
            
        }
    }
    override func getMoreData() {
        if self.logic.isLoading {
            return
        }
        self.logic.isLoading = true
        self.logic.getAttentionWithCompleteBlock { [weak self](aResopneseObject, anError) in
            if let weakSelf = self {
                weakSelf.tableView.reloadData()
                weakSelf.logic.isLoading = false
            }
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
                if QWReachability.sharedInstance().isConnectedToNet && weakSelf.logic.listVO == nil {
                    weakSelf.getData()
                }
            }
        }
        if QWGlobalValue.sharedInstance().isLogin()  {
            self.getData()
        }
    }
    
    @IBAction func onPressedSearchBtn(_ sender: AnyObject) {
        let sb = UIStoryboard(name: "QWSearch", bundle: nil)
        if let vc = sb.instantiateInitialViewController() {
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func createHeadView()  {
        let headView = QWbannerAdView.init(frame: CGRect(x:0,y:0,width:QWSize.screenWidth(),height:QWSize.bannerHeight()))
//        headView.frame = CGRect(x:0,y:0,width:QWSize.screenWidth(),height:125)
        headView?.backgroundColor = UIColor.white
        self.tableView.tableHeaderView = headView
    }
    
    func createAttentionView()  {
        self.attentionView = QWbannerAdView.init(frame: CGRect(x:0,y:64,width:QWSize.screenWidth(),height:QWSize.bannerHeight()))
        self.loginView?.addSubview(self.attentionView!)
    }
    func createAttentionDefaultView()  {
        let favorite_adInc:String = QWGlobalValue.sharedInstance().favorite_adInc!
        let favorite_adUrl:String = QWGlobalValue.sharedInstance().favorite_adURL!
        let view = QWDefaultAdImgView.init(frame: CGRect(x:0,y:64,width:QWSize.screenWidth(),height:QWSize.bannerHeight()), withImgUrl:favorite_adInc ,withPost:favorite_adUrl)
        self.loginView?.addSubview(view!)
    }
}
extension QWBookAttentionVC {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return PX1_LINE
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1
    }
    

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let favorite_ad:String = QWGlobalValue.sharedInstance().favorite_ad!
        if favorite_ad == "2" {
            return 130
        }
        else{
            if self.listVO?.results.count == 0{
                 return QWSize.bannerHeight()
            }
            else{
                if indexPath.row == 1{
                    return QWSize.bannerHeight()
                }
                else{
                    return 130
                }
            }
            
        }
        
        
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let favorite_ad:String = QWGlobalValue.sharedInstance().favorite_ad!
        if favorite_ad == "2" {
            if let vos = self.listVO?.results {
                
                return vos.count
                
            }
        }
        else{
            if let vos = self.listVO?.results {
                
                return vos.count + 1
                
            }
        }
        
        
        return 0
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        print("区头 = ",indexPath.section)
        let favorite_ad:String = QWGlobalValue.sharedInstance().favorite_ad!
        if favorite_ad == "2" {
            
                let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! QWBookAttentionTVCell
                if let vo = self.listVO?.results[indexPath.row] as? AttentionVO {
                    cell.updateWithVO(vo)
                }
                
                return cell
            
        }
        else{
            if self.listVO?.results.count == 0{
                let cell = tableView.dequeueReusableCell(withIdentifier: "adcell", for: indexPath) as! QWAdTVCell
                cell.createUI(type: "Favorite")
                return cell
            }
            else{
                if indexPath.row == 0 {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! QWBookAttentionTVCell
                    if let vo = self.listVO?.results[indexPath.row] as? AttentionVO {
                        cell.updateWithVO(vo)
                    }
                    return cell
                }
                else if indexPath.row == 1 {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "adcell", for: indexPath) as! QWAdTVCell
                    cell.createUI(type: "Favorite")
                    return cell
                }
                else{
                    let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! QWBookAttentionTVCell
                    if let vo = self.listVO?.results[indexPath.row - 1] as? AttentionVO {
                        cell.updateWithVO(vo)
                    }
                    
                    return cell
                }
            }
            
        }
        
        
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if tableView.tableFooterView == nil {
            if useSection {
                if let list = listVO?.results, let count = listVO?.count?.intValue, list.count == indexPath.section + 1, list.count < count {
                    getMoreData()
                }
            }
            else {
                let favorite_ad:String = QWGlobalValue.sharedInstance().favorite_ad!
                if favorite_ad == "2" {
                    if let list = listVO?.results, let count = listVO?.count?.intValue {
                        if list.count == indexPath.row + 1 && list.count < count {
                            getMoreData()
                            
                        }
                    }
                }
                else{
                    if let list = listVO?.results, let count = listVO?.count?.intValue {
                        if list.count == indexPath.row + 2 && list.count < count {
                            getMoreData()
                            
                        }
                    }
                }
                
            }
        }
    }
    
//    override func updateWithTVCell(_ cell: QWBaseTVCell, indexPath: IndexPath) {
//        if indexPath.section == 1 {
//                let cell = cell as! QWAdTVCell
//                cell.updateWithIndexPath(indexPath)
//
//
//        }
//        else{
//            if let vo = self.listVO?.results[indexPath.section] as? AttentionVO {
//                let cell = cell as! QWBookAttentionTVCell
//                cell.updateWithVO(vo)
//            }
//        }
//
//    }
    
    override func didSelectedCellAtIndexPath(_ indexPath: IndexPath) {
        let favorite_ad:String = QWGlobalValue.sharedInstance().favorite_ad!
        if favorite_ad == "2" {
            guard let attentionVO = self.listVO?.results[indexPath.row] as? AttentionVO else {
                return
            }
            if let vo = attentionVO.work {
                var params = [String: String]()
                params["book_url"] = vo.url
                params["id"] = vo.nid?.stringValue
                if attentionVO.work_type == .game {
                    QWRouter.sharedInstance().router(withUrlString: NSString.getRouterVCUrlString(fromUrlString: "gamedetail", andParams: params))
                }
                else {
                    QWRouter.sharedInstance().router(withUrlString: NSString.getRouterVCUrlString(fromUrlString: "book", andParams: params))
                }
                
            }
        }
        else{
            
            if indexPath.row == 0{
                guard let attentionVO = self.listVO?.results[indexPath.row] as? AttentionVO else {
                    return
                }
                if let vo = attentionVO.work {
                    var params = [String: String]()
                    params["book_url"] = vo.url
                    params["id"] = vo.nid?.stringValue
                    if attentionVO.work_type == .game {
                        QWRouter.sharedInstance().router(withUrlString: NSString.getRouterVCUrlString(fromUrlString: "gamedetail", andParams: params))
                    }
                    else {
                        QWRouter.sharedInstance().router(withUrlString: NSString.getRouterVCUrlString(fromUrlString: "book", andParams: params))
                    }
                    
                }

            }
            else if indexPath.row == 1 {
                return
            }
            else{
                guard let attentionVO = self.listVO?.results[indexPath.row - 1] as? AttentionVO else {
                    return
                }
                if let vo = attentionVO.work {
                    var params = [String: String]()
                    params["book_url"] = vo.url
                    params["id"] = vo.nid?.stringValue
                    if attentionVO.work_type == .game {
                        QWRouter.sharedInstance().router(withUrlString: NSString.getRouterVCUrlString(fromUrlString: "gamedetail", andParams: params))
                    }
                    else {
                        QWRouter.sharedInstance().router(withUrlString: NSString.getRouterVCUrlString(fromUrlString: "book", andParams: params))
                    }
                    
                }
            }
            
        }
        
    }
}
