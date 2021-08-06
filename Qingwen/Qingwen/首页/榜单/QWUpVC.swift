//
//  QWUpVC.swift
//  Qingwen
//
//  Created by mumu on 17/3/30.
//  Copyright © 2017年 iQing. All rights reserved.
//

import UIKit

class QWUpVC: QWRankingVC {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    fileprivate lazy var logic: QWUpLogic = {
        return QWUpLogic(operationManager: self.operationManager)
    }()
    
    override var listVO: PageVO? {
        return self.logic.listVO
    }

    override func configHeadView() {
        let categoryView = QWHeadChoiceView(titles: ["全部", "新书"], fromPointX: 10)
        
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
        self.headView .addSubview(categoryView)
    }
    
    override func getData() {
        if self.logic.isLoading {
            return
        }
        self.showLoading()
        self.logic.isLoading = true
        self.tableView.emptyView.showError = false
        self.logic.listVO = nil
        self.logic.getUpListWithCompleteBlock { [weak self] (_, _) in
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
        self.logic.getUpListWithCompleteBlock { [weak self] (_, _) in
            if let weakSelf = self {
                weakSelf.logic.isLoading = false
                weakSelf.tableView.emptyView.showError = true
                weakSelf.tableView.reloadData()
            }
        }
    }
}
extension QWUpVC {
    
    
    override func onPressedChannelBtn(_ sender: UIButton) {
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
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return PX1_LINE
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let upper_ad:String = QWGlobalValue.sharedInstance().upper_ad!
        if upper_ad == "2" {
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
        let upper_ad:String = QWGlobalValue.sharedInstance().upper_ad!
        if upper_ad == "2" {
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
        let upper_ad:String = QWGlobalValue.sharedInstance().upper_ad!
        if upper_ad == "2" {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! QWBookTVCell
            if let vo = self.listVO?.results[indexPath.row] {
                cell.updateWithVO(vo as AnyObject)
            }
            
            return cell
            
        }
        else{
            if self.listVO?.results.count == 0{
                let cell = tableView.dequeueReusableCell(withIdentifier: "adcell", for: indexPath) as! QWAdTVCell
                cell.createUI(type: "Upper")
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
                    cell.createUI(type: "Upper")
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
                let upper_ad:String = QWGlobalValue.sharedInstance().upper_ad!
                if upper_ad == "2" {
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
        let brand_ad:String = QWGlobalValue.sharedInstance().upper_ad!
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
