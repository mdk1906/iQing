//
//  QWActivityPageVC.swift
//  Qingwen
//
//  Created by mumu on 2017/4/24.
//  Copyright © 2017年 iQing. All rights reserved.
//

import UIKit

extension QWActivityPageVC {
    override static func registMapping() {
        let vo = QWMappingVO()
        vo.className = NSStringFromClass(self)
        vo.storyboardID = "activitypage"
        vo.storyboardName = "QWActivity"
        QWRouter.sharedInstance().register(vo, withKey: "actopic")
    }
}

class QWActivityPageVC: QWBasePageVC {
    
    var activityVO: ActivityVO?
    var url:String?
    var topic = false
    var inId :String?
    
    lazy var logic: QWActivityLogic = {
        return QWActivityLogic(operationManager: self.operationManager)
    }()
    
    lazy var leftVC:QWActivityWebVC = {
        let vc = QWActivityWebVC()
        self.addChildViewController(vc)
        return vc
    }()
    
    lazy var midVC:QWActivityWorkVC = {
        let vc = QWActivityWorkVC.createFromStoryboard(withStoryboardID: "activitywork", storyboardName: "QWActivity")!
        self.addChildViewController(vc)
        return vc
    }()
    lazy var rightVC:QWDiscussTVC = {
        let vc = QWDiscussTVC.createFromStoryboard(withStoryboardID: "discuss", storyboardName: "QWDiscuss")!
        self.addChildViewController(vc)
        vc.isChild = true
        return vc
    }()
    var vcs = [UIViewController]()
    var titles = [String]()
    override var pages: [UIViewController]? {
        return vcs
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let extraData = self.extraData{
            if let url = extraData.objectForCaseInsensitiveKey("activity") as? String{
                self.url = url
            }
            if let topic = extraData.objectForCaseInsensitiveKey("topic") as? NSNumber {
                if topic.intValue == 1 {
                    self.topic = true
                }
            }
            if let assembly_id = extraData.objectForCaseInsensitiveKey("assembly_id") as? NSNumber {
                if self.topic {
                    self.url = "\(QWOperationParam.currentDomain())/topikku/\(assembly_id)/"
                }
                else {
                    self.url = "\(QWOperationParam.currentDomain())/activity/\(assembly_id)/"
                    
                }
            }
        }
        if let _ = self.url {
            self.getData()
        }
        NotificationCenter.default.addObserver(self, selector: #selector(webViewShare), name: NSNotification.Name(rawValue:"webViewShare"), object: nil)
    }
    func webViewShare()  {
        if let vo = self.activityVO {
            var params = [String: AnyObject]()
            var title = ""
            if let status = vo.status {
                switch status.intValue {
                case 0:
                    title = "轻文\(String(describing: vo.title!)) - 已结束"
                case 2:
                    title = "轻文\(String(describing: vo.title!)) - 进行中"
                case 1:
                    title = "轻文\(String(describing: vo.title!)) - 准备中"
                default:
                    break
                }
            }else {
                title = "轻文\(String(describing: vo.title!))"
            }
            
            params["title"] = title as AnyObject
            params["image"] = vo.cover! as AnyObject
            params["intro"] = title as AnyObject
            params["url"] = (vo.eve_url! as NSString).replacingOccurrences(of: "#app", with: "") as AnyObject
            params["type"] = "activity" as AnyObject
            params["workId"] = vo.nid as AnyObject
            QWRouter.sharedInstance().router(withUrlString: NSString.getRouterVCUrlString(fromUrlString: "share", andParams: params))
        }
    }
    override func initTitleBtns() {
        if vcs.contains(self.leftVC) == false {
            self.vcs.append(self.leftVC)
        }
        if let vo = self.activityVO {
            var view: QWBarItemView?
            if let eve_url = vo.eve_url {
                var params = [String:String]()
                params["url"] = eve_url
                self.leftVC.extraData = params as [String : AnyObject]
                titles.append("活动")
            }
            if let url = vo.url, let works_display = vo.works_display, works_display.intValue == 1{
                self.midVC.url = "\(url)order/"
                vcs.append(self.midVC)
                titles.append("作品")
            }
            if let bf_url = vo.bf_url,let bf_enable = vo.bf_enable, bf_enable.intValue == 1 {
                self.rightVC.discussUrl = bf_url
                vcs.append(self.rightVC)
                titles.append("讨论")
            }
            view = QWBarItemView(titles: titles, actionBlock: { [weak self](btn) in
                if let weakSelf = self, let btn = btn {
                    weakSelf.onPressedTitleBtn(btn)
                }
            })
            self.titleBtns = view?.titleBtns as! [UIButton]!
            self.titleBtns = self.titleBtns.sorted { $0.tag < $1.tag }
            self.currentBtn = self.titleBtns.first
            
            if self.titles.count == 1 {
                self.navigationItem.title = self.activityVO?.title ?? "活动"
            }
            else {
                self.navigationItem.titleView = view
            }
            self.automaticallyAdjustsScrollViewInsets = false
        }
    }
    
    override func getData() {
        guard let url = self.url else {
            return
        }
        if self.logic.isLoading {
            return
        }
        self.showLoading()
        self.logic.isLoading = true
        self.logic.activityDetail = nil
        self.logic.getActivityDetailWithUrl(url) { [weak self] (_, _) in
            if let weakSelf = self {
                weakSelf.hideLoading()
                weakSelf.activityVO = weakSelf.logic.activityDetail
                weakSelf.initTitleBtns()
                weakSelf.segmentPaper?.reloadData()
                if let eveUrl = weakSelf.activityVO?.eve_url, let url = URL(string: eveUrl){
                    let request = URLRequest(url: url)
                    weakSelf.leftVC.webView.loadRequest(request)
                    weakSelf.leftVC.webView.reload()
                    weakSelf.leftVC.getCookie()
                }
            }
        }
    }
    
    override func rightBtnClicked(_ sender: AnyObject?) {
        if let vo = self.activityVO {
            var params = [String: AnyObject]()
            var title = ""
            if let status = vo.status {
                switch status.intValue {
                case 0:
                    title = "轻文\(String(describing: vo.title!)) - 已结束"
                case 2:
                    title = "轻文\(String(describing: vo.title!)) - 进行中"
                case 1:
                    title = "轻文\(String(describing: vo.title!)) - 准备中"
                default:
                    break
                }
            }else {
                title = "轻文\(String(describing: vo.title!))"
            }
            
            params["title"] = title as AnyObject
            params["image"] = vo.cover! as AnyObject
            params["intro"] = title as AnyObject
            params["url"] = (vo.eve_url! as NSString).replacingOccurrences(of: "#app", with: "") as AnyObject
            params["type"] = "activity" as AnyObject
            params["workId"] = vo.nid as AnyObject
            QWRouter.sharedInstance().router(withUrlString: NSString.getRouterVCUrlString(fromUrlString: "share", andParams: params))
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
//    override func leftBtnClicked(_ sender: AnyObject?) {
////        if inId == "1" {
//            self.navigationController?.popViewController(animated: true)
////        }
//
//    }
    
}
