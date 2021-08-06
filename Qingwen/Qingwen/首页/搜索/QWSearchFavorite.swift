//
//  QWSearchFavorite.swift
//  Qingwen
//
//  Created by wei lu on 8/02/18.
//  Copyright © 2018 iQing. All rights reserved.
//

import UIKit

class QWSearchFavoriteVC: QWBaseListVC {
    var dataSource = [["信仰"],["作品数"],["战力"], ["更新"], ["收藏"],["讨论"]]
    var keyWords: String?
    var change = false
    var choiceView: QWChoiceMainView?
    
    lazy var logic: QWSearchLogic = {
        return QWSearchLogic(operationManager: self.operationManager)
    }()
    
    override var listVO: PageVO? {
        return self.logic.searchFavorite
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.useSection = true
        self.type = 1
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.logic.order = 2;
        self.choiceView = QWChoiceMainView.createWithNib()
        self.view.addSubview(self.choiceView!)
        self.choiceView?.updateButtons(withTitles: dataSource)
        self.choiceView?.delegate = self
        
        self.tableView.tableFooterView = UIView()
        self.tableView.backgroundColor = UIColor(hex:0xf1f1f1)
        self.tableView.rowHeight = 110
        self.tableView.contentInset = UIEdgeInsetsMake(40, 0, 0, 0)
        self.tableView.emptyView.errorImage = UIImage(named: "empty_6_none")
        self.tableView.emptyView.errorMsg = "没有搜索到该书单"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.getData()
    }
    
    override func getData() {
        if self.logic.isLoading {
            return
        }
        if self.change == false {
            return
        }
        
        self.logic.isLoading = true
        self.tableView.emptyView.showError = false
        self.logic.searchFavorite = nil
        self.logic.searchFavorite(withKeywords: keyWords, andComplete: { (_, _) in
            self.tableView.emptyView.showError = true
            self.logic.isLoading = false
            self.tableView.reloadData()
            self.change = false
        })
    }
    
    override func getMoreData() {
        if self.logic.isLoading {
            return
        }
        self.logic.isLoading = true
        self.tableView.emptyView.showError = false
        self.logic.searchFavorite(withKeywords: keyWords, andComplete: { (_, _) in
            self.tableView.emptyView.showError = true
            self.logic.isLoading = false
            self.tableView.reloadData()
        })
    }
    
    override func update() {
        self.change = true
        self.getData()
    }
    
    func didClickChoiceBtn(_ button:(UIButton, NSNumber?)) {
//        if button.0.tag == 0 {
//            self.logic.order = nil
//        }
//        else {
//            self.logic.order = button.0.tag - 1 as NSNumber
//        }
        switch button.0.tag {
        case 0:
            self.logic.order = 2
        case 1:
            self.logic.order = 0
        case 2:
            self.logic.order = 1
        case 3:
            self.logic.order = nil
        case 4:
            self.logic.order = 3
        case 5:
            self.logic.order = 4
            
        default:
            break
        }
        self.update()
    }
}

extension QWSearchFavoriteVC {
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return PX1_LINE
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return PX1_LINE
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 130
    }
    
    override func updateWithTVCell(_ cell: QWBaseTVCell, indexPath: IndexPath) {
        
        if let vo = listVO?.results[indexPath.section] as? FavoriteBooksVO{
            let cell = cell as! QWFavoriteCell
            cell.updateCell(withFavorite: vo)
        }
    }
    
    
    override func didSelectedCellAtIndexPath(_ indexPath: IndexPath) {
        if let data = listVO?.results[indexPath.section] as? FavoriteBooksVO{
            var params = [String: Any]()
            params["title"] = data.title
            params["intro"] = data.intro
            params["id"] = data.nid
            if let user = data.user{
                params["username"] = user.username
                params["avatar"] = user.avatar
                params["profile_url"] = user.profile_url
            }
            
            QWRouter.sharedInstance().router(withUrlString: NSString.getRouterVCUrlString(fromUrlString: "favorite", andParams: params))
        }
    }
}
extension QWSearchFavoriteVC: QWChoiceMainViewDelegate {
    func choiceMainView(_ choiceMainView: QWChoiceMainView, didClickChoiceBtn button: (UIButton,NSNumber?)) {
        self.didClickChoiceBtn(button)
    }
}
