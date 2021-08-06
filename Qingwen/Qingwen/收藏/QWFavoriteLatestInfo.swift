//
//  QWFavoriteLatestInfo.swift
//  Qingwen
//
//  Created by wei lu on 9/02/18.
//  Copyright © 2018 iQing. All rights reserved.
//

import UIKit

class QWFavoriteLatestInfo:QWBaseVC{
    lazy var bodyTableView:QWTableView = {
        let table = QWTableView()
        table.isScrollEnabled = false
        table.delegate = self
        table.dataSource = self
        return table
    }()
    var faithData:UserPageVO?
    var awardData:UserPageVO?
    var listID:NSNumber?
    
    lazy var logic: QWGetBookslistDetailsLogic = {
        let logic = QWGetBookslistDetailsLogic(operationManager: self.operationManager)
        return logic
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpViews()
        self.bodyTableView.register(QWFaithPointTVCell.self, forCellReuseIdentifier: "chargecell")
        self.bodyTableView.register(QWAwardPointCell.self, forCellReuseIdentifier: "cellID")
        self.logic.isLoading = false
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.getData()
    }
    
    func setUpViews(){
        self.view.addSubview(self.bodyTableView)
        self.bodyTableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
        self.bodyTableView.autoPinEdge(.top, to: .top, of: self.view)
        self.bodyTableView.autoPinEdge(.left, to: .left, of: self.view)
        self.bodyTableView.autoPinEdge(.right, to: .right, of: self.view)
        self.bodyTableView.autoPinEdge(.bottom, to: .bottom, of: self.view)
    }
    
    func updateItemWithData(_ faithData:UserPageVO){
        self.faithData = faithData
    }
    
    override func getData(){
//        if self.logic.isLoading {
//            return
//        }
        self.showLoading()
        //self.booksListCollectionView.emptyView.showError = false
        self.logic.awardDymicPageVO = nil
        self.logic.faithPointsPage = nil
        self.logic.isLoading = true
        var step = 1
        self.logic.getFaithPointBlock(listId: self.listID){ [weak self] (aResponseObject,anError) in
            if let weakSelf = self {
                weakSelf.hideLoading()
                if let anError = anError as NSError?{
                    weakSelf.showToast(withTitle: anError.userInfo[NSLocalizedDescriptionKey] as? String, subtitle: nil, type: .alert)
                    weakSelf.logic.faithPointsPage = nil
                }
                else if(aResponseObject != nil){
                    weakSelf.updateWithStep(&step)
                }
            }
        }
                
                
        self.logic.getAwardsLatestBlock(listId: self.listID){ [weak self] (aResponseObject,anError) in
            if let weakSelf = self {
                weakSelf.hideLoading()
                if let anError = anError as NSError?{
                    weakSelf.showToast(withTitle: anError.userInfo[NSLocalizedDescriptionKey] as? String, subtitle: nil, type: .alert)
                    weakSelf.logic.awardDymicPageVO = nil
                }
                else if(aResponseObject != nil){
                    weakSelf.updateWithStep(&step)
                }
            }
        }

    }
    
    func updateWithStep(_ step: inout Int) {
        step -= 1
        if step > 0 {
            return
        }
        self.logic.isLoading = false
        self.bodyTableView.reloadData()
    }
    
}



extension QWFavoriteLatestInfo:UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(section == 0){
            return 2
        }
        else if (section == 1){
            if(self.logic.awardDymicPageVO?.results == nil){
                return 0
            }
            if let cnt = self.logic.awardDymicPageVO?.results.count,cnt > 0 {
                if(cnt > 3){
                    return 4
                }else{
                    return 1 + cnt;
                }
                
            }
            else {
                return 2;
            }
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(indexPath.section == 0 && indexPath.row == 1){
            return 85
        }else{
            return 49
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(indexPath.section == 0 && indexPath.row == 0){//信仰殿堂入口
            tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
            let cell: UITableViewCell = UITableViewCell(style: .value1, reuseIdentifier: "cell")
            cell.imageView?.image = UIImage(named: "detail_list_icon_7")
            cell.textLabel?.attributedText = nil
            cell.textLabel?.text = "信仰殿堂"
            cell.textLabel?.textColor = UIColor(hex:0x505050)
            if let cnt = self.faithData?.results.count,cnt > 0{
                cell.accessoryType = .disclosureIndicator
                cell.detailTextLabel?.text = "查看更多"
            }else{
                cell.accessoryType = .none
                cell.detailTextLabel?.text = ""
            }
            return cell
            
        }
        
        if(indexPath.section == 0 && indexPath.row == 1){//信仰殿堂用户
            
            if let cell = tableView.dequeueReusableCell(withIdentifier: "chargecell", for: indexPath) as? QWFaithPointTVCell{
                
                if (self.logic.faithPointsPage != nil){
                    cell.updateChagreWithListVO(self.self.logic.faithPointsPage!, chargeType: 2)
                }
                return cell
            }
        }
        if(indexPath.section == 1){//投石动态
            if (indexPath.row == 0) {
                tableView.register(UITableViewCell.self, forCellReuseIdentifier: "awardcell")
                let cell: UITableViewCell = UITableViewCell(style: .value1, reuseIdentifier: "awardcell")
                
                cell.imageView?.image = UIImage(named: "detail_list_icon_award")
                cell.textLabel?.attributedText = nil;
                cell.textLabel?.text = "投石动态";
                cell.accessoryType = .none;
                cell.detailTextLabel?.text = "";
                return cell;
            }
            else {
                if let cnt = self.logic.awardDymicPageVO?.results.count,cnt > 0 {
                    
                    if let cell = tableView.dequeueReusableCell(withIdentifier: "cellID", for: indexPath) as? QWAwardPointCell{
                        cell.empty = false
                        cell.showEmptyView()
                        cell.updateWithUser(self.logic.awardDymicPageVO?.results[indexPath.row - 1] as! UserVO)
                        cell.updateAwardWithUserVO(self.logic.awardDymicPageVO?.results[indexPath.row - 1] as! UserVO)
                        return cell;
                    }
                }
                else {
                    if let cell = tableView.dequeueReusableCell(withIdentifier: "cellID", for: indexPath) as? QWAwardPointCell{
                        cell.empty = true
                        cell.showEmptyView()
                        return cell;
                    }
                    
                }
            }
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath.section == 0 && indexPath.row == 0) {
            if (self.faithData == nil || self.listID == nil) {
                return;
            }else if(self.faithData!.results.count == 0){
                return;
            }
            var params = [String:Any]()
            let url = "/favorite/"+self.listID!.stringValue+"/points/"
            params["url"] = QWOperationParam.currentFAVBooksDomain()+url
            params["title"] = "信仰殿堂";
            params["gold"] = 2;
            params["v4"] = true;
            QWRouter.sharedInstance().router(withUrlString: NSString.getRouterVCUrlString(fromUrlString: "userlist", andParams: params))
        }
        else if(indexPath.section == 0 && indexPath.row == 1){
            if (self.logic.awardDymicPageVO?.results.count == 0) {
//                [self doCharge:YES];
                return ;
            }
        }
    }
    
}
