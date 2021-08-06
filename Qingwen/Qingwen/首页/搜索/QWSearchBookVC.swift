//
//  QWSearchBookVC.swift
//  Qingwen
//
//  Created by mumu on 2017/7/25.
//  Copyright © 2017年 iQing. All rights reserved.
//

import UIKit

class QWSearchBookVC: QWBaseListVC {
    
    var keyWords: String?
    dynamic var selecedBook =  false
    var choiceView: QWChoiceMainView?
    var change = false

    lazy var logic: QWSearchLogic = {
        return QWSearchLogic(operationManager: self.operationManager)
    }()
    
    var dataSource = [
        ["范围",["全站", "原创","  文库本", "女性向"]],
        ["排序",["信仰", "更新", "战力", "相关度", "收藏", "评论"]],
        ["等级",["全部", "白金","黄金", "白银"]],
        ["分类",["同人","仙侠"]],
        ["状态",["全部","连载","完结"]]
    ]
    //信仰 = 2 更新 = 0 战力 = 1 相关度 = nil 收藏 =3 评论 =4
    override func awakeFromNib() {
        super.awakeFromNib()
        self.type = 1
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.logic.order = 2;
        self.choiceView = QWChoiceMainView.createWithNib()
        self.view.addSubview(self.choiceView!)
        self.choiceView?.updateButtons(withTitles: dataSource)
        self.choiceView?.delegate = self
        
        self.tableView.emptyView.errorImage = UIImage(named: "empty_6_none")
        self.tableView.contentInset = UIEdgeInsetsMake(40, 0, 0, 0)
        self.tableView.emptyView.errorMsg = "没有找到这本书~"
        
        self.getCategory()
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
        self.logic.searchBookVO = nil
        self.logic.searchBook(withKeywords: keyWords, andComplete: { (_, _) in
            self.tableView.emptyView.showError = true
            self.logic.isLoading = false
            self.tableView.reloadData()
            self.change = false
        })
    }
    
    func getCategory() {
        self.logic.getCategoryWithComplete {[weak self](_,_) in
            if let weakSelf = self {
                if let titles = weakSelf.logic.categoryStrings {
                    weakSelf.dataSource[3][1] = titles
                        weakSelf.choiceView?.updateButtons(withTitles: weakSelf.dataSource)
                }
            }
        }
    }
    
    override func getMoreData() {
        if self.logic.isLoading {
            return
        }
        self.logic.isLoading = true
        self.tableView.emptyView.showError = false
        self.logic.searchBook(withKeywords: keyWords, andComplete: { (_, _) in
            self.tableView.emptyView.showError = true
            self.logic.isLoading = false
            self.tableView.reloadData()
        })
    }
    
    override func update() {
        self.change = true
        self.getData()
    }
    
    func didClickedChoiceBtn(_ button:(UIButton,NSNumber?)) {
        guard let select = button.1 else {
            return
        }
        switch button.0.tag {
        case 0: //范围分区
            switch select.intValue {
            case 0:
                self.logic.locate = nil
            case 1:
                self.logic.locate = 12
            case 2:
                self.logic.locate = 14
            case 3:
                self.logic.locate = 11
            default:
                break
            }
        case 1: //排序
//            if select.intValue == 0 {
//                self.logic.order = nil
//            }
//            else {
//                self.logic.order = NSNumber(value: select.intValue - 1)
//            }
            switch select.intValue {
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
        case 2: //黄金白银
            switch select.intValue {
            case 0:
                self.logic.rank = nil
            case 1:
                self.logic.rank = 6
            case 2:
                self.logic.rank = 4
            case 3:
                self.logic.rank = 3
            default:
                break
            }
        case 3: //分类
            if select == 0 {
                self.logic.categories = nil
            }
            else {
                self.logic.categories = NSNumber(value: select.intValue - 1)
            }
        case 4: //状态
            switch select.intValue {
            case 0:
                self.logic.end = nil
            case 1:
                self.logic.end = 0
            case 2:
                self.logic.end = 1
            default:
                break
            }
        default:
            break
        }
        self.update()
    }
}

extension QWSearchBookVC {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let vo = self.logic.searchBookVO, let results = vo.results , results.count > 0{
            return results.count
        } else {
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
        
        if let results = self.logic.searchBookVO?.results , let count = self.logic.searchBookVO?.count,results.count == indexPath.row + 1 && results.count < count.intValue {
            getMoreData()
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! QWListTVCell
        
        if let book = self.logic.searchBookVO?.results?[(indexPath as NSIndexPath).row] as? BookVO {
            cell.updateWithBookVO(book)
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let book = self.logic.searchBookVO?.results?[(indexPath as NSIndexPath).row] as? BookVO {
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
                QWRouter.sharedInstance().router(withUrlString: NSString.getRouterVCUrlString(fromUrlString: "book", andParams: params))
            }
        }
    }
}

extension QWSearchBookVC: QWChoiceMainViewDelegate {
    func choiceMainView(_ choiceMainView: QWChoiceMainView, didClickChoiceBtn button: (UIButton, NSNumber?)) {
        self.didClickedChoiceBtn(button)
    }
}


