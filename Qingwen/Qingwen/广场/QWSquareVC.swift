//
//  QWSquareVC.swift
//  Qingwen
//
//  Created by mumu on 17/3/24.
//  Copyright © 2017年 iQing. All rights reserved.
//

import UIKit

class QWSquareVC: QWBaseVC {
    
    let identifer = "discuss"
    
    enum QWSquare: Int{
        case promotion
        case stoneRank
        case discuss
        case count
        
        case none = 9999
        
        init(section: Int) {
            if let type = QWSquare(rawValue: section) {
                self = type
            }
            else {
                self = .none
            }
        }
    }
    
    @IBOutlet weak var tableView: QWTableView!
    
    lazy var logic: QWSquareLogic = {
        return QWSquareLogic(operationManager: self.operationManager)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        self.tableView.tableFooterView = UIView()
        self.tableView.register(QWGeneralTVCell.self, forCellReuseIdentifier: identifer)
        self.getData()
        self.tableView.mj_header = QWRefreshHeader(refreshingBlock: { [weak self] () -> Void in
            self?.getData()
        })
        self.tableView.separatorStyle = .none
        
        
        let os = ProcessInfo().operatingSystemVersion
        
        switch  (os.majorVersion, os.minorVersion, os.patchVersion) {
        case  (10, _, _):
            self.tableView.contentInset = UIEdgeInsets(top: 64, left: 0, bottom: 49, right: 0)
        default :
            break
        }

        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        if let dict = QWGlobalValue.sharedInstance().systemSwitchesDic{
            
            if  dict["square"] as! Int == 2 {
                self.tableView.isHidden = true
                
                let view = QWAnnouncementView(frame:UIScreen.main.bounds)
                self.view.addSubview(view)
            }
            else if  dict["square"] as! Int == 1 {
                if QWGlobalValue.sharedInstance().isLogin() == false {
                    self.tableView.isHidden = true
                    let view = QWAnnouncementView(frame:UIScreen.main.bounds)
                    self.view.addSubview(view)
                    return;
                }
                else{
                    self.tableView.isHidden = false
                    
                }
                
            }
            else{
                
            }
            
        }
        
    }
    override func getData() {
        if self.logic.isLoading {
            return
        }
        var step = QWSquare.count.rawValue
        self.logic.getPromotionWithComplete { [weak self](_, _) in
            if let weakSelf = self {
                weakSelf.updateWithStep(&step)
            }
        }
        self.logic.getStoneRank { [weak self](_, _) in
            if let weakSelf = self {
                weakSelf.updateWithStep(&step)
            }
        }
        self.logic.getHotDuscussList { [weak self](_, _) in
            if let weakSelf = self {
                weakSelf.updateWithStep(&step)
            }
        }
        self.logic.getDiscussLastCount { [weak self](_, _) in
            if let weakSelf = self {
                weakSelf.tableView.reloadData()
            }
        }
        self.logic.getAchievementInfo{ [weak self](aResponseObject, anError) in
            
        }
        
    }
    
    func updateWithStep(_ step: inout Int) {
        step -= 1
        if step > 0 {
            return
        }
        
        self.logic.isLoading = false
        self.tableView.emptyView.showError = true
        self.tableView.mj_header.endRefreshing()
        self.tableView.reloadData()
    }
    override func update() {
        if self.logic.isLoading == false {
            self.tableView.mj_header.beginRefreshing()
        }
    }
    
    override func repeateClickTabBarItem(_ count: Int) {
        if count % 2 == 0 && self.logic.isLoading == false {
            self.update()
        }
    }
    
