//
//  QWBillPageVC.swift
//  Qingwen
//
//  Created by Aimy on 11/16/15.
//  Copyright © 2015 iQing. All rights reserved.
//

import UIKit

class QWBillPageVC: QWBasePageVC {

    lazy var leftVC: QWBillVC = {
        let vc = QWBillVC.createFromStoryboard(withStoryboardID: "bill", storyboardName: "QWCoin")!
        self.addChildViewController(vc)
        return vc
    }()

    lazy var rightVC: QWHeavyBillVC = {
        let vc = QWHeavyBillVC.createFromStoryboard(withStoryboardID: "heavybill", storyboardName: "QWWallet")!
//        vc.billType = .Outlay
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

    @IBAction func onPressedChargeBtn(sender: AnyObject) {
        
        let charge  = QWCharge()
        charge.doCharge()
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
