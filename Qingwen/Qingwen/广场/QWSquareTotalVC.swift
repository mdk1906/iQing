//
//  QWSquareTotalVC.swift
//  Qingwen
//
//  Created by qingwen on 2018/3/27.
//  Copyright © 2018年 iQing. All rights reserved.
//

import UIKit
extension QWSquareTotalVC {
    override class func registMapping() {
        let vo = QWMappingVO()
        vo.className = NSStringFromClass(self)
        vo.storyboardName = "QWSquare"
        QWRouter.sharedInstance().register(vo, withKey: "QWSquareTotal")
    }
}
class QWSquareTotalVC: QWBasePageVC {
    
    lazy var leftVC: QWSquareVC = {
        let vc = QWSquareVC.createFromStoryboard(withStoryboardID: "square", storyboardName: "QWSquare")!
        self.addChildViewController(vc)
        return vc
    }()
    
    lazy var midVC: QWActivityVC = {
        let vc = QWActivityVC.createFromStoryboard(withStoryboardID: "activity", storyboardName: "QWActivity")!
        var params = [String: AnyObject]()
        params["title"] = "专题" as AnyObject
        params["topic"] = 1 as AnyObject
        vc.extraData = params
        self.addChildViewController(vc)
        return vc
    }()
    
    lazy var rightVC: QWActivityVC = {
        let vc = QWActivityVC.createFromStoryboard(withStoryboardID: "activity", storyboardName: "QWActivity")!
        var params = [String: AnyObject]()
        params["title"] = "活动" as AnyObject
        vc.extraData = params
        self.addChildViewController(vc)
        return vc
    } ()
    
    override var pages: [UIViewController]? {
        return [self.leftVC, self.midVC, self.rightVC]
    }
    
    override func viewDidLoad() {
        let view = QWBarItemView(titles: ["广场", "专题", "活动"], actionBlock: { [weak self](btn) in
            if let weakSelf = self, let btn = btn {
                weakSelf.onPressedTitleBtn(btn)
            }
        })
        self.titleBtns = view.titleBtns as! [UIButton]!
        
        super.viewDidLoad()
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: view)
        self.rightVC.setPageShow(false)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func searchBtnClick(_ sender: Any) {
        let sb = UIStoryboard(name: "QWSearch", bundle: nil)
        if let vc = sb.instantiateInitialViewController() {
            self.navigationController?.pushViewController(vc, animated: true)
        }
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
