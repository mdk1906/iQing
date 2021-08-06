//
//  QWRankingVC.swift
//  Qingwen
//
//  Created by mumu on 17/3/29.
//  Copyright © 2017年 iQing. All rights reserved.
//

import UIKit

extension QWRankingVC {
    override class func registMapping() {
        let vo = QWMappingVO()
        vo.className = NSStringFromClass(self)
        vo.storyboardName = "QWBest"
        vo.storyboardID = "ranking"
        QWRouter.sharedInstance().register(vo, withKey: "ranking")
    }
}

class QWRankingVC: QWBaseListVC {
    
    @IBOutlet weak var headView: UIView!
    
    let channelView = QWFilterChannelView.createWithNib()!
    
    fileprivate lazy var logic: QWRankingLogic = {
        return QWRankingLogic(operationManager: self.operationManager)
    }()
    
    override var listVO: PageVO? {
        return self.logic.listVO
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.useSection = false
        type = 1
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configChannelView()
        self.configHeadView()
        
        self.tableView.register(UINib(nibName: "QWBookTVCell", bundle: nil), forCellReuseIdentifier: "cell")
        self.tableView.register(QWAdTVCell.self, forCellReuseIdentifier: "adcell")
//        self.tableView.contentInset = UIEdgeInsetsMake(105, 0, 0, 0)
        self.getData()
        
        self.tableView.mj_header = QWRefreshHeader(refreshingBlock: { [weak self] () -> Void in
            self?.getData()
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let dict = QWGlobalValue.sharedInstance().systemSwitchesDic{
            if  dict["home"] as! Int == 2 {
                self.tableView.isHidden = true
                self.channelView.isHidden = true
                let view = QWAnnouncementView(frame:UIScreen.main.bounds)
                self.view.addSubview(view)
            }
            else if  dict["home"] as! Int == 1 {
                if QWGlobalValue.sharedInstance().isLogin() == false {
                    self.tableView.isHidden = true
                    self.channelView.isHidden = true
                    let view = QWAnnouncementView(frame:UIScreen.main.bounds)
                    self.view.addSubview(view)
                    return;
                }
                else{
                    self.tableView.isHidden = false
                    self.channelView.isHidden = false
                }
                
            }
            else{
                
            }
            
        }
        
    }
    
    func configChannelView() {
        self.view.addSubview(channelView)
        if #available(iOS 11, *) {
            channelView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor,constant: 41).isActive = true
        }else{
            channelView.autoPinEdge(.top, to: .top, of: self.view, withOffset: 105)
        }
        channelView.autoPinEdge(.left, to: .left, of: self.view, withOffset: 0)
        channelView.autoSetDimension(.width, toSize: 61)
        channelView.autoPinEdge(.bottom, to: .bottom, of: self.view, withOffset: 0)
        
        channelView.delegate = self
    }
    
    func configHeadView() {
        let rankView = QWHeadChoiceView (titles: ["信仰", "战力"], fromPointX: 12.5)
        rankView.block = { [weak self](sender) in
            guard let weakSelf = self else {
                return
            }
            switch sender.tag {
            case 0: //信仰
                weakSelf.logic.rankType = 4
            case 1: //战力
                weakSelf.logic.rankType = 5
            default:
                break
            }
            weakSelf.tableView.mj_header.beginRefreshing()
        }
        let categoryView = QWHeadChoiceView(titles: ["全部", "新书"], fromPointX: rankView.right + 20)
        
        categoryView.block = {[weak self](sender) in
            guard let weakSelf = self else {
                return
            }
            switch sender.tag {
            case 0: //全部
                weakSelf.logic.category = 1
            case 1: //新书
                weakSelf.logic.category = 0
            default:
                break
            }
            weakSelf.tableView.mj_header.beginRefreshing()
        }
        
        let periodView = QWTestHeadChoiceView(titles: ["日榜", "周榜", "月榜"], toPointX: 10)
        periodView.block = {[weak self](sender) in
            guard let weakSelf = self else {
                return
            }
            switch sender.tag {
            case 0: //日榜
                weakSelf.logic.period = 0
            case 1: //周榜
                weakSelf.logic.period = 1
            case 2: //月榜
                weakSelf.logic.period = 2
            default:
                break
            }
            weakSelf.tableView.mj_header.beginRefreshing()
        }
        self.headView.addSubview(rankView)
        self.headView.addSubview(categoryView)
        self.headView.addSubview(periodView)
    }
    
