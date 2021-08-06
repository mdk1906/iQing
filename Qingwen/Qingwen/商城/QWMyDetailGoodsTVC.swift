//
//  QWMyDetailGoodsTVC.swift
//  Qingwen
//
//  Created by mumu on 16/10/27.
//  Copyright © 2016年 iQing. All rights reserved.
//

import UIKit

class QWMyDetailGoodsTVC:  QWBaseListVC{

    lazy var logic: QWShopLogic = {
        return QWShopLogic(operationManager: self.operationManager)
    }()
    
    override var listVO: PageVO? {
        return self.logic.sigelePropsList
    }
    var url: String?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.getData()
        self.tableView.tableFooterView = UIView()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "icon_help"), style: .plain, target: self, action: #selector(QWMyDetailGoodsTVC.onPressedRightBarBtn(_:)))
    }

    override func getData() {
        
        guard let url = url else {
            return
        }
        if self.logic.isLoading {
            return
        }
        self.logic.isLoading = true
        self.logic.propsList = nil
        self.tableView.emptyView.showError = false
        self.logic.getMyDetailPropsListWithUrl(url: url) { [weak self](_, _) in
            if let weakSelf = self {
                weakSelf.logic.isLoading = false
                weakSelf.tableView.emptyView.showError = true
                weakSelf.tableView.reloadData()
            }
        }
    }
    override func getMoreData() {
        guard let url = url else {
            return
        }
        if self.logic.isLoading {
            return
        }
        self.logic.isLoading = true
        self.tableView.emptyView.showError = false
        self.logic.getMyDetailPropsListWithUrl(url: url) { [weak self](_, _) in
            if let weakSelf = self {
                weakSelf.logic.isLoading = false
                weakSelf.tableView.emptyView.showError = true
                weakSelf.tableView.reloadData()
            }
        }
    }
    
    func onPressedRightBarBtn(_ sender: UIButton) {
        print("onPressedRightBarBtn")
        var params = [String: String]()
        params["title"] = "购书券"
        params["localurl"] = Bundle.main.path(forResource: "shopticket_help", ofType: "html")
        QWRouter.sharedInstance().router(withUrlString: NSString.getRouterVCUrlString(fromUrlString: "web", andParams: params))
    }
}

extension QWMyDetailGoodsTVC {
    override func updateWithTVCell(_ cell: QWBaseTVCell, indexPath: IndexPath) {
        if let singlePropsVO = self.listVO?.results[indexPath.section] as? SinglePropsVO {
            let cell = cell as! QWMyDetailPropsTVCell
            cell.update(singlePropsVO: singlePropsVO)
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if let vos = self.listVO?.results {
            return vos.count
        }
        
        return 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath as IndexPath) as! QWBaseTVCell
        
        if #available(iOS 8.0, *) {
            cell.layoutMargins = UIEdgeInsets.zero
        }
        
        updateWithTVCell(cell, indexPath: indexPath as IndexPath)
        
        if let list = listVO?.results, let count = listVO?.count?.intValue {
            if list.count == indexPath.row + 1 && list.count < count {
                getMoreData()
                
            }
        }
        
        return cell
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 15
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return PX1_LINE
    }
    override func didSelectedCellAtIndexPath(_ indexPath: IndexPath) {
        
    }
}
