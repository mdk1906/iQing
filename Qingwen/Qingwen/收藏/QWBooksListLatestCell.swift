//
//  QWBooksListLatestCell.swift
//  Qingwen
//
//  Created by wei lu on 6/02/18.
//  Copyright © 2018 iQing. All rights reserved.
//
import UIKit

class QWBooksListLatestCell:QWBaseCVCell{
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
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setUpViews()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //setUpViews()
        
    }
    
    func setUpViews(){
        self.contentView.addSubview(self.bodyTableView)
        self.bodyTableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
        self.bodyTableView.autoPinEdge(.top, to: .top, of: self.contentView)
        self.bodyTableView.autoPinEdge(.left, to: .left, of: self.contentView)
        self.bodyTableView.autoPinEdge(.right, to: .right, of: self.contentView)
        self.bodyTableView.autoPinEdge(.bottom, to: .bottom, of: self.contentView)
    }
    
    func updateItemWithData(_ faithData:UserPageVO){
        self.faithData = faithData
    }
    
    
}



extension QWBooksListLatestCell:UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(section == 0){
            return 2
        }
        else if (section == 1){
            if let cnt = self.awardData?.results.count,cnt > 0 {
                return 1 + cnt;
            }
            else {
                return 2;
            }
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(indexPath.section == 0 && indexPath.row == 1){
            return 85
        }
        else{
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
            self.bodyTableView.register(QWFaithPointTVCell.self, forCellReuseIdentifier: "chargecell")
            if let cell = tableView.dequeueReusableCell(withIdentifier: "chargecell", for: indexPath) as? QWFaithPointTVCell{
                
                if (self.faithData != nil){
                   cell.updateChagreWithListVO(self.faithData!, chargeType: 2)
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
                cell.textLabel?.textColor = UIColor(hex:0x505050)
                cell.accessoryType = .none;
                cell.detailTextLabel?.text = "";
                return cell;
            }
            else {
                if let cnt = self.awardData?.results.count,cnt > 0 {
                    tableView.register(QWAwardPointCell.self, forCellReuseIdentifier: "awardDetials")
                    if let cell = tableView.dequeueReusableCell(withIdentifier: "awardDetials", for: indexPath) as? QWAwardPointCell{
                        cell.empty = false
                        cell.updateWithUser(self.awardData?.results[indexPath.row - 1] as! UserVO)
                        cell.updateAwardWithUserVO(self.awardData?.results[indexPath.row - 1] as! UserVO)
                         return cell;
                    }
                }
                else {
                    tableView.register(QWAwardPointCell.self, forCellReuseIdentifier: "awardDetials")
                    if let cell = tableView.dequeueReusableCell(withIdentifier: "awardDetials", for: indexPath) as? QWAwardPointCell{
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
        else {
//            if (self.logic.heavyUserPageVO.results.count == 0) {
//                [self doCharge:YES];
//                return ;
//            }
        }
    }
   
}
