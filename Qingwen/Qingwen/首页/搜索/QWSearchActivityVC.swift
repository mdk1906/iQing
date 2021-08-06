//
//  QWSearchActivityVC.swift
//  Qingwen
//
//  Created by mumu on 2017/7/26.
//  Copyright © 2017年 iQing. All rights reserved.
//

import UIKit

class QWSearchActivityVC: QWActivityVC {
    
    lazy var searchLogic: QWSearchLogic = {
        return QWSearchLogic(operationManager: self.operationManager)
    }()
    
    var keyWords: String?
    var change = false
    
    let dataSource = [["活动时间"],["相关作品"],["相关评论"]]
    var choiceMainView: QWChoiceMainView?
    var lastPostion = CGFloat(0)

    override var listVO: PageVO? {
        return self.searchLogic.searchActivityListVO
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.choiceMainView = QWChoiceMainView.createWithNib()
        self.view.addSubview(self.choiceMainView!)
        self.choiceMainView?.updateButtons(withTitles: dataSource)
        self.choiceMainView?.delegate = self
        self.tableView.contentInset = UIEdgeInsetsMake(40, 0, 0, 0)
        if self.topic {
            self.tableView.emptyView.errorImage = UIImage(named: "empty_6_none")
            self.tableView.emptyView.errorMsg = "没有找到这专题~"
        }
        else {
            self.tableView.emptyView.errorImage = UIImage(named: "empty_6_none")
            self.tableView.emptyView.errorMsg = "没有找到这种活动~"
        }
    }
    
    override func getData() {
        if self.searchLogic.isLoading {
            return
        }
        if self.change == false {
            return
        }
        
        self.searchLogic.isLoading = true
        self.tableView.emptyView.showError = false
        self.searchLogic.searchActivityListVO = nil
        self.searchLogic.searchActivity(withKeywords: keyWords, topic: self.topic, andComplete: { (_, _) in
            self.tableView.emptyView.showError = true
            self.searchLogic.isLoading = false
            self.tableView.reloadData()
            self.change = false
        })
    }
    
    override func getMoreData() {
        if self.searchLogic.isLoading {
            return
        }
        
        self.searchLogic.isLoading = true
        self.tableView.emptyView.showError = false
        self.searchLogic.searchActivity(withKeywords: keyWords, topic: self.topic, andComplete: { (_, _) in
            self.tableView.emptyView.showError = true
            self.searchLogic.isLoading = false
            self.tableView.reloadData()
        })
    }
    
    override func update() {
        self.change = true
        self.getData()
    }
}

extension QWSearchActivityVC: QWChoiceMainViewDelegate {
    func choiceMainView(_ choiceMainView: QWChoiceMainView, didClickChoiceBtn button: (UIButton, NSNumber?)) {
        self.searchLogic.order = button.0.tag as NSNumber
        self.update()
    }

}
