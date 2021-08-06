//
//  QWBoutiqueVC.swift
//  Qingwen
//
//  Created by mumu on 17/1/13.
//  Copyright © 2017年 iQing. All rights reserved.
//

import UIKit

extension QWBoutiqueVC {
    override static func registMapping() {
        let vo = QWMappingVO()
        vo.className = NSStringFromClass(self)
        vo.storyboardName = "QWBest"
        vo.storyboardID = "boutique"
        QWRouter.sharedInstance().register(vo, withKey: "boutique")
    }
}

class QWBoutiqueVC: QWUpdateVC {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func getData() {
        if self.logic.isLoading {
            return
        }
        
        self.tableView.emptyView.showError = false
        self.logic.isLoading = true
        self.logic.listVO = nil
        self.showLoading()
        self.logic.getBoutiqueWithUrl(url) { [weak self](_, _) in
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
        self.showLoading()
        self.logic.getBoutiqueWithUrl(url) { [weak self](_, _) in
            if let weakSelf = self {
                weakSelf.hideLoading()
                weakSelf.logic.isLoading = false
                weakSelf.tableView.emptyView.showError = true
                weakSelf.tableView.reloadData()
            }
        }
    }
    
    override func onPressedCategoryBtn(_ sender: UIButton) {
        pop.dismiss()
        let point = CGPoint(x:0, y:sender.frame.origin.y + sender.frame.size.height)
        let titles = ["  白金","  黄金", "  白银"]
        pop = QWPopoverView(point: point, titles: titles, currentSelected: sender.titleLabel?.text, images: nil)
        pop.selectRowAtIndex = {[weak self](index) in
            if let weakSelf = self {
                if (sender.titleLabel!.text! as NSString).isEqual(to: titles[index]) {
                    return
                }
                weakSelf.categoryBtn.setTitle(titles[index], for: .normal)
                switch index {
                case 0:
                    weakSelf.logic.rank = 6
                case 1:
                    weakSelf.logic.rank = 4
                case 2:
                    weakSelf.logic.rank = 3
                default:
                    break
                }
                weakSelf.getData()
            }
        }
        self.pop.show()
    }
    
    override func onPressedZoneTypeBtn(_ sender: UIButton) {
        pop.dismiss()
        let point = CGPoint(x:0, y:sender.frame.origin.y + sender.frame.size.height)
        let titles = ["  全站", "  原创","  文库本",  "  女性向"]
        pop = QWPopoverView(point: point, titles: titles, currentSelected: sender.titleLabel?.text, images: nil)
        pop.selectRowAtIndex = {[weak self](index) in
            if let weakSelf = self {
                if (sender.titleLabel!.text! as NSString).isEqual(to: titles[index]) {
                    return
                }
                weakSelf.game = false
                
                weakSelf.zoneTypeBtn.setTitle(titles[index], for: .normal)
                
                switch index {
                case 0:
                    weakSelf.logic.channelType = .typeNone
                case 1:
                    weakSelf.logic.channelType = .type10
                case 2:
//                    weakSelf.logic.channelType = .type12
                    weakSelf.logic.channelType = .type14
                case 3:
                    //                    weakSelf.logic.channelType = .type12
                    weakSelf.logic.channelType = .type11
                default:
                    break
                }
                weakSelf.url = "\(QWOperationParam.currentDomain())/book/all_works/"
                weakSelf.getData()
            }
        }
        self.pop.show()
    }
    
    override func onPressedUpdateBtn(_ sender: UIButton) {
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
}
