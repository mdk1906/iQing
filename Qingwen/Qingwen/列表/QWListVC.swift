//
//  QWListVC.swift
//  Qingwen
//
//  Created by Aimy on 10/12/15.
//  Copyright © 2015 iQing. All rights reserved.
//

extension QWListVC {
    override class func registMapping() {
        let vo = QWMappingVO()
        vo.className = NSStringFromClass(self)
        vo.storyboardName = "QWList"
        QWRouter.sharedInstance().register(vo, withKey: "list")
    }

    override class func getStoryBoardIDOrNibNameWithType(_ type: Int) -> String? {
        return type == 0 ? "listcvc" : "listtvc"
    }
}

class QWListVC: QWBaseListVC {

    var book_url: String?

    var params = [String: AnyObject]()

    @IBOutlet var filterBtn: UIBarButtonItem!
    var filterVC: QWListFilterVC?

    override var listVO: PageVO? {
        return self.logic.listVO
    }

    dynamic var count: Int = 0

    lazy var logic: QWListLogic = {
        return QWListLogic(operationManager: self.operationManager)
        }()

    override func viewDidLoad() {
        super.viewDidLoad()

        if self.parent is QWUserDetailVC {
            self.automaticallyAdjustsScrollViewInsets = false
        }
        else if self.parent is UINavigationController == false {
            self.automaticallyAdjustsScrollViewInsets = false
            self.tableView.contentInset = UIEdgeInsetsMake(64, 0, 49, 0)
            self.collectionView.contentInset = UIEdgeInsetsMake(64, 0, 49, 0)
        }

        self.navigationItem.rightBarButtonItem = self.filterBtn

        if let extraData = self.extraData {
            if let title = extraData.objectForCaseInsensitiveKey("title") as? String {
                self.title = title
            }

            if let listVO = extraData.objectForCaseInsensitiveKey("list") as? String {
                self.logic.listVO = ListVO.vo(withJson: listVO)
                self.collectionView.reloadData()
            }

            if let book_url = extraData.objectForCaseInsensitiveKey("book_url") as? String {
                self.book_url = book_url
            }

            if let channelType = extraData.objectForCaseInsensitiveKey("channel") as? NSNumber {
                self.logic.channelType = QWChannelType(rawValue: UInt(channelType.uintValue))!
            }

            if let sortType = extraData.objectForCaseInsensitiveKey("sort") as? NSNumber {
                self.logic.sortType = QWSortType(rawValue: UInt(sortType.uintValue))!
            }

            if let _ = extraData.objectForCaseInsensitiveKey("hidefilter") as? NSNumber {
                self.navigationItem.rightBarButtonItem = nil
            }

            if let game = extraData.objectForCaseInsensitiveKey("game") as? NSNumber {
                self.game = game.boolValue
            }

        }

        if let period = params["period"] as? NSNumber {
            self.logic.period = period
        }
        
        self.collectionView.mj_header = QWRefreshHeader(refreshingBlock: { [weak self] () -> Void in
            self?.getData()
            })

        self.tableView.mj_header = QWRefreshHeader(refreshingBlock: { [weak self] () -> Void in
            self?.getData()
            })

        getData()
    }

    override func getData() {
        guard let _ = self.book_url else {
            return
        }

        if self.logic.isLoading {
            return
        }

        self.logic.isLoading = true

        self.logic.listVO = nil;
        self.tableView.emptyView.showError = false
        self.collectionView.emptyView.showError = false

        self.logic.getWithUrl(self.book_url) { [weak self] (aResponseObject, anError) -> Void in
            if let weakSelf = self {
                if let count = weakSelf.logic.listVO?.count {
                    weakSelf.count = count.intValue
                }
                
                weakSelf.collectionView.reloadData()
                weakSelf.collectionView.emptyView.showError = true
                weakSelf.tableView.reloadData()
                weakSelf.tableView.emptyView.showError = true
                weakSelf.logic.isLoading = false
                weakSelf.hideLoading()
                
                weakSelf.tableView.mj_header.endRefreshing()
                weakSelf.collectionView.mj_header.endRefreshing()
            }
        }
    }

