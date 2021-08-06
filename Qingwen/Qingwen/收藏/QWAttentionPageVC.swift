//
//  QWAttentionPageVC.swift
//  Qingwen
//
//  Created by Aimy on 5/15/16.
//  Copyright © 2016 iQing. All rights reserved.
//

import UIKit

class QWAttentionPageVC: QWBasePageVC {

    lazy var leftVC: QWBookAttentionVC = {
        let vc = QWBookAttentionVC.createFromStoryboard(withStoryboardID: "book", storyboardName: "QWBookAttention")!
        self.addChildViewController(vc)
        return vc
    }()

    lazy var rightVC: QWGameAttentionVC = {
        let vc = QWGameAttentionVC.createFromStoryboard(withStoryboardID: "game", storyboardName: "QWBookAttention")!
        self.addChildViewController(vc)
        vc.setPageShow(false)
        return vc
    } ()

    override var pages: [UIViewController]? {
        return [self.leftVC, self.rightVC]
    }

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func update() {
        if self.segmentPaper?.pager.indexForSelectedPage == 0 {
            self.leftVC.update()
        }
        else {
            self.rightVC.update()
        }
    }

}