    override func getData() {
        if self.logic.isLoading {
            return
        }
//        self.tableView.mj_header.beginRefreshing()
        self.showLoading()
        self.logic.isLoading = true
        self.tableView.emptyView.showError = false
        self.logic.listVO = nil
        self.logic.getListWithCompleteBlock { [weak self] (_, _) in
            if let weakSelf = self {
                weakSelf.hideLoading()
                weakSelf.logic.isLoading = false
                weakSelf.tableView.emptyView.showError = true
                weakSelf.tableView.reloadData()
                weakSelf.tableView.mj_header.endRefreshing()
            }
        }
    }
    
    override func getMoreData() {
        if self.logic.isLoading {
            return
        }
        self.logic.isLoading = true
        self.tableView.emptyView.showError = false
        self.logic.getListWithCompleteBlock { [weak self] (_, _) in
            if let weakSelf = self {
                weakSelf.logic.isLoading = false
                weakSelf.tableView.emptyView.showError = true
                weakSelf.tableView.reloadData()
            }
        }
    }
}

extension QWRankingVC: QWFilterChannelViewDelegate {
    func onPressedChannelBtn(_ sender: UIButton) {
        switch sender.tag {
        case 0:
            self.logic.channel = QWChannelType.typeNone
        case 1:
            self.logic.channel = QWChannelType.type10
        case 2:
            //            self.logic.channel = QWChannelType.type12
            self.logic.channel = QWChannelType.type11
        case 3:
//            self.logic.channel = QWChannelType.type13
            self.logic.channel = QWChannelType.type14
        case 4:
            self.logic.channel = QWChannelType.type99
            break;
        default:
            self.logic.channel = QWChannelType.typeNone
        }
        self.tableView.mj_header.beginRefreshing()
    }
}

extension QWRankingVC {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return PX1_LINE
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let brand_ad:String = QWGlobalValue.sharedInstance().brand_ad!
        if brand_ad == "2" {
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
        let brand_ad:String = QWGlobalValue.sharedInstance().brand_ad!
        if brand_ad == "2" {
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
        let brand_ad:String = QWGlobalValue.sharedInstance().brand_ad!
        if brand_ad == "2" {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! QWBookTVCell
            if let vo = self.listVO?.results[indexPath.row] {
                cell.updateWithVO(vo as AnyObject)
            }
            
            return cell
            
        }
        else{
            if self.listVO?.results.count == 0{
                let cell = tableView.dequeueReusableCell(withIdentifier: "adcell", for: indexPath) as! QWAdTVCell
                cell.createUI(type: "Brand")
                return cell
            }
            else{
                if indexPath.row == 0 {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! QWBookTVCell
                    if let vo = self.listVO?.results[indexPath.row] {
                        cell.updateWithVO(vo as AnyObject)
                    }
                    return cell
                }
                else if indexPath.row == 1 {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "adcell", for: indexPath) as! QWAdTVCell
                    cell.createUI(type: "Brand")
                    return cell
                }
                else{
                    let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! QWBookTVCell
                    if let vo = self.listVO?.results[indexPath.row - 1] {
                        cell.updateWithVO(vo as AnyObject )
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
                let brand_ad:String = QWGlobalValue.sharedInstance().brand_ad!
                if brand_ad == "2" {
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
    
    
    
    override func didSelectedCellAtIndexPath(_ indexPath: IndexPath) {
        let brand_ad:String = QWGlobalValue.sharedInstance().brand_ad!
        if brand_ad == "2" {
            if let book = listVO?.results[indexPath.row] as? BookVO, let book_url = book.url {
                
                var params = [String: String]()
                params["id"] = book.nid?.stringValue
                params["book_url"] = book.url
                QWRouter.sharedInstance().router(withUrlString: NSString.getRouterVCUrlString(fromUrlString: (book_url as NSString).routerKey(), andParams: params))
                
            }
        }
        else{
            if indexPath.row == 0{
                if let book = listVO?.results[indexPath.row] as? BookVO, let book_url = book.url {
                    
                    var params = [String: String]()
                    params["id"] = book.nid?.stringValue
                    params["book_url"] = book.url
                    QWRouter.sharedInstance().router(withUrlString: NSString.getRouterVCUrlString(fromUrlString: (book_url as NSString).routerKey(), andParams: params))
                    
                }
            }
            else if indexPath.row == 1 {
                return
            }
            else{
                if let book = listVO?.results[indexPath.row - 1] as? BookVO, let book_url = book.url {
                    
                    var params = [String: String]()
                    params["id"] = book.nid?.stringValue
                    params["book_url"] = book.url
                    QWRouter.sharedInstance().router(withUrlString: NSString.getRouterVCUrlString(fromUrlString: (book_url as NSString).routerKey(), andParams: params))
                    
                }
            }
            
            
        }
        
    }
    
}
