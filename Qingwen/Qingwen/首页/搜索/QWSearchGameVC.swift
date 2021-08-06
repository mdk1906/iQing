//
//  QWSearchGameVC.swift
//  Qingwen
//
//  Created by mumu on 2017/7/26.
//  Copyright © 2017年 iQing. All rights reserved.
//

import UIKit

class QWSearchGameVC: QWBaseListVC {
    var dataSource = [["收藏"],["更新"],["战力"], ["相关度"], ["信仰"],["评论"]]
    var keyWords: String?
    dynamic var selecedBook =  false
    var choiceView: QWChoiceMainView?
    var change = false
    
    //信仰 = 2 更新 = 0 战力 = 1 相关度 = nil 收藏 =3 评论 =4
    lazy var logic: QWSearchLogic = {
        return QWSearchLogic(operationManager: self.operationManager)
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.type = 1
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.logic.order = 3;
        self.choiceView = QWChoiceMainView.createWithNib()
        self.view.addSubview(self.choiceView!)
        self.choiceView?.updateButtons(withTitles: dataSource)
        self.choiceView?.delegate = self
        
        self.tableView.contentInset = UIEdgeInsetsMake(40, 0, 0, 0)
        self.tableView.emptyView.errorImage = UIImage(named: "empty_6_none")
        self.tableView.emptyView.errorMsg = "没有找到这本演绘~"
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
        self.logic.searchGameVO = nil
        self.logic.searchGame(withKeywords: keyWords, andComplete: {(_, _) in
            self.tableView.emptyView.showError = true
            self.change = false
            self.logic.isLoading = false
            self.tableView.reloadData()
        })
        self.logic.getAchievementInfo{ [weak self](aResponseObject, anError) in
            
        }
    }
    
    override func getMoreData() {
        if self.logic.isLoading {
            return
        }
        self.logic.isLoading = true
        self.tableView.emptyView.showError = false
        self.logic.searchGame(withKeywords: keyWords, andComplete: {(_, _) in
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
            self.logic.order = 3
        case 1:
            self.logic.order = 0
        case 2:
            self.logic.order = 1
        case 3:
            self.logic.order = nil
        case 4:
            self.logic.order = 2
        case 5:
            self.logic.order = 4
        
        default:
            break
        }
        self.update()
    }
}

extension QWSearchGameVC {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let vo = self.logic.searchGameVO, let results = vo.results , results.count > 0{
            return results.count
        }else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return PX1_LINE
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return PX1_LINE
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let results = self.logic.searchGameVO?.results, let count = self.logic.searchGameVO?.count,  results.count == indexPath.row + 1 && results.count < count.intValue{
            getMoreData()
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! QWListTVCell
        
        if let game = self.logic.searchGameVO?.results?[indexPath.row] as? BookVO {
            cell.updateWithGameVO(book: game)
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let book = self.logic.searchGameVO?.results?[(indexPath as NSIndexPath).row] as? BookVO {
            if let extraData = extraData, let _ = extraData.objectForCaseInsensitiveKey("searchbookname") {
                
                if let p_block = extraData.objectForCaseInsensitiveKey(QWRouterCallbackKey) {
                    let block = unsafeBitCast(p_block, to: QWNativeFuncVOBlockType.self)
                    _ = block(["book_name": book.title! as AnyObject])
                    self.selecedBook = true
                }
            } else {
                var params = [String: String]()
                params["id"] = book.nid?.stringValue
                params["book_url"] = book.url
                QWRouter.sharedInstance().router(withUrlString: NSString.getRouterVCUrlString(fromUrlString: "gamedetail", andParams: params))
            }
        }
    }
}

extension QWSearchGameVC: QWChoiceMainViewDelegate {
    func choiceMainView(_ choiceMainView: QWChoiceMainView, didClickChoiceBtn button: (UIButton,NSNumber?)) {
        self.didClickChoiceBtn(button)
    }
}
