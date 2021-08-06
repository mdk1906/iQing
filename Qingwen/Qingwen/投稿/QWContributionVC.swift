//
//  QWContributionVC.swift
//  Qingwen
//
//  Created by Aimy on 10/26/15.
//  Copyright © 2015 iQing. All rights reserved.
//

import UIKit
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}

extension QWContributionVC {
    override static func registMapping() {
        let vo = QWMappingVO()
        vo.className = NSStringFromClass(self)
        vo.storyboardID = "contribution"
        vo.storyboardName = "QWContribution"
        QWRouter.sharedInstance().register(vo, withKey: "submission")
    }
}

class QWContributionVC: QWBasePageVC {

    var contributionVO: ContributionVO?

    lazy var logic: QWContributionLogic = {
        let logic = QWContributionLogic(operationManager: self.operationManager)
        logic.channel = self.channel as NSNumber?
        return logic
    }()

    @IBOutlet var saveBtn: UIBarButtonItem!
    @IBOutlet var backBtn: UIBarButtonItem!
    @IBOutlet var editBtn: UIBarButtonItem!
    @IBOutlet var cancelBtn: UIBarButtonItem!
    @IBOutlet var completeBtn: UIBarButtonItem!
    @IBOutlet var deleteBtn: UIBarButtonItem!


    var channel = QWChannelType.type10.rawValue

    lazy var leftVC: QWContributionInfoVC = {
        let vc = QWContributionInfoVC.createFromStoryboard(withStoryboardID: "info", storyboardName: "QWContribution")!
        vc.logic = self.logic
        self.addChildViewController(vc)
        vc.willMove(toParentViewController: self)
        let _ = vc.view
        vc.didMove(toParentViewController: self)
        return vc
    }()

    lazy var middleVC: QWContributionContentVolumeTVC = {
        let vc = QWContributionContentVolumeTVC.createFromStoryboard(withStoryboardID: "content", storyboardName: "QWContribution")!
        vc.logic = self.logic
        self.addChildViewController(vc)
        vc.setPageShow(false)
        return vc
    } ()

    lazy var rightVC: QWContributionDraftVC = {
        let vc = QWContributionDraftVC.createFromStoryboard(withStoryboardID: "draft", storyboardName: "QWContribution")!
        vc.logic = self.logic
        self.addChildViewController(vc)
        vc.setPageShow(false)
        return vc
    } ()

    override var pages: [UIViewController]? {
        return [self.leftVC, self.middleVC, self.rightVC]
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.fd_interactivePopDisabled = true
        self.navigationItem.titleView = nil
        self.segmentPaper?.pager.isScrollEnabled = false
        
        if let extraData = self.extraData {
            if let title = extraData.objectForCaseInsensitiveKey("activity_title") as? String, let nid = extraData.objectForCaseInsensitiveKey("activity_id") as? NSNumber {
                let activity = ActivityVO()
                activity.title = title
                activity.nid = nid
                self.leftVC.logic.activitys = [activity]
            }
        }
        
        if let contributionVO = self.contributionVO {
            self.title = "修改作品"
            self.logic.channel = contributionVO.channel
            self.logic.contributionVO = contributionVO
            self.logic.book = contributionVO
            self.logic.categorys = contributionVO.categories as? [CategoryItemVO]
            self.logic.activitys = contributionVO.book.activity as? [ActivityVO]
            self.navigationItem.titleView = self.titleView
            self.navigationItem.leftBarButtonItem = self.backBtn
            if let status = self.logic.contributionVO?.status , status == .draft {
                self.navigationItem.rightBarButtonItems = [self.deleteBtn, self.editBtn];
            } else {
                self.navigationItem.rightBarButtonItem = self.editBtn;
            }
        }
        else {
            self.navigationItem.leftBarButtonItem = self.cancelBtn
            self.navigationItem.rightBarButtonItem = self.saveBtn

            self.leftVC.currentLocateBtn.isSelected = false
            if self.channel == QWChannelType.type10.rawValue {
                self.leftVC.currentLocateBtn = self.leftVC.locate10Btn
            }
            else if self.channel == QWChannelType.type11.rawValue{
                self.leftVC.currentLocateBtn = self.leftVC.locate11Btn
            } else {
                self.leftVC.currentLocateBtn = self.leftVC.locate12Btn
            }
        }
        self.getActivityList()
    }
    
