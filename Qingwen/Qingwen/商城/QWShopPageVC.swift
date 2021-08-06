//
//  QWShopPageVC.swift
//  Qingwen
//
//  Created by mumu on 16/10/26.
//  Copyright © 2016年 iQing. All rights reserved.
//

import UIKit

extension QWShopPageVC {
    
    override class func registMapping() {
        let vo = QWMappingVO()
        vo.className = NSStringFromClass(self)
        vo.storyboardName = "QWShop"
        QWRouter.sharedInstance().register(vo, withKey: "shop")
    }
}

class QWShopPageVC: QWBasePageVC {

    lazy var leftVC: UIViewController = {
        let sb = UIStoryboard(name: "QWShop", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "shoplist")
        self.addChildViewController(vc)
        return vc
    }()
    
    lazy var rightVC: UIViewController = {
        let sb = UIStoryboard(name: "QWShop", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "mygoods")
        self.addChildViewController(vc)
        vc.setPageShow(false)
        return vc
    }()
    
    override var pages: [UIViewController]? {
        return [self.leftVC, self.rightVC]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false
    }
    
    override func didSelectedIndex(index: Int) {
        super.didSelectedIndex(index: index)
        self.update()
    }
    
    override func update() {
        if self.segmentPaper?.pager.indexForSelectedPage == 0 {
            self.leftVC.update()
        }
        else {
            self.rightVC.update()
        }
    }
    @IBAction func onPressedHelp(_ sender: UIBarButtonItem) {
        print("onPressedRightBarBtn")
        var params = [String: String]()
        params["title"] = "购书券"
        params["localurl"] = Bundle.main.path(forResource: "shopticket_help", ofType: "html")
        QWRouter.sharedInstance().router(withUrlString: NSString.getRouterVCUrlString(fromUrlString: "web", andParams: params))
    }
}
