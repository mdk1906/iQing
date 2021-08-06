//
//  QWHistoryPageVC.swift
//  Qingwen
//
//  Created by Aimy on 5/15/16.
//  Copyright © 2016 iQing. All rights reserved.
//

import UIKit

class QWHistoryPageVC: QWBasePageVC {
    
    lazy var leftVC: QWBookHistoryVC = {
        let vc = QWBookHistoryVC.createFromStoryboard(withStoryboardID: "book", storyboardName: "QWHistory")!
        self.addChildViewController(vc)
        return vc
    }()
    
    lazy var rightVC: QWGameHistoryVC = {
        let vc = QWGameHistoryVC.createFromStoryboard(withStoryboardID: "game", storyboardName: "QWHistory")!
        self.addChildViewController(vc)
        vc.setPageShow(false)
        return vc
    } ()
    
    override var pages: [UIViewController]? {
        return [self.leftVC, self.rightVC]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let view = QWBarItemView(titles: ["小说","演绘"], actionBlock: { [weak self](btn) in
            if let weakSelf = self, let btn = btn {
                weakSelf.onPressedTitleBtn(btn)
            }
        })
//        view.frame = CGRect(x:(QWSize.screenWidth()-220)/2,y:20,width:220,height:44)
        self.titleBtns = view.titleBtns as! [UIButton]?
        self.titleBtns = self.titleBtns.sorted { $0.tag < $1.tag }
        self.currentBtn = self.titleBtns.first
        self.navigationItem.titleView = view
        self.rightVC.setPageShow(false)
        
    }
    
    override func update() {
        if let vc = self.pages![self.segmentPaper!.pager.indexForSelectedPage] as? QWBookHistoryVC {
            vc.update()
        }
    }
    
}
