//
//  QWProjectVC.swift
//  Qingwen
//
//  Created by qingwen on 2018/3/27.
//  Copyright © 2018年 iQing. All rights reserved.
//

import UIKit
extension QWProjectVC {
    override static func registMapping() {
        let vo = QWMappingVO()
        vo.className = NSStringFromClass(self)
        vo.storyboardID = "project"
        vo.storyboardName = "QWActivity"
        QWRouter.sharedInstance().register(vo, withKey: "projectlist")
    }
}
class QWProjectVC: QWBaseListVC {

    var topic = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.type = 1
        self.useSection = true
    }
    
    lazy var logic: QWActivityLogic = {
        return QWActivityLogic(operationManager: self.operationManager)
    }()
    
    override var listVO: PageVO? {
        return self.logic.activityList
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.tableFooterView = UIView()
        if #available(iOS 11.0, *){
            self.tableView.contentInset = UIEdgeInsetsMake(self.view.safeAreaInsets.top, 0, self.view.safeAreaInsets.bottom, 0);
            self.tableView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor).isActive = true
        }
        
        if let extraData = self.extraData {
            if let title = extraData.objectForCaseInsensitiveKey("title")  as? String {
                self.title = title
            }
            if let topic = extraData.objectForCaseInsensitiveKey("topic") as? NSNumber {
                if topic.intValue == 1 {
                    self.topic = true
                    self.logic.topic = topic
                    self.title = "专题"
                }
                else {
                    self.title = "活动"
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.getData()
    }
    
    override func getData() {
        if self.logic.isLoading {
            return
        }
        self.logic.isLoading = true
        self.logic.activityList = nil
        self.logic.getActivityListWithCompleteBlock { [weak self](_, _) in
            guard let weakSelf = self else {
                return
            }
            weakSelf.logic.isLoading = false
            weakSelf.tableView.reloadData()
        }
    }
    
    override func getMoreData() {
        if self.logic.isLoading {
            return
        }
        self.logic.isLoading = true
        self.logic.getActivityListWithCompleteBlock { [weak self](_, _) in
            guard let weakSelf = self else {
                return
            }
            weakSelf.logic.isLoading = false
            weakSelf.tableView.reloadData()
        }
    }
}

extension QWProjectVC {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let width = QWSize.screenWidth() - 24
        var height: CGFloat = 0
        if self.topic {
            height = width * 0.3 + 51
        }
        else {
            height = width * 0.3 + 94
        }
        return height
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 5
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = QWActivityCell()
        if self.topic {
            cell = tableView.dequeueReusableCell(withIdentifier: "topic", for: indexPath) as! QWActivityCell
        }
        else {
            cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! QWActivityCell
        }
        
        
        if #available(iOS 8.0, *) {
            cell.layoutMargins = UIEdgeInsets.zero
        }
        
        if let vo = self.listVO?.results[indexPath.section] as? ActivityVO {
            if self.topic {
                cell.updateCell(activityVO: vo)
            }
            else {
                cell.updateCell(activityVO: vo)
                cell.configOtherLable(activityVO: vo)
            }
        }
        
        if useSection {
            if let list = listVO?.results, let count = listVO?.count?.intValue, list.count == indexPath.section + 1, list.count < count {
                getMoreData()
            }
        }
        else {
            if let list = listVO?.results, let count = listVO?.count?.intValue {
                if list.count == indexPath.row + 1 && list.count < count {
                    getMoreData()
                    
                }
            }
        }
        return cell
    }
    
    override func didSelectedCellAtIndexPath(_ indexPath: IndexPath) {
        if let vo = self.listVO?.results[indexPath.section] as? ActivityVO {
            if self.topic {
                QWUserDefaults.sharedInstance()["topic_\(vo.nid!)"] = NSDate()
            }
            else {
                QWUserDefaults.sharedInstance()["activity_\(vo.nid!)"] = NSDate()
                
            }
            
            let sb = UIStoryboard(name: "QWActivity", bundle: nil)
            let vc = sb.instantiateViewController(withIdentifier: "activitypage") as! QWActivityPageVC
            vc.activityVO = vo
            vc.topic = self.topic
            vc.inId = "1"
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