    func getActivityList() {
        self.logic.getActivitList {[weak self](aResponseObject, anError) in
            if let weakSelf = self {
                if let _ = weakSelf.contributionVO {
                    weakSelf.leftVC.update()
                    weakSelf.leftVC.setEditing(false, animated: true)
                }
                else {
                    weakSelf.leftVC.currentLocateBtn.isSelected = true
                    weakSelf.leftVC.setEditing(true, animated: true)
                }
            }
        }
    }
    
    override func didSelectedIndex(index: Int) {
        super.didSelectedIndex(index: index)

        switch index {
        case 0:
            if let status = self.logic.contributionVO?.status , status == .draft {
                self.navigationItem.rightBarButtonItems = [self.deleteBtn, self.editBtn];
            } else {
                self.navigationItem.rightBarButtonItem = self.editBtn;
            }
        case 1:
            self.navigationItem.rightBarButtonItems = [self.editBtn];
        case 2:
            self.navigationItem.rightBarButtonItem = nil
        default:
            self.navigationItem.rightBarButtonItem = self.editBtn
        }
    }

    @IBAction func onPressedEditBtn(_ sender: AnyObject) {
        if let status = self.logic.contributionVO?.status , status == .inReview {
            self.showToast(withTitle: "无法修改审核中的书籍", subtitle: nil, type: .alert)
            return
        }

        self.titleView.isUserInteractionEnabled = false

        if self.segmentPaper?.pager.indexForSelectedPage == 0 {
            self.navigationItem.leftBarButtonItem = self.cancelBtn
            self.navigationItem.rightBarButtonItems = [self.saveBtn]
            self.leftVC.setEditing(true, animated: true)
        }
        else {
            self.navigationItem.leftBarButtonItem = self.completeBtn
            self.navigationItem.rightBarButtonItem = nil
            self.middleVC.setEditing(true, animated: true)
        }
    }

    @IBAction func onPressedCancelBtn(_ sender: AnyObject) {
        self.titleView.isUserInteractionEnabled = true
        if let _ = self.logic.book {
            self.navigationItem.leftBarButtonItem = self.backBtn
            if let status = self.logic.contributionVO?.status, status == .draft {
                self.navigationItem.rightBarButtonItems = [self.deleteBtn, self.editBtn];
            } else {
                self.navigationItem.rightBarButtonItem = self.editBtn;
            }
            self.leftVC.setEditing(false, animated: true)
            self.middleVC.setEditing(false, animated: true)
        }
        else {
            if let _ = self.presentingViewController {
                self.presentingViewController?.dismiss(animated: true, completion: nil)
            }
            else {
                self.navigationController?.popViewController(animated: true)
            }
            
        }
    }

    @IBAction func onPressedBackBtn(_ sender: AnyObject) {
        self.cancelAllOperations()
        if let _ = self.presentingViewController {
            self.presentingViewController?.dismiss(animated: true, completion: nil)
        }
        else {
            self.navigationController?.popViewController(animated: true)
        }
    }

    @IBAction func onPressedCompletedBtn(_ sender: AnyObject) {
        self.leftVC.setEditing(false, animated: true)
        self.middleVC.setEditing(false, animated: true)
        self.titleView.isUserInteractionEnabled = true
        self.navigationItem.leftBarButtonItem = self.backBtn
        self.navigationItem.rightBarButtonItem = self.editBtn
    }

