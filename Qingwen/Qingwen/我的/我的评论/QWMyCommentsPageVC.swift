//
//  QWMyCommentsPageVC.swift
//  Qingwen
//
//  Created by qingwen on 2018/4/27.
//  Copyright © 2018年 iQing. All rights reserved.
//

import UIKit


class QWMyCommentsPageVC: QWBasePageVC {
//    var commentsVO: CommentsVO?
    var uid :String?
    var inId :String?
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    lazy var leftVC:QWMyCommentsVC = {
        let vc = QWMyCommentsVC.createFromStoryboard(withStoryboardID: "pushComments", storyboardName: "MyComments")!
        vc.uid = self.uid
        self.addChildViewController(vc)
        return vc
    }()
    
    lazy var midVC:QWReceivedVC = {
        let vc = QWReceivedVC.createFromStoryboard(withStoryboardID: "receivedComments", storyboardName: "MyComments")!
        vc.uid = self.uid
        self.addChildViewController(vc)
//        vc.setPageShow(false)
        return vc
    }()
//    override var pages: [UIViewController]? {
//        return [self.leftVC,self.midVC]
//    }
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        // Do any additional setup after loading the view.
//        let view = QWBarItemView(titles: ["我的评论","收到的回复"], titleWidth:100, actionBlock: { [weak self](btn) in
//            if let weakSelf = self, let btn = btn {
//                weakSelf.onPressedTitleBtn(btn)
//            }
//        })
//        self.titleBtns = view.titleBtns as! [UIButton]!
//
//        self.titleBtns = self.titleBtns.sorted { $0.tag < $1.tag }
//        self.currentBtn = self.titleBtns.first
//        super.viewDidLoad()
//        self.navigationItem.titleView = view
//        self.rightVC.setPageShow(false)
//    }
    override var pages: [UIViewController]? {
        return [self.leftVC,self.midVC]
    }
    
    override func viewDidLoad() {
//         let userId :String = QWGlobalValue.sharedInstance().nid!.stringValue
        var titleArr = [String]()
        if inId == "1"  {
            titleArr = ["TA的评论","收到的回复"]
        }
        else{
             titleArr = ["我的评论","收到的回复"]
        }
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
        if let vc = self.pages![self.segmentPaper!.pager.indexForSelectedPage] as? QWMyCommentsVC {
            vc.update()
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