    @IBAction func onPressedSearchBtn(_ sender: AnyObject) {
        let sb = UIStoryboard(name: "QWSearch", bundle: nil)
        if let vc = sb.instantiateInitialViewController() {
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
}

extension QWSquareVC: UITableViewDelegate,  UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        if self.logic.isShow() {
            if self.logic.showHot(){
                return QWSquare.count.rawValue
            }
            else{
                return QWSquare.count.rawValue - 1
            }
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let type = QWSquare(section: section)
        switch type {
        case .promotion:
            if let vos = self.logic.promotionVO?.results {
                return vos.count
            }
            else {
                return 0
            }
        case .stoneRank:
            if self.logic.stoneRankVO == nil{
                return 1
            }
            else{
                return 1
            }
        case .discuss:
            let square_ad:String = QWGlobalValue.sharedInstance().square_ad!
            if square_ad == "2" {
                if let list = self.logic.hotDiscussList {
                    return list.count + 1
                }
                return 1
            }else{
                if let list = self.logic.hotDiscussList {
                    return list.count + 2
                }
                return 2
            }
            
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        tableView.separatorInset = UIEdgeInsetsMake(0, 12, 0, 12)
        switch QWSquare(section: indexPath.section) {
        case .promotion:
            let cell = tableView.dequeueReusableCell(withIdentifier: "promotion", for: indexPath) as! QWSquarePromotionTVCell
            if let promotion = self.logic.promotionVO?.results?[indexPath.row] as? PromotionVO {
                cell.updateWithPromotion(promotion)
            }
            
            return cell
        case .stoneRank:
            let cell = tableView.dequeueReusableCell(withIdentifier: "stonerank", for: indexPath) as! QWSquareStoneRankTVCell
            if self.logic.stoneRankVO == nil{
                cell.emptyImg.isHidden = false
                cell.nextBtn.isHidden = true
            }else{
                var dataArr = [Dictionary<String, Any>]()
                dataArr  = self.logic.stoneRankVO!["results"]! as! [Dictionary<String, Any>]
                if dataArr.count == 0{
                    cell.emptyImg.isHidden = false
                    cell.nextBtn.isHidden = true
                }
                else{
                    cell.emptyImg.isHidden = true
                    cell.emptyImg.removeFromSuperview()
                    cell.nextBtn.isHidden = false
                    if let stoneRank = self.logic.stoneRankVO {
                        cell.updateWithStoneRank(stoneRank as! Dictionary<String, Any>)
                    }
                }
            }
            return cell
        case .discuss:
            let square_ad:String = QWGlobalValue.sharedInstance().square_ad!
            if square_ad == "2" {
                if indexPath.row == 0 {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "header", for: indexPath)
                    let discussCountLabel = cell.viewWithTag(99) as! UILabel
                    if let count = self.logic.discussLastCount, count.intValue > 0 {
                        discussCountLabel.text = "+\(count)"
                    }
                    else {
                        discussCountLabel.text = ""
                    }
                    
                    return cell
                }
                else {
                    if let cell = QWGeneralTVCell(tableView: tableView) {
                        cell.subTitleColor = UIColor.colorQWPinkDark()
                        if let vo = self.logic.hotDiscussList?[indexPath.row - 1] as? QWGeneralCellConfigure {
//                            cell.cornerRadius = 23;
                            cell.update(withVO: vo)
                        }
                        let hui = UIView.init()
                        hui.frame = CGRect(x:10,y:0,width:QWSize.screenWidth(),height:1)
                        hui.backgroundColor = UIColor.colorDD()
                        cell.contentView.addSubview(hui)
                        return cell
                    }else {
                        return UITableViewCell()
                    }
                }
            }
            else{
                if indexPath.row == 0 {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "header", for: indexPath)
                    let discussCountLabel = cell.viewWithTag(99) as! UILabel
                    if let count = self.logic.discussLastCount, count.intValue > 0 {
                        discussCountLabel.text = "+\(count)"
                    }
                    else {
                        discussCountLabel.text = ""
                    }
                    
                    return cell
                }
                
                else if indexPath.row == 1{
                    let cell = tableView.dequeueReusableCell(withIdentifier: "adcell", for: indexPath) as! QWAdTVCell
                    cell.createUI(type: "Square")
                    return cell
                }
                else {
                    if let cell = QWGeneralTVCell(tableView: tableView) {
                        cell.subTitleColor = UIColor.colorQWPinkDark()
                        if let vo = self.logic.hotDiscussList?[indexPath.row - 2] as? QWGeneralCellConfigure {
//                            cell.cornerRadius = 23;
                            cell.update(withVO: vo)
                        }
                        let hui = UIView.init()
                        hui.frame = CGRect(x:10,y:0,width:QWSize.screenWidth(),height:1)
                        hui.backgroundColor = UIColor.colorDD()
                        cell.contentView.addSubview(hui)
                        return cell
                    }else {
                        return UITableViewCell()
                    }
                }
            }
            
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch QWSquare(section: indexPath.section) {
        case .promotion:
            if let _ = self.logic.promotionVO {
                
                return ceil((QWSize.screenWidth() - 20) * 0.3 + 20)

            }
            else {
                return 0
            }
        case .stoneRank:
            return 130
        case .discuss:
            let square_ad:String = QWGlobalValue.sharedInstance().square_ad!
            if square_ad == "2" {
                if indexPath.row == 0 {
                    return 93
                }
                else {
                    if let _ = self.logic.hotDiscussList {
                        return 66
                    }
                    else {
                        return 0
                    }
                }
            }else{
                if indexPath.row == 0 {
                    return 93
                }
                else if indexPath.row == 1{
                    return QWSize.bannerHeight()
                }
                else {
                    if let _ = self.logic.hotDiscussList {
                        return 66
                    }
                    else {
                        return 0
                    }
                }
            }
            
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return PX1_LINE
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return PX1_LINE
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch QWSquare(section: indexPath.section) {
        case .promotion:
            if let promotion = self.logic.promotionVO?.results?[indexPath.item] as? PromotionVO {
                QWRouter.sharedInstance().router(withUrlString: NSString.getRouterVCUrlString(fromUrlString: promotion.url) ?? "")
            }
        case .stoneRank:
            return
        case .discuss:
            let square_ad:String = QWGlobalValue.sharedInstance().square_ad!
            if square_ad == "2" {
                if indexPath.row == 0 {
                    var params = [String: String]()
                    params["title"] = "讨论"
                    params["url"] = "\(QWOperationParam.currentBfDomain())/brand/55dfe20f9d2fd159f2bbc125/"
                    QWRouter.sharedInstance().router(withUrlString: NSString.getRouterVCUrlString(fromUrlString: "discuss", andParams: params))
                }
                else {
                    guard let book = (self.logic.hotDiscussList?[indexPath.row - 1] as? SquareVO)?.detail, let bf_url = book.bf_url, let url = book.url else {
                        return
                    }
                    
                    var predicate = NSPredicate(format: "nid == \(book.nid!) && game == NO")
                    let type = (url as NSString).readingType()
                    if type == .game {
                        predicate = NSPredicate(format: "nid == \(book.nid!) && game == YES")
                    }
                    let bookCD = BookCD.mr_findFirst(with: predicate, in: QWFileManager.qwContext())
                    if let reply = (self.logic.hotDiscussList?[indexPath.row - 1] as? SquareVO)?.reply ,reply.intValue > 0, let bookCD = bookCD {
                        bookCD.lastViewDiscuss = Date()
                    }
                    QWFileManager.qwContext().mr_saveToPersistentStore(completion: nil)
                    
                    let discussVC = QWDiscussTVC.createFromStoryboard(withStoryboardID: "discuss", storyboardName: "QWDiscuss")!
                    discussVC.discussUrl = bf_url
                    discussVC.title = "讨论"
                    var vcs = self.navigationController?.viewControllers
                    if type == .game {
                        let detailTVC = QWDetailTVC.createFromStoryboard(withStoryboardID: "detail", storyboardName: "QWGame")!
                        detailTVC.book_url = url
                        vcs?.append(detailTVC)
                    }
                    else {
                        let detailTVC = QWDetailTVC.createFromStoryboard(withStoryboardID: "detail", storyboardName: "QWDetail")!
                        detailTVC.book_url = url
                        vcs?.append(detailTVC)
                    }
                    
                    vcs?.append(discussVC)
                    self.navigationController?.setViewControllers(vcs!, animated: true)
                }
            }else{
                if indexPath.row == 0 {
                    var params = [String: String]()
                    params["title"] = "讨论"
                    params["url"] = "\(QWOperationParam.currentBfDomain())/brand/55dfe20f9d2fd159f2bbc125/"
                    QWRouter.sharedInstance().router(withUrlString: NSString.getRouterVCUrlString(fromUrlString: "discuss", andParams: params))
                }
                else if indexPath.row == 1{
                    return
                }
                else {
                    guard let book = (self.logic.hotDiscussList?[indexPath.row - 2] as? SquareVO)?.detail, let bf_url = book.bf_url, let url = book.url else {
                        return
                    }
                    
                    var predicate = NSPredicate(format: "nid == \(book.nid!) && game == NO")
                    let type = (url as NSString).readingType()
                    if type == .game {
                        predicate = NSPredicate(format: "nid == \(book.nid!) && game == YES")
                    }
                    let bookCD = BookCD.mr_findFirst(with: predicate, in: QWFileManager.qwContext())
                    if let reply = (self.logic.hotDiscussList?[indexPath.row - 2] as? SquareVO)?.reply ,reply.intValue > 0, let bookCD = bookCD {
                        bookCD.lastViewDiscuss = Date()
                    }
                    QWFileManager.qwContext().mr_saveToPersistentStore(completion: nil)
                    
                    let discussVC = QWDiscussTVC.createFromStoryboard(withStoryboardID: "discuss", storyboardName: "QWDiscuss")!
                    discussVC.discussUrl = bf_url
                    discussVC.title = "讨论"
                    var vcs = self.navigationController?.viewControllers
                    if type == .game {
                        let detailTVC = QWDetailTVC.createFromStoryboard(withStoryboardID: "detail", storyboardName: "QWGame")!
                        detailTVC.book_url = url
                        vcs?.append(detailTVC)
                    }
                    else {
                        let detailTVC = QWDetailTVC.createFromStoryboard(withStoryboardID: "detail", storyboardName: "QWDetail")!
                        detailTVC.book_url = url
                        vcs?.append(detailTVC)
                    }
                    
                    vcs?.append(discussVC)
                    self.navigationController?.setViewControllers(vcs!, animated: true)
                }
            }
            
        default:
            break
        }
    }
}

