//
//  QWContributionContentChapterTVC.swift
//  Qingwen
//
//  Created by mumu on 2017/9/4.
//  Copyright © 2017年 iQing. All rights reserved.
//

import UIKit

class QWContributionContentChapterTVC: QWBaseVC {
    
    @IBOutlet var tableView: UITableView!
    
    var logic: QWContributionLogic!
    var writingParams: (VolumeVO, ChapterVO?)? = nil
    var volume: VolumeVO!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = volume.title
        if #available(iOS 11.0, *) {
            self.tableView.contentInset = UIEdgeInsetsMake(self.view.safeAreaInsets.top, 0, self.view.safeAreaInsets.bottom, 0)
        }
        else{
            self.tableView.contentInset = UIEdgeInsetsMake(64, 0, 0, 0)
        }
        
        
        self.tableView.separatorInset = UIEdgeInsets.zero;
        if #available(iOS 8.0, *) {
            self.tableView.layoutMargins = UIEdgeInsets.zero
        }
        
        self.tableView.mj_header = QWRefreshHeader(refreshingBlock: { [weak self] () -> Void in
            self?.getData()
        })
        
        self.getData()
        
    }
    
    override func getData() {
        guard let volume = self.volume else {
            return
        }
        
        self.showLoading()
        self.logic.getChaptersWithVolume(volume) { (aResponseObject, anError) -> Void in
            self.tableView.reloadData()
            self.tableView.mj_header.endRefreshing()
            self.update()
            self.hideLoading()
        }
    }
    
    override func rightBtnClicked(_ sender: AnyObject?) {
        
        if #available(iOS 8.0, *) , SWIFT_IS_IPAD_DEVICE{
            let actionSheet = UIAlertController(title: "", message: nil, preferredStyle: .actionSheet)
            actionSheet.addAction(UIAlertAction(title: "新增草稿", style: .default, handler: { [weak self](_) in
                guard let weakSelf = self else { return }
                weakSelf.addChapter((weakSelf.volume, nil))
            }))
            actionSheet.addAction(UIAlertAction(title: "取消", style: .cancel, handler: { (_) in
                
            }))
            actionSheet.popoverPresentationController?.barButtonItem = self.navigationItem.rightBarButtonItem
            self.present(actionSheet, animated: true, completion: nil)
        }
        else {
            let actionSheet = UIActionSheet.bk_actionSheet(withTitle: nil) as! UIActionSheet
            actionSheet.bk_addButton(withTitle: "新增草稿") {[weak self] () in
                guard let weakSelf = self else { return }
                weakSelf.addChapter((weakSelf.volume, nil))
            }
            
            actionSheet.bk_setCancelButton(withTitle: "取消") {
                
            }
            
            actionSheet.show(in: self.view)
        }
    }
    
    func manageChapter(_ params: (VolumeVO, ChapterVO?), cell: UITableViewCell) {
        self.writingParams = params
        if #available(iOS 8.0, *), SWIFT_IS_IPAD_DEVICE {
            let actionSheet = UIAlertController(title: "设置草稿", message: nil, preferredStyle: .actionSheet)
            actionSheet.addAction(UIAlertAction(title: "修改作者的话", style: .default, handler: { (_) in
                self.updateWhisper(params.1!)
            }))
            actionSheet.addAction(UIAlertAction(title: "删除章节", style: .default, handler: { (_) in
                self.deleteChapter(params.1!)
            }))
            actionSheet.addAction(UIAlertAction(title: "修改正文", style: .default, handler: { (_) in
                self.updateChapter(params.1!)
            }))
            actionSheet.addAction(UIAlertAction(title: "取消", style: .cancel, handler: { (_) in
            }))
            actionSheet.popoverPresentationController?.sourceView = cell
            actionSheet.popoverPresentationController?.sourceRect = cell.bounds
            self.present(actionSheet, animated: true, completion: nil)
        }
        else {
            let actionSheet = UIActionSheet.bk_actionSheet(withTitle: "设置章节") as! UIActionSheet
            actionSheet.bk_addButton(withTitle: "修改作者的话") {
                self.updateWhisper(params.1!)
            }
            actionSheet.bk_addButton(withTitle: "删除章节") {
                self.deleteChapter(params.1!)
            }
            actionSheet.bk_addButton(withTitle: "修改正文") {
                self.updateChapter(params.1!)
            }
            actionSheet.bk_setCancelButton(withTitle: "取消") {
                
            }
            actionSheet.show(in: self.view)
        }
    }
    
    func addChapter(_ params: (VolumeVO, ChapterVO?)) {
        
        self.writingParams = params
        let actionSheet = UIActionSheet(title: "设置章节", delegate: self, cancelButtonTitle: "取消", destructiveButtonTitle: nil, otherButtonTitles: "正文章节", "设定章节")
        actionSheet.show(in: self.tableView)
    }
    func updateWhisper(_ chapter: ChapterVO)  {
        let alertView = UIAlertView.bk_alertView(withTitle: "提示", message: "已通过章节只可修改作者的话") as! UIAlertView
        alertView.bk_addButton(withTitle: "确定修改") {
            chapter.editWhisper = true
            self.performSegue(withIdentifier: "chapter", sender:chapter.type)
        }
        alertView.bk_addButton(withTitle: "暂不修改") {
            
        }
        alertView.show()
    }
    func updateChapter(_ chapter: ChapterVO) {
        let alertView = UIAlertView.bk_alertView(withTitle: "提示", message: "已通过章节暂不支持修改内容，您可以创建一个当前章节的副本，修改后覆盖当前章节即可。") as! UIAlertView
        alertView.bk_addButton(withTitle: "创建副本") {
            self.performSegue(withIdentifier: "chapter", sender:chapter.type)
        }
        alertView.bk_addButton(withTitle: "暂不创建") {
            
        }
        alertView.show()
    }
    func deleteChapter(_ chapter: ChapterVO) {
        let alertView = UIAlertView.bk_alertView(withTitle: "是否删除该章？") as! UIAlertView
        alertView.bk_setCancelButton(withTitle: "取消") { () -> Void in
            
        }
        
        alertView.bk_addButton(withTitle: "删除") { () -> Void in
            self.showLoading()
            self.logic.deleteChapter(withChapter: chapter, andComplete: { (aResponseObject, anError) -> Void in
                self.hideLoading()
                if let anError = anError as NSError?{
                    self.showToast(withTitle: anError.userInfo[NSLocalizedDescriptionKey] as? String, subtitle: nil, type: .error)
                    return
                }
                
                if let dict = aResponseObject as? [String: AnyObject] {
                    if let code = dict["code"] as? Int , code != 0 {
                        if let message = dict["data"] as? String {
                            self.showToast(withTitle: message, subtitle: nil, type: .error)
                        }
                        else {
                            self.showToast(withTitle: "删除章失败", subtitle: nil, type: .error)
                        }
                    }
                    else {
                        self.getData()
                        self.showToast(withTitle: "删除章成功", subtitle: nil, type: .error)
                    }
                }
            })
        }
        alertView.show()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let params = self.writingParams {
            let nc = segue.destination as! UINavigationController
            let vc = nc.topViewController as! QWContributionWritingVC
            vc.volume = params.0
            if let chapter = params.1 {
                vc.chapter = chapter
                vc.type = chapter.type!
            }
            vc.book = self.logic.book!
            if let sender = sender as? NSNumber {
                vc.type = sender
            }
        }
    }
    
    @IBAction func unwindToContributionChapterFromWritting(_ segue: UIStoryboardSegue) {
        switch segue.identifier {
        case let identifier where identifier == "chapterupdate":
            self.getData()
        default:
            break
        }
    }
}