    @IBAction func onPressedSaveBtn(_ sender: AnyObject) {
        endTextEditing()
        if self.segmentPaper?.pager.indexForSelectedPage == 0 {
            if let status = self.logic.contributionVO?.status , status == .approve || status == .partReview {//已经通过
                if (self.leftVC.introTV.text as NSString).length == 0 {
                    self.showToast(withTitle: "请输入简介", subtitle: nil, type: .alert)
                    return
                }

                if (self.leftVC.introTV.text as NSString).length > 300 {
                    self.showToast(withTitle: "简介不能超过300个字符", subtitle: nil, type: .alert)
                    return
                }

                if self.logic.isLoading {
                    return
                }

                self.logic.isLoading = true

                self.saveBtn.isEnabled = false
                self.showLoading()
                self.logic.updateApproveBook(withIntro: self.leftVC.introTV.text, andComplete: { (aResponseObject, anError) -> Void in
                    self.hideLoading()
                    self.saveBtn.isEnabled = true
                    self.logic.isLoading = false

                    if let anError = anError as NSError?{
                        self.showToast(withTitle: anError.userInfo[NSLocalizedDescriptionKey] as? String, subtitle: nil, type: .error)
                        return ;
                    }

                    if let dict = aResponseObject as? [String: AnyObject] {
                        if let code = dict["code"] as? Int , code != 0 {
                            if let message = dict["data"] as? String {
                                self.showToast(withTitle: message, subtitle: nil, type: .error)
                            }
                            else {
                                self.showToast(withTitle: "更新失败", subtitle: nil, type: .error)
                            }
                        }
                        else {
                            self.titleView.isUserInteractionEnabled = true
                            self.navigationItem.leftBarButtonItem = self.backBtn
                            self.navigationItem.rightBarButtonItem = self.editBtn
                            self.leftVC.setEditing(false, animated: true)
                            self.showToast(withTitle: "更新成功", subtitle: nil, type: .error)
                        }
                    }
                })
            }
            else if let _ = self.logic.book {
                if (self.leftVC.introTV.text as NSString).length == 0 {
                    self.showToast(withTitle: "请输入简介", subtitle: nil, type: .alert)
                    return
                }

                if (self.leftVC.introTV.text as NSString).length > 300 {
                    self.showToast(withTitle: "简介不能超过300个字符", subtitle: nil, type: .alert)
                    return
                }

                if self.logic.categorys?.count < 2 {
                    self.showToast(withTitle: "请至少选择2个分类", subtitle: nil, type: .alert)
                    return
                }

                if self.logic.categorys?.count > 5 {
                    self.showToast(withTitle: "分类不能超过5个", subtitle: nil, type: .alert)
                    return
                }

                if self.logic.isLoading {
                    return
                }

                self.logic.isLoading = true

                self.saveBtn.isEnabled = false
                self.showLoading()
                self.logic.updateBook(withIntro: self.leftVC.introTV.text, andComplete: { (aResponseObject, anError) -> Void in
                    self.hideLoading()
                    self.saveBtn.isEnabled = true
                    self.logic.isLoading = false

                    if let anError = anError as NSError? {
                        self.showToast(withTitle: anError.userInfo[NSLocalizedDescriptionKey] as? String, subtitle: nil, type: .error)
                        return ;
                    }

                    if let dict = aResponseObject as? [String: AnyObject] {
                        if let code = dict["code"] as? Int , code != 0 {
                            if let message = dict["data"] as? String {
                                self.showToast(withTitle: message, subtitle: nil, type: .error)
                            }
                            else {
                                self.showToast(withTitle: "更新失败", subtitle: nil, type: .error)
                            }
                        }
                        else {
                            self.titleView.isUserInteractionEnabled = true
                            self.navigationItem.leftBarButtonItem = self.backBtn
                            
                            if let status = self.logic.contributionVO?.status , status == .draft {
                                self.navigationItem.rightBarButtonItems = [self.deleteBtn, self.editBtn];
                            } else {
                                self.navigationItem.rightBarButtonItem = self.editBtn;
                            }
                            self.leftVC.setEditing(false, animated: true)
                            self.showToast(withTitle: "更新成功", subtitle: nil, type: .error)
                        }
                    }
                })
            }
            else {

                if let text = self.leftVC.titleTF.text , (text as NSString).length == 0 {
                    self.showToast(withTitle: "请输入书名", subtitle: nil, type: .alert)
                    return
                }

                if let text = self.leftVC.titleTF.text , (text as NSString).length > 64 {
                    self.showToast(withTitle: "书名不能超过64个字符", subtitle: nil, type: .alert)
                    return
                }

                if (self.leftVC.introTV.text as NSString).length == 0 {
                    self.showToast(withTitle: "请输入简介", subtitle: nil, type: .alert)
                    return
                }

                if let coverPath = self.logic.coverPath , (coverPath as NSString).length == 0 {
                    self.showToast(withTitle: "请上传封面", subtitle: nil, type: .alert)
                    return
                }

                if (self.leftVC.introTV.text as NSString).length > 300 {
                    self.showToast(withTitle: "简介不能超过300个字符", subtitle: nil, type: .alert)
                    return
                }

                if self.logic.categorys?.count < 2 {
                    self.showToast(withTitle: "请至少选择2个分类", subtitle: nil, type: .alert)
                    return
                }

                if self.logic.categorys?.count > 5 {
                    self.showToast(withTitle: "分类不能超过5个", subtitle: nil, type: .alert)
                    return
                }

                if self.logic.isLoading {
                    return
                }

                self.logic.isLoading = true

                self.saveBtn.isEnabled = false
                self.showLoading()
                self.logic.createBook(withTitle: self.leftVC.titleTF.text!, intro: self.leftVC.introTV.text, andComplete: { (aResponseObject, anError) -> Void in
                    self.hideLoading()
                    self.logic.isLoading = false
                    self.saveBtn.isEnabled = true

                    if let anError = anError as NSError? {
                        self.showToast(withTitle: anError.userInfo[NSLocalizedDescriptionKey] as? String, subtitle: nil, type: .error)
                        return ;
                    }

                    if let dict = aResponseObject as? [String: AnyObject] {
                        if let code = dict["code"] as? Int , code != 0 {
                            if let message = dict["data"] as? String {
                                self.showToast(withTitle: message, subtitle: nil, type: .error)
                            }
                            else {
                                self.showToast(withTitle: "创建失败", subtitle: nil, type: .error)
                            }
                        }
                        else {
                            self.titleView.isUserInteractionEnabled = true
                            self.navigationItem.leftBarButtonItem = self.backBtn
                            self.navigationItem.rightBarButtonItem = self.editBtn
                            self.navigationItem.titleView = self.titleView
                            self.segmentPaper?.pager.showPage(at: 1, animated: true)
                            self.leftVC.setEditing(false, animated: true)
                            self.showToast(withTitle: "创建成功", subtitle: nil, type: .error)
                        }
                    }
                })
            }
        }
    }

