//
//  QWActivityWorkVC.swift
//  Qingwen
//
//  Created by mumu on 2017/4/24.
//  Copyright © 2017年 iQing. All rights reserved.
//

import UIKit

class QWActivityWorkVC: QWBaseListVC {
    
    var url: String?
    @IBOutlet var contributionBtn: UIButton!
    
    @IBOutlet var headView: UIView!
    lazy var logic: QWActivityLogic = {
        return QWActivityLogic(operationManager: self.operationManager)
    }()
    
    override var listVO: PageVO? {
        return self.logic.activityWorkList
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.type = 1
        self.useSection = true
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configHeadView()
        if #available(iOS 11.0, *){
            self.tableView.contentInset = UIEdgeInsetsMake(self.view.safeAreaInsets.top+40, 0, self.view.safeAreaInsets.bottom, 0)
            self.headView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor).isActive = true
        }else{
            self.tableView.contentInset = UIEdgeInsetsMake(105, 0, 0, 0)
        }
        
        self.tableView.register(UINib(nibName: "QWBookTVCell", bundle: nil), forCellReuseIdentifier: "cell")
        self.tableView.tableFooterView = UIView()
        self.tableView.mj_header = QWRefreshHeader(refreshingBlock: { [weak self] () -> Void in
            self?.getData()
        })
        if let pageVC = self.parent as? QWActivityPageVC, let vo = pageVC.activityVO, vo.submit_enable?.intValue == 1 {
            self.contributionBtn.isHidden = false
        }
        self.getData()
    }
    
    func configHeadView() {
        let rankView = QWHeadChoiceView (titles: ["信仰", "战力", "更新", "字数"], fromPointX: 12.5)
        rankView.block = { [weak self](sender) in
            guard let weakSelf = self else {
                return
            }
            switch sender.tag {
            case 0: //信仰
                weakSelf.logic.order = "belief"
            case 1: //战力
                weakSelf.logic.order = "combat"
            case 2: //更新
                weakSelf.logic.order = "update"
            case 3: //字数
                weakSelf.logic.order = "count"
            default:
                break
            }
            weakSelf.tableView.mj_header.beginRefreshing()
        }
        self.headView.addSubview(rankView)

    }
    
    override func getData() {
        guard let url = url else {
            return
        }
        if self.logic.isLoading {
            return
        }
        self.showLoading()
        self.logic.isLoading = true
        self.tableView.emptyView.showError = false
        self.logic.activityWorkList = nil
        self.logic.getWorkListWithUrl(url) { [weak self] (_, _) in
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
        guard let url = url else {
            return
        }
        if self.logic.isLoading {
            return
        }
        self.logic.isLoading = true
        self.tableView.emptyView.showError = false
        self.logic.getWorkListWithUrl(url) { [weak self] (_, _) in
            if let weakSelf = self {
                weakSelf.logic.isLoading = false
                weakSelf.tableView.emptyView.showError = true
                weakSelf.tableView.reloadData()
            }
        }
    }
    @IBAction func onpressedContrbitionBetn(_ sender: Any) {
        guard QWGlobalValue.sharedInstance().isLogin() == true else{
            QWRouter.sharedInstance().routerToLogin()
            return;
        }
        if let pageVC = self.parent as? QWActivityPageVC, let vo = pageVC.activityVO{
            let vc = QWContributionInfoVC.createFromStoryboard(withStoryboardID: "info", storyboardName: "QWContribution", bundleName: nil)!
            let nvc = QWBaseNC(rootViewController: vc)
            vc.logic.activitys = [vo]
            pageVC.present(nvc, animated: true, completion: nil)
        }
        
//        var params = [String: String]()
//        params["activity_title"] = "1212"
//        QWRouter.sharedInstance().router(withUrlString: NSString.getRouterVCUrlString(fromUrlString: "submission", andParams: params))
    }
}

extension QWActivityWorkVC{
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    
    override func updateWithTVCell(_ cell: QWBaseTVCell, indexPath: IndexPath) {
        
        if let vo = listVO?.results[indexPath.section]{
            let cell = cell as! QWBookTVCell
            cell.updateWithVO(vo as AnyObject)
        }
    }
    
    override func didSelectedCellAtIndexPath(_ indexPath: IndexPath) {
        if let book = listVO?.results[indexPath.section] as? ActivityWorkVO, let book_url = book.url {
            
            var params = [String: String]()
//            params["id"] = book.nid?.stringValue
            params["book_url"] = book.url
            QWRouter.sharedInstance().router(withUrlString: NSString.getRouterVCUrlString(fromUrlString: (book_url as NSString).routerKey(), andParams: params))
        }
    }
}