extension QWContributionContentChapterTVC:UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let chapters = volume?.chapter,chapters.count > 0 {
            return chapters.count
        }
        else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "chapter", for: indexPath) as! QWContributionContentChapterTVCell
        if let chapter = self.volume?.chapter?[indexPath.row] as? ChapterVO {
            cell.updateWithChapter(chapter)
        }
        if #available(iOS 8.0, *) {
            cell.layoutMargins = UIEdgeInsets.zero
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let chapter = volume.chapter?[indexPath.row] as? ChapterVO{
            if chapter.status != .inReview{
                self.manageChapter((volume, chapter),cell: tableView.cellForRow(at: indexPath)!)
            }
            else {
                self.showToast(withTitle: "审核中的章节不可修改", subtitle: nil, type: .error)
            }
        }
    }
}

extension QWContributionContentChapterTVC: UIActionSheetDelegate {
    func actionSheet(_ actionSheet: UIActionSheet, didDismissWithButtonIndex buttonIndex: Int) {
        switch buttonIndex {
        case 0:
            break
        case 1:
            let type: NSNumber = 1
            self.performSegue(withIdentifier: "chapter", sender: type)
        case 2:
            let type: NSNumber = 0
            self.performSegue(withIdentifier: "chapter", sender: type)
        default:
            break
        }
    }
}