    @IBAction func onPressedDeleteBtn(_ sender: AnyObject) {
        let alert = UIAlertView()
        guard let title =  contributionVO?.book.title else {
            return
        }
        alert.bk_init(withTitle: "删除作品", message: "删除作品\"\(title)\"")
        alert.bk_addButton(withTitle: "取消") {
            
        }
        alert.bk_addButton(withTitle: "确定") { [weak self]() -> Void in
            if let weakSelf = self {
                weakSelf.logic.deleteBook { [weak weakSelf](aResponseObject, anError) in
                    if let weakSelf = weakSelf {
                        if anError == nil {
                            if let aResponseObject = aResponseObject as? [String: AnyObject] {
                                if let code = aResponseObject["code"] as? NSNumber , code.isEqual(to: NSNumber(value: 0)) {
                                    
                                    weakSelf.showToast(withTitle: "删除成功", subtitle: nil, type: ToastType.alert)
                                    weakSelf.onPressedBackBtn(weakSelf.backBtn)
                                }
                                else {
                                    if let message = aResponseObject["msg"] as? String {
                                        weakSelf.showToast(withTitle: message, subtitle: nil, type: ToastType.alert)
                                    }
                                    else {
                                        weakSelf.showToast(withTitle: "删除失败 ", subtitle: nil, type: ToastType.alert)
                                    }
                                }
                            }
                        }
                        else {
                            if let anError = anError as NSError? {
                                weakSelf.showToast(withTitle: anError.userInfo[NSLocalizedDescriptionKey] as? String, subtitle: nil, type: ToastType.error)
                            }
                            
                        }
                        weakSelf.hideLoading()
                    }
                }
            }
        }
        alert.show()
    }
    
    @IBAction func unwindToContributionBookFromCategory(_ segue: UIStoryboardSegue) {
        if let vc = segue.source as? QWContributionCategoryVC {
            self.leftVC.logic.categorys = vc.categorys;
            self.leftVC.categoryCV.reloadData()
        }
        if  let vc = segue.source as? QWContributionActivityVC {
            self.leftVC.logic.activitys = vc.activitys
            self.leftVC.setEditing(true, animated: true)
        }
        
    }
}
