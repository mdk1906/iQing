//
//  QWGameLibraryVC.swift
//  Qingwen
//
//  Created by mumu on 2017/7/27.
//  Copyright © 2017年 iQing. All rights reserved.
//

import UIKit

extension QWGameLibraryVC {
    override static func registMapping() {
        let vo = QWMappingVO()
        vo.className = NSStringFromClass(self)
        vo.storyboardName = "QWLibrary"
        vo.storyboardID = "gamelibrary"
        QWRouter.sharedInstance().register(vo, withKey: "gamelibrary")
    }
}

class QWGameLibraryVC: QWSearchGameVC {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.dataSource = [["更新"],["战力"], ["信仰"], ["收藏"],["评论"]]
    }
    
    override func viewDidLoad() {
        if let extraData = self.extraData {
            if let title = extraData.objectForCaseInsensitiveKey("title") as? String {
                self.title = title
            }
            /// 规则: choice[0] 为1级标签第几个 choice[1] 为2级标签
            if let choices = extraData.objectForCaseInsensitiveKey("tags") as? [Array<Any>] {
                for (_, choice) in choices.enumerated() {
                    let first = choice[0] as! Int
                    let tags = choice[1] as! String
                    self.dataSource[first][0] = tags
                }
                if let order = extraData.objectForCaseInsensitiveKey("order")as? NSNumber  {
                    self.logic.order = order
                }
            }
        }
        self.change = true
        super.viewDidLoad()
        if #available(iOS 11.0, *){
            self.choiceView?.topLayout?.constant = 0
            let offset = self.choiceView!.height + self.view.safeAreaInsets.top
            self.tableView.contentInset = UIEdgeInsetsMake(offset, 0, 0, 0)
        }else{
            self.tableView.contentInset = UIEdgeInsetsMake(104, 0, 0, 0)
            self.choiceView?.topLayout?.constant = 64
        }
        
        self.choiceView?.delegate = self
        self.choiceView?.currentBtn.isSelected = false
        self.choiceView?.currentBtn = self.choiceView?.mainButtons[1]
        self.choiceView?.currentBtn.isSelected = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func didClickChoiceBtn(_ button:(UIButton, NSNumber?)) {
        self.logic.order = button.0.tag as NSNumber
        self.update()
    }
    @IBAction func SearchBtnClick(_ sender: Any) {
        let sb = UIStoryboard(name: "QWSearch", bundle: nil)
        if let vc = sb.instantiateInitialViewController() {
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