    override func getMoreData() {
        guard let _ = self.book_url else {
            return
        }

        if self.logic.isLoading {
            return
        }

        self.logic.isLoading = true

        self.tableView.emptyView.showError = false
        self.collectionView.emptyView.showError = false

        self.logic.getWithUrl(self.book_url) { [weak self] (aResponseObject, anError) -> Void in
            if let weakSelf = self {
                weakSelf.collectionView.reloadData()
                weakSelf.collectionView.emptyView.showError = true
                weakSelf.tableView.reloadData()
                weakSelf.tableView.emptyView.showError = true
                weakSelf.tableView.tableFooterView = nil
                weakSelf.logic.isLoading = false
            }
        }
    }

    @IBAction func onPressedFilterBtn(_ sender: UIBarButtonItem) {
        if let _ = self.filterVC {
            return ;
        }

        let filterVC = QWListFilterVC.createFromStoryboard(withStoryboardID: "filter", storyboardName: "QWList")!
        filterVC.delegate = self
        self.navigationController?.view.addSubview(filterVC.view)
        filterVC.view.autoPinEdge(.left, to: .left, of: (self.navigationController?.view)!)
        filterVC.view.autoPinEdge(.right, to: .right, of: (self.navigationController?.view)!)
        filterVC.view.autoPinEdge(.bottom, to: .bottom, of: (self.navigationController?.view)!)
        filterVC.view.autoPinEdge(.top, to: .top, of: (self.navigationController?.view)!)
        filterVC.view.layoutIfNeeded()
        self.filterVC = filterVC
        self.filterVC?.show(category: self.logic.channelType, sort: self.logic.sortType)
    }
}

extension QWListVC: QWListFilterVCDelegate {
    func doFilter(_ category: QWChannelType, sort: QWSortType) {
        self.logic.channelType = category
        self.logic.sortType = sort
        self.showLoading()
        getData()
        self.cancelFilter()
    }

    func cancelFilter() {
        if let filterVC = self.filterVC {
            filterVC.hide({ [weak self] () -> Void in
                self?.filterVC = nil
            })
        }
    }
}

extension QWListVC {
    override func updateWithCVCell(_ cell: QWBaseCVCell, indexPath: IndexPath) {
        if let vo = self.listVO?.results[(indexPath as NSIndexPath).item] as? BookVO {
            let cell = cell as! QWListCVCell
            if game {
                cell.updateWithGameVO(vo)
            } else  {
                cell.updateWithBookVO(vo)
            }
            cell.updateWithIndexPath(indexPath)
        }
    }

    override func updateWithTVCell(_ cell: QWBaseTVCell, indexPath: IndexPath) {
        if let vo = self.listVO?.results[(indexPath as NSIndexPath).row] as? BookVO {
            let cell = cell as! QWListTVCell
            cell.updateWithBookVO(vo)
            cell.updateWithIndexPath(indexPath)
        }
    }

    override func didSelectedCellAtIndexPath(_ indexPath: IndexPath) {
        let index = self.type == 0 ? (indexPath as NSIndexPath).item : (indexPath as NSIndexPath).row
        if game {
            if let vo = self.logic.listVO?.results[index] as? BookVO {
                var params = [String: String]()
                params["book_url"] = vo.url
                params["id"] = vo.nid?.stringValue
                QWRouter.sharedInstance().router(withUrlString: NSString.getRouterVCUrlString(fromUrlString: "gamedetail", andParams: params))
            }
        }
        else {
            if let vo = self.logic.listVO?.results[index] as? BookVO {
                var params = [String: String]()
                params["book_url"] = vo.url
                params["id"] = vo.nid?.stringValue
                QWRouter.sharedInstance().router(withUrlString: NSString.getRouterVCUrlString(fromUrlString: "book", andParams: params))
            }
        }
    }
}
