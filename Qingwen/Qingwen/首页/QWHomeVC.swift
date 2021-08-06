//
//  QWHomeVC.swift
//  Qingwen
//
//  Created by Aimy on 10/12/15.
//  Copyright © 2015 iQing. All rights reserved.
//

import UIKit

extension QWHomeVC {
    override class func registMapping() {
        let vo = QWMappingVO()
        vo.className = NSStringFromClass(self)
        vo.storyboardName = "QWHome"
        QWRouter.sharedInstance().register(vo, withKey: "main")
    }
}

class QWHomeVC: QWBasePageVC {

    lazy var leftVC: QWBestCVC = {
        let vc = QWBestCVC.createFromStoryboard(withStoryboardID: nil, storyboardName: "QWBest")!
        self.addChildViewController(vc)
        return vc
    }()
    
    lazy var midVC: QWRankingVC = {
        let vc = QWRankingVC.createFromStoryboard(withStoryboardID: "ranking", storyboardName: "QWBest")!
        self.addChildViewController(vc)
        return vc
    }()
    
    lazy var rightVC: QWUpVC = {
        let vc = QWUpVC.createFromStoryboard(withStoryboardID: "up", storyboardName: "QWBest")!
        self.addChildViewController(vc)
        return vc
    } ()
    
    override var pages: [UIViewController]? {
        return [self.leftVC, self.midVC, self.rightVC]
    }

    override func viewDidLoad() {
        let view = QWBarItemView(titles: ["推荐", "榜单", "上升"], actionBlock: { [weak self](btn) in
            if let weakSelf = self, let btn = btn {
                weakSelf.onPressedTitleBtn(btn)
            }
        })
        self.titleBtns = view.titleBtns as! [UIButton]!
        
        super.viewDidLoad()
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: view)
        self.rightVC.setPageShow(false)
    }

    override func update() {
        if let vc = self.pages![self.segmentPaper!.pager.indexForSelectedPage] as? QWBestCVC {
            vc.update()
        }
    }

    override func repeateClickTabBarItem(_ count: Int) {

        if self.segmentPaper?.pager.indexForSelectedPage == 0 {
            self.leftVC.repeateClickTabBarItem(count)
        }
        else if self.segmentPaper?.pager.indexForSelectedPage == 1 {
            self.rightVC.repeateClickTabBarItem(count)
        }
    }

    @IBAction func onPressedSearchBtn(_ sender: AnyObject) {
        let sb = UIStoryboard(name: "QWSearch", bundle: nil)
        if let vc = sb.instantiateInitialViewController() {
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
