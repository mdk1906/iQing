//
//  QWWalletBillPageVC.swift
//  Qingwen
//
//  Created by Aimy on 2/25/16.
//  Copyright © 2016 iQing. All rights reserved.
//

import UIKit

class QWWalletBillPageVC: QWBasePageVC {

    lazy var leftVC: QWWalletBillVC = {
        let vc = QWWalletBillVC.createFromStoryboard(withStoryboardID: "bill", storyboardName: "QWWallet")!
        self.addChildViewController(vc)
        return vc
    }()

    lazy var rightVC: QWWalletBillVC = {
        let vc = QWWalletBillVC.createFromStoryboard(withStoryboardID: "bill", storyboardName: "QWWallet")!
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
