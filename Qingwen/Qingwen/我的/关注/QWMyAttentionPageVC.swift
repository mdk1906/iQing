//
//  QWAttentionPageVC.swift
//  Qingwen
//
//  Created by qingwen on 2018/9/18.
//  Copyright © 2018年 iQing. All rights reserved.
//

import UIKit

class QWMyAttentionPageVC: QWBasePageVC {

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    lazy var leftVC:QWMyAttentionPeopleVC = {
        let vc = QWMyAttentionPeopleVC.createFromStoryboard(withStoryboardID: "myattention", storyboardName: "QWAttention")!
        self.addChildViewController(vc)
        return vc
    }()
    
    lazy var midVC:QWFollowMePeopleVC = {
        let vc = QWFollowMePeopleVC.createFromStoryboard(withStoryboardID: "fans", storyboardName: "QWAttention")!
        self.addChildViewController(vc)
        //        vc.setPageShow(false)
        return vc
    }()
    override var pages: [UIViewController]? {
        return [self.leftVC,self.midVC]
    }
    
    override func viewDidLoad() {
        var titleArr = [String]()
        
            titleArr = ["我关注的","关注我的"]
        
        let view = QWBarItemView(titles: titleArr, titleWidth:100, actionBlock: { [weak self](btn) in
            if let weakSelf = self, let btn = btn {
                weakSelf.onPressedTitleBtn(btn)
            }
        })
        self.titleBtns = view.titleBtns as! [UIButton]!
        
        super.viewDidLoad()
        self.navigationItem.titleView = view
    }
    
    override func update() {
//        if let vc = self.pages![self.segmentPaper!.pager.indexForSelectedPage] as? QWMyAttentionPeopleVC {
//            vc.update()
//        }
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
}
