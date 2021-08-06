//
//  QWUpdatePageVC.swift
//  Qingwen
//
//  Created by mumu on 16/10/27.
//  Copyright © 2016年 iQing. All rights reserved.
//

import UIKit

class QWUpdateVC: QWBaseListVC {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.type = 1
    }
    
    lazy var logic: QWListLogic = {
        return QWListLogic(operationManager: self.operationManager)
    }()
    var url = "\(QWOperationParam.currentDomain())/book/all_works/"
    
    @IBOutlet weak var zoneTypeBtn: UIButton! //全站  各大分区
    @IBOutlet weak var updateBtn: UIButton! //最近更新
    @IBOutlet weak var categoryBtn: UIButton!  //全部、新书
    
    override var listVO: PageVO? {
        if let list =  self.logic.listVO {
            return list
        }
        else {
            return self.logic.listVO
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.contentInset = UIEdgeInsetsMake(40, 0, 0, 0)
        getData()
    }
    
    override func getData() {
        if self.logic.isLoading {
            return
        }
        
        self.tableView.emptyView.showError = false
        self.logic.isLoading = true
        self.logic.listVO = nil
        self.showLoading()
        self.logic.getWithUrl1(url) { [weak self](_, _) in
            if let weakSelf = self {
                weakSelf.hideLoading()
                weakSelf.logic.isLoading = false
                weakSelf.tableView.emptyView.showError = true
                weakSelf.tableView.reloadData()
            }
        }
    }
    
    override func getMoreData() {
        if self.logic.isLoading {
            return
        }
        self.tableView.emptyView.showError = false

        self.logic.isLoading = true
        
        self.logic.getWithUrl1(url) { [weak self](_, _) in
            if let weakSelf = self {
                weakSelf.logic.isLoading = false
                weakSelf.tableView.emptyView.showError = true
                weakSelf.tableView.reloadData()
            }
        }
    }
    var pop = QWPopoverView()

    @IBAction func onPressedZoneTypeBtn(_ sender: UIButton) {
        pop.dismiss()
        let point = CGPoint(x:0, y:sender.frame.origin.y + sender.frame.size.height)
        let titles = ["  全站", "  原创",  "  女性向", "  文库本","  演绘"]
        pop = QWPopoverView(point: point, titles: titles, currentSelected: sender.titleLabel?.text, images: nil)
        pop.selectRowAtIndex = {[weak self](index) in
            if let weakSelf = self {
                if (sender.titleLabel!.text! as NSString).isEqual(to: titles[index]) {
                    return
                }
                weakSelf.game = false

                weakSelf.zoneTypeBtn.setTitle(titles[index], for: .normal)
                if (titles[index] as NSString).isEqual(to: "  演绘"){
                    weakSelf.game = true
                }
                
                weakSelf.zoneTypeBtn.setTitle(titles[index], for: .normal)
                switch index {
                case 0:
                    weakSelf.logic.channelType = .typeNone
                case 1:
                    weakSelf.logic.channelType = .type10
                case 2:
//                    weakSelf.logic.channelType = .type12
                    weakSelf.logic.channelType = .type11
                case 3:
                    weakSelf.logic.channelType = .type14
                case 4:
                    weakSelf.logic.channelType = .type99
                default:
                    break
                }
                weakSelf.url = "\(QWOperationParam.currentDomain())/book/all_works/"
                weakSelf.getData()
            }
        }
        self.pop.show()
    }
    
    @IBAction func onPressedUpdateBtn(_ sender: UIButton) {
        pop.dismiss()
        let point = CGPoint(x:0, y:sender.frame.origin.y + sender.frame.size.height)
        let titles = ["  最近更新", "  最近上升", "  累计人气", "  累计收藏"]
        pop = QWPopoverView(point: point, titles: titles, currentSelected: sender.titleLabel?.text, images: nil)
        pop.selectRowAtIndex = {[weak self](index) in
            if let weakSelf = self {
                if (sender.titleLabel!.text! as NSString).isEqual(to: titles[index]) {
                    return
                }
                weakSelf.updateBtn.setTitle(titles[index], for: .normal)
                switch index {
                case 0:
                    weakSelf.logic.order = "update"
                case 1:
                    weakSelf.logic.order = "gold"
                case 2:
                    weakSelf.logic.order = "views"
                case 3:
                    weakSelf.logic.order = "follow"
                default:
                    break
                }
                weakSelf.getData()
            }
        }
        self.pop.show()
    }
    @IBAction func onPressedCategoryBtn(_ sender: UIButton) {
        pop.dismiss()
        let point = CGPoint(x:0, y:sender.frame.origin.y + sender.frame.size.height)
        let titles = ["  全部", "  新作"]
        pop = QWPopoverView(point: point, titles: titles, currentSelected: sender.titleLabel?.text, images: nil)
        pop.selectRowAtIndex = {[weak self](index) in
            if let weakSelf = self {
                if (sender.titleLabel!.text! as NSString).isEqual(to: titles[index]) {
                    return
                }
                weakSelf.categoryBtn.setTitle(titles[index], for: .normal)
                switch index {
                case 0:
                    weakSelf.logic.works = "all"
                case 1:
                    weakSelf.logic.works = "new"
                default:
                    break
                }
                weakSelf.getData()
            }
        }
        self.pop.show()
    }
    
    override func leftBtnClicked(_ sender: AnyObject?) {
        pop.dismiss()
        _ = self.navigationController?.popViewController(animated: true)
    }
}

extension QWUpdateVC {
//    func numberOfSectionsInTableView(_ tableView: UITableView) -> Int {
//        if let vo = self.logic.listVO?.results {
//            return vo.count
//        }
//        return 0
//    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let count = self.logic.listVO?.results.count, count == indexPath.section + 1,
            let resultsCount = self.logic.listVO?.count?.intValue, count < resultsCount{
            
            getMoreData()
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath as IndexPath) as! QWUpdateListTVCell
        
        if #available(iOS 8.0, *) {
            cell.layoutMargins = UIEdgeInsets.zero
        }
        if let vo = self.logic.listVO?.results[indexPath.section] as? BookVO{
            cell.updateWithBookVO(vo)
            
            cell.updateWithIndexPath(indexPath as IndexPath)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return PX1_LINE
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return PX1_LINE
    }
    override func didSelectedCellAtIndexPath(_ indexPath: IndexPath) {
        let index = indexPath.section
        if game {
            if let vo = self.logic.listVO?.results[index] as? BookVO {
                var params = [String: AnyObject]()
                params["book_url"] = vo.url as AnyObject?
                params["id"] = vo.nid?.stringValue as AnyObject?
                QWRouter.sharedInstance().router(withUrlString: NSString.getRouterVCUrlString(fromUrlString: "gamedetail", andParams: params))
            }
        }
        else {
            if let vo = self.logic.listVO?.results[index] as? BookVO {
                var params = [String: AnyObject]()
                params["book_url"] = vo.url as AnyObject?
                params["id"] = vo.nid?.stringValue as AnyObject?
                QWRouter.sharedInstance().router(withUrlString: NSString.getRouterVCUrlString(fromUrlString: "book", andParams: params))
            }
        }
    }
    
}
