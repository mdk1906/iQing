//
//  createNewBooksList.swift
//  Qingwen
//
//  Created by wei lu on 15/12/17.
//  Copyright © 2017 iQing. All rights reserved.
//

import UIKit

extension QWBooksListCreate{
    override static func registMapping() {
        let vo = QWMappingVO()
        vo.className = NSStringFromClass(self)
        vo.storyboardName = "QWBookListCreator"
        vo.storyboardID = "CreateNewBooksList"
        QWRouter.sharedInstance().register(vo, withKey: "CreateNewBooksList")
    }
}

class QWBooksListCreate: QWBaseVC {
    
    @IBOutlet var intro: UITextField!
    @IBOutlet var name: UITextField!
    var contributionVO: ContributionVO?
    var actionType:NSString?
    var nid:String?
    lazy var logic: QWCreateBooksListLogic = {
        let logic = QWCreateBooksListLogic(operationManager: self.operationManager)
        return logic
    }()
    
    
    @IBAction func saveBtnCliecked(_ sender: Any) {
        endTextEditing()
        self.sumbitLists()
    }
    

    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.name.placeholder = "必填, 不超过64字符"
        self.intro.placeholder = "必填, 不超过300字符"
        
        if let extra = self.extraData {
            if let type = extra.objectForCaseInsensitiveKey("action") as? NSString {
                self.actionType = type
                if (type == "update"){
                    self.name.placeholder = ""
                    self.intro.placeholder = ""
                    if let lid = extra.objectForCaseInsensitiveKey("id") as? String {
                        self.nid = lid
                    }
                    
                    if let title = extra.objectForCaseInsensitiveKey("title") as? String {
                        self.name.text = title as String
                    }
                    
                    if let intro = extra.objectForCaseInsensitiveKey("intro") as? String {
                         self.intro.text = intro as String
                    }
                    self.intro.becomeFirstResponder()
                    return
                }
            }
        }
        self.name.becomeFirstResponder()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    func sumbitLists() {
        self.endTextEditing()
        if let booksTitle = self.name.text ,let booksIntro = self.intro.text, (booksTitle as String).length > 0,(booksIntro as String).length > 0 {
            if (booksTitle as String).length > 64 {
                self.showToast(withTitle: "书单名不能超过64个字符", subtitle: nil, type: .alert)
                return
            }
            if (booksIntro as String).length > 300 {
                self.showToast(withTitle: "简介不能超过300个字符", subtitle: nil, type: .alert)
                return
            }
            
            self.showLoading()
            var actiongUrl = "/favorite/"
            if (self.actionType == "update"){
                if(self.nid == nil){
                    self.showToast(withTitle: "没有找到该书单", subtitle: nil, type: .alert)
                    return
                }
                actiongUrl = "/favorite/" + self.nid! + "/change/"
            }
            self.logic.postNewBooksListWithCompleteBlock(title: booksTitle, intro:booksIntro,url:actiongUrl, { (aResponseObject, anError) -> Void in
                self.hideLoading()
                if let anError = anError as NSError? {

                    self.showToast(withTitle: anError.userInfo[NSLocalizedDescriptionKey] as? String, subtitle: nil, type: .error)
                    return
                }
                
                if let aResponseObject = aResponseObject as? [String: AnyObject] {
                    let respon = (self.actionType == "update") ? "更新成功" : "创建成功"
                    
                    
                    if let code = aResponseObject["code"] as? NSNumber, code.isEqual(to: NSNumber(value: 0)) {
                        self.showToast(withTitle: respon, subtitle: nil, type: .error)
                        if(self.actionType != "update"){//create
                            QWGlobalValue.sharedInstance().created_favorite = 1
                            QWGlobalValue.sharedInstance().save()
                        }
                        self.presentingViewController?.dismiss(animated: false, completion:nil)
                    }else{
                        self.showToast(withTitle: aResponseObject["msg"] as? String, subtitle: nil, type: .error)
                    }
                   
                }
            })
        }
        else {
            self.showToast(withTitle: "请输入名称和简介", subtitle: nil, type: .alert)
        }
    }
    
}
