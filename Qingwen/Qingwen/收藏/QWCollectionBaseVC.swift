//
//  QWCollectionBaseVC.swift
//  Qingwen
//
//  Created by wei lu on 5/12/17.
//  Copyright © 2017 iQing. All rights reserved.
//

import UIKit

extension QWCollectionVC {
    override class func registMapping() {
        let vo = QWMappingVO()
        vo.className = NSStringFromClass(self)
        vo.storyboardName = "QWCollection"
        QWRouter.sharedInstance().register(vo, withKey: "main")
    }
}

class QWCollectionVC: QWBasePageVC {
    
    lazy var leftVC: QWBookAttentionVC = {
        let vc = QWBookAttentionVC.createFromStoryboard(withStoryboardID: "book", storyboardName: "QWBookAttention")!
        
        self.addChildViewController(vc)
        
        return vc
    }()
    
    lazy var midVC: QWFavoriteBooksCVC = {
        let vc = QWFavoriteBooksCVC.createFromStoryboard(withStoryboardID: "favoritebooks", storyboardName: "QWFavoriteBooks")!
        vc.extraData = self.extraData
        self.addChildViewController(vc)
        return vc
    }()
    lazy var rightVC: QWDownloadCVC = {
//        let sb = UIStoryboard(name: "QWDownload", bundle: nil)
//        let vc = sb.instantiateInitialViewController()!
        let vc = QWDownloadCVC.createFromStoryboard(withStoryboardID: "downloadcv", storyboardName: "QWDownload")!
//        vc.extraData = self.extraData
        self.addChildViewController(vc)
        return vc 
    }()
    
    
    override var pages: [UIViewController]? {
        return [self.leftVC,self.midVC,self.rightVC]
    }
    
    override func viewDidLoad() {

        let view = QWBarItemView(titles: ["我喜欢的","其他书单","下载管理"], titleWidth:66, actionBlock: { [weak self](btn) in
            if let weakSelf = self, let btn = btn {
                weakSelf.onPressedTitleBtn(btn)
            }
        })
        self.titleBtns = view.titleBtns as! [UIButton]!
        
        super.viewDidLoad()
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: view)
    }
    
    override func update() {
        if let vc = self.pages![self.segmentPaper!.pager.indexForSelectedPage] as? QWBookAttentionVC {
            vc.update()
        }
    }
    
//    override func repeateClickTabBarItem(_ count: Int) {
//        
//        if self.segmentPaper?.pager.indexForSelectedPage == 0 {
//            self.leftVC.repeateClickTabBarItem(count)
//        }
//        else if self.segmentPaper?.pager.indexForSelectedPage == 1 {
//            self.rightVC.repeateClickTabBarItem(count)
//        }
//    }
    
}
