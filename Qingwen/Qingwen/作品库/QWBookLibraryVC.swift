//
//  QWBookLibraryVC.swift
//  Qingwen
//
//  Created by mumu on 2017/7/27.
//  Copyright © 2017年 iQing. All rights reserved.
//

import UIKit

extension QWBookLibraryVC {
    override static func registMapping() {
        let vo = QWMappingVO()
        vo.className = NSStringFromClass(self)
        vo.storyboardName = "QWLibrary"
        vo.storyboardID = "booklibrary"
        QWRouter.sharedInstance().register(vo, withKey: "booklibrary")
    }
}

class QWBookLibraryVC: QWSearchBookVC {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.dataSource = [
            ["全站",["全站", "原创","文库本","女性向"]],
            ["排序",["更新", "战力", "信仰", "收藏", "评论"]],
            ["等级",["全部","白金", "黄金", "白银"]],
            ["分类",["","同人","仙侠"]],
            ["状态",["全部","连载","完结"]]
        ]
    }
    
    override func viewDidLoad() {
        self.title = "小说库"
        super.viewDidLoad()
        //修改
        if let extraData = self.extraData {
            if let title = extraData.objectForCaseInsensitiveKey("title") as? String {
                self.title = title
            }
            
            /// 规则: choice[0] 为1级标签第几个 choice[1] 为2级标签
            if let choices = extraData.objectForCaseInsensitiveKey("tags") as? [Array<Any>] {
                self.choiceView?.currentSelectSecondChoices = choices
            }
            if let boutique = extraData.objectForCaseInsensitiveKey("boutique") as? NSNumber, boutique.intValue == 1{
                self.dataSource[2][0] = "白金"
                self.dataSource[0][0] = "原创"
                self.dataSource[1][0] = "信仰"
            }
            
            if let riqing = extraData.objectForCaseInsensitiveKey("riqing") as? NSNumber,riqing.intValue == 1{
                self.dataSource[0][0] = "文库本"
            }
            
            
            
            if let channel = extraData.objectForCaseInsensitiveKey("channel")as? NSNumber  {
                self.logic.locate = channel
            }
            if let rank = extraData.objectForCaseInsensitiveKey("rank") as? NSNumber {
                self.logic.rank = rank
            }
            if let order = extraData.objectForCaseInsensitiveKey("order")as? NSNumber  {
                self.logic.order = order
            }
            if let categories = extraData.objectForCaseInsensitiveKey("categories")as? NSNumber  {
                self.logic.category_id = categories
            }
            if let endState = extraData.objectForCaseInsensitiveKey("end")as? NSNumber  {
                self.logic.end = endState
            }
            
            self.update()
        }
        
        
        if #available(iOS 11.0, *){
            self.choiceView?.topLayout?.constant = 0
            let offset = self.choiceView!.height + self.view.safeAreaInsets.top
            self.tableView.contentInset = UIEdgeInsetsMake(offset, 0, 0, 0)
        }else{
            self.tableView.contentInset = UIEdgeInsetsMake(104, 0, 0, 0)
            self.choiceView?.topLayout?.constant = 64
        }
    }
    
   override func getCategory() {
        self.logic.getCategoryWithComplete {[weak self](_,_) in
            if let weakSelf = self {
                if let titles = weakSelf.logic.categoryStrings {
                    weakSelf.dataSource[3][1] = titles
                    weakSelf.choiceView?.updateButtons(withTitles: weakSelf.dataSource)
                    weakSelf.choiceView?.changeTitles()
                }
            }
        }
    self.logic.getAchievementInfo{ [weak self](aResponseObject, anError) in
        
    }
    }
    
    override func didClickedChoiceBtn(_ button: (UIButton, NSNumber?)) {
        guard let select = button.1 else {
            return
        }
        switch button.0.tag {
        case 0: //范围分区
            switch select.intValue {
            case 0:
                self.logic.locate = nil
            case 1:
                self.logic.locate = 10
            case 2:
//                self.logic.locate = 12
//                self.logic.locate = 13
                self.logic.locate = 14
            case 3:
                self.logic.locate = 11
            default:
                break
            }
        case 1: //排序
            self.logic.order = NSNumber(value: select.intValue)
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
    @IBAction func SearchBtnClick(_ sender: Any) {
        let sb = UIStoryboard(name: "QWSearch", bundle: nil)
        if let vc = sb.instantiateInitialViewController() {
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    
}


