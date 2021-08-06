//
//  QWContributionVolumeVC.swift
//  Qingwen
//
//  Created by mumu on 2017/9/4.
//  Copyright © 2017年 iQing. All rights reserved.
//

import UIKit

class QWContributionAddVolumeVC: QWBaseVC {
    
    
    typealias saveCompleteBlock = () -> Void
    
    @IBOutlet var titleTF: UITextField!
    
    var volume: VolumeVO?
    var book: BookVO?
    var logic: QWContributionLogic!
    var fromInfo = false
    override func viewDidLoad() {
        super.viewDidLoad()
        if let volume = self.volume {
            self.titleTF.text = volume.title
        }
        else {
            self.titleTF.placeholder = "必填, 不超过64字符"
        }
        self.titleTF.becomeFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    @IBAction override func rightBtnClicked(_ sender: AnyObject?) {
        endTextEditing()
        let actionSheet = UIActionSheet.bk_actionSheet(withTitle: "") as! UIActionSheet
        
        actionSheet.bk_addButton(withTitle:"保存修改") {
            if let _ = self.volume {
                self.updateVolume()
            }
            else {
                self.sumbitVolume()
            }
        }
        
        actionSheet.bk_setCancelButton(withTitle: "取消") {
            
        }
        actionSheet.show(in: self.view)
    }
    
    func updateVolume(completeBlock:saveCompleteBlock? = nil) {
        if let title = self.titleTF.text , (title as NSString).length > 0, let volume = volume {
            if (title as NSString).length > 64 {
                self.showToast(withTitle: "卷名不能超过64个字符", subtitle: nil, type: .alert)
                return
            }
            
            self.showLoading()
            self.logic.updateVolume(withVolume: volume, title: title, andComplete: { (aResponseObject, anError) -> Void in
                if let anError = anError as NSError?{
                    self.showToast(withTitle: anError.userInfo[NSLocalizedDescriptionKey] as? String, subtitle: nil, type: .error)
                    return
                }
                
                if let _ = aResponseObject as? [String: AnyObject] {
                    self.getData()
                    if let completeBlock = completeBlock{
                        completeBlock()
                    }
                    else {
                        self.showToast(withTitle: "修改成功", subtitle: nil, type: .error)
                    }
                }
                self.hideLoading()
            })
        }
        else {
            self.showToast(withTitle: "请输入卷名", subtitle: nil, type: .alert)
        }
    }
    
    func sumbitVolume(completeBlock:saveCompleteBlock? = nil) {
        self.endTextEditing()
        if let title = self.titleTF.text , (title as NSString).length > 0 {
            if (title as NSString).length > 64 {
                self.showToast(withTitle: "卷名不能超过64个字符", subtitle: nil, type: .alert)
                return
            }
            
            self.showLoading()
            self.logic.createVolume(withTitle: title, andComplete: { (aResponseObject, anError) -> Void in
                self.hideLoading()
                if let anError = anError as NSError? {
                    self.showToast(withTitle: anError.userInfo[NSLocalizedDescriptionKey] as? String, subtitle: nil, type: .error)
                    return
                }
                
                if let _ = aResponseObject as? [String: AnyObject] {
                    self.getData()
                    self.showToast(withTitle: "创建成功", subtitle: nil, type: .error)
                    self.volume = VolumeVO.vo(withDict: aResponseObject as? [String : Any])
                    if let completeBlock = completeBlock{
                        completeBlock()
                    }
                }
            })
        }
        else {
            self.showToast(withTitle: "请输入卷名", subtitle: nil, type: .alert)
        }
    }
    
    @IBAction func onPressedManageChaptersBtn(_ sender: AnyObject) {
        let push:()->Void = {
            let vc = QWContributionContentChapterTVC.createFromStoryboard(withStoryboardID: "contentchapter", storyboardName: "QWContribution")!
            vc.volume = self.volume
            vc.logic = self.logic
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        if let _ = self.volume {
            self.updateVolume(completeBlock: { 
                push()
            })
        }
        else {
            self.sumbitVolume(completeBlock: { 
                push()
            })
        }
    }
    
    override func leftBtnClicked(_ sender: AnyObject?) {
        self.cancelAllOperations()
        if let _ = self.volume, fromInfo == false {
            self.performSegue(withIdentifier: "tovolume", sender: nil)
        }
        else {
            _ = self.navigationController?.popViewController(animated: true)
        }
    }
    
}
