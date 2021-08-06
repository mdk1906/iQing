//
//  QWContributionListVC.swift
//  Qingwen
//
//  Created by Aimy on 10/26/15.
//  Copyright © 2015 iQing. All rights reserved.
//

import UIKit
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}


class QWContributionListVC: QWBaseListVC {

    lazy var logic: QWContributionLogic = {
        return QWContributionLogic(operationManager: self.operationManager)
    }()

    @IBOutlet var createBtn: UIBarButtonItem!
    @IBOutlet var infoBtn: UIButton!

    override var listVO: PageVO? {
        return self.logic.contributionBooks
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        type = 1
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 44, 0)
        self.tableView.backgroundColor = UIColor.white

        self.tableView.mj_header = QWRefreshHeader(refreshingBlock: { [weak self] () -> Void in
            self?.getData()
        })
        
        self.tableView.rowHeight = 158
        self.tableView.tableFooterView = UIView()
    }
    
    @IBAction func unwindToContributionListVC(_ sender: UIStoryboardSegue) {

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

        self.logic.contributionBooks = nil;
        self.tableView.emptyView.showError = false
        self.logic.getContributionsWithComplete { (aResponseObject, anError) -> Void in
            self.tableView.emptyView.showError = true
            self.logic.isLoading = false
            self.tableView.reloadData()
            self.tableView.mj_header.endRefreshing()
        }
    }

    override func getMoreData() {
        if self.logic.isLoading {
            return
        }

        self.logic.isLoading = true

        self.tableView.emptyView.showError = false
        self.logic.getContributionsWithComplete { (aResponseObject, anError) -> Void in
            self.tableView.emptyView.showError = true
            self.logic.isLoading = false
            self.tableView.reloadData()
            self.tableView.mj_header.endRefreshing()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if  let indexPath = sender as? IndexPath, segue.identifier == "edit"{
            let nc = segue.destination as! UINavigationController
            let vc = nc.topViewController as! QWContributionInfoVC
            vc.contributionVO = self.logic.contributionBooks?.results[indexPath.row] as? ContributionVO
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {

        return true
    }
    
    @IBAction func onPressedCreateBookBtn(_ sender: AnyObject) {
        if !QWBindingValue.sharedInstance().isBindPhone() {
            
            let alert = UIAlertView.bk_alertView(withTitle: "", message: "应国家相关法律法规规定，您必须绑定手机号码后方可投稿。") as! UIAlertView
            alert.bk_addButton(withTitle: "确定", handler: {
                var params = [String: AnyObject]()
                params["bind_phone"] = 1 as NSNumber
                QWRouter.sharedInstance().router(withUrlString: NSString.getRouterVCUrlString(fromUrlString: "myself", andParams: params))
            })
            alert.bk_setCancelButton(withTitle: "取消", handler: {
                
            })
            alert.show()
        }
        else {
            self.performSegue(withIdentifier: "add", sender: nil)
        }
    }
}

extension QWContributionListVC {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        if let list = self.logic.contributionBooks {
            return list.results.count + 1
        }
        else {
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        if self.logic.contributionBooks?.results.count == (indexPath as NSIndexPath).item && self.logic.contributionBooks?.results.count < self.logic.contributionBooks?.count?.intValue {
            getMoreData()
        }
        
        if let list = self.logic.contributionBooks {
            if indexPath.row <= list.results.count - 1  {
                let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! QWContributionListTVCell
                if let contributionVO = self.listVO?.results[indexPath.row] as? ContributionVO {
                    cell.updateWithContributionVO(contributionVO)
                }
                return cell
            }
            else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "add", for: indexPath)
                return cell
            }
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "add", for: indexPath)
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if(self.listVO?.results.count == nil){
            return
        }
        
        if indexPath.row <= (self.listVO?.results.count)! - 1  {
            self.performSegue(withIdentifier: "edit", sender: indexPath)
        }
        else {
            self.onPressedCreateBookBtn(self.navigationItem.rightBarButtonItem!)
        }
        didSelectedCellAtIndexPath(indexPath)
    }
}
