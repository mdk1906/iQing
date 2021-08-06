//
//  QWContributionDraftVC.swift
//  Qingwen
//
//  Created by Aimy on 4/11/16.
//  Copyright © 2016 iQing. All rights reserved.
//

import UIKit

class QWContributionDraftVC: QWBaseVC {

    var logic: QWContributionLogic!

    var publishView: QWContributionPublishView?

    var chapter: ChapterVO?

    @IBOutlet var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        self.tableView.separatorInset = UIEdgeInsets.zero;
        
        if #available(iOS 8.0, *) {
            self.tableView.layoutMargins = UIEdgeInsets.zero
        }
        if #available(iOS 11.0, *) {
            self.tableView.contentInset = UIEdgeInsetsMake(self.view.safeAreaInsets.top, 0, 0, 0)
        }else{
           self.tableView.contentInset = UIEdgeInsetsMake(64, 0, 0, 0)
        }
        self.tableView.mj_header = QWRefreshHeader(refreshingBlock: { [weak self] () -> Void in
            self?.getData()
        })

        self.getData()
    }

    override func update() {
        self.tableView.mj_header.beginRefreshing()
    }

    override func getData() {
        if let nid = self.logic.book?.nid {
            self.logic.getDraftsWithBookId(nid.stringValue, andComplete: { (aResponseObject, anError) in
                self.tableView.mj_header.endRefreshing()
                self.tableView.reloadData()
            })
        }
    }

    @IBAction func unwindToContributionDraftFromChapter(_ segue: UIStoryboardSegue) {
        switch segue.identifier {
        case let identifier where identifier == "draftupdate":
            self.tableView.mj_header.beginRefreshing()
        default:
            break
        }
    }

    @IBAction func onPressedTimeBtn(_ sender: AnyObject, event: UIEvent) {
        if let touch = event.allTouches?.first {
            let point = touch.location(in: self.tableView)
            if let indexPath = self.tableView.indexPathForRow(at: point), let chapter = self.logic.draftList?.results[(indexPath as NSIndexPath).row] as? ChapterVO {
                self.showPublishView(chapter)
            }
        }
    }

    func showPublishView(_ chapter: ChapterVO) {
        self.chapter = chapter
        self.publishView = QWContributionPublishView.createWithNib()

        if let release_time = self.chapter?.release_time {
            self.publishView?.timePicker.date = release_time
            self.publishView?.timeLabel.text = QWHelper.fullDate(toString: release_time)
        }

//        self.publishView!.delegate = self;
        self.publishView!.frame = self.view.bounds;
        self.navigationController?.view.addSubview(self.publishView!)
    }
    
    func cancelReleaseDraft(_ chapter: ChapterVO) {
        let alert = UIAlertView.bk_alertView(withTitle: "是否撤回当前章节的定时发布", message: nil) as! UIAlertView
        alert.bk_addButton(withTitle: "取消") { 
            
        }
        alert.bk_addButton(withTitle: "确定") {
            self.showLoading()
            self.logic.cancelreleaseDraft(withChapterId: (chapter.nid?.stringValue)!) { [weak self](aResponseObject, anError) in
                guard let `self` =  self else {
                    return
                }
                self.hideLoading()
                if let anError = anError as NSError? {
                    self.showToast(withTitle: anError.userInfo[NSLocalizedDescriptionKey] as? String, subtitle: nil, type: .error)
                    return
                }
                
                if let _ = aResponseObject as? [String: AnyObject] {
                    self.getData()
                    self.showToast(withTitle: "撤回发布成功", subtitle: nil, type: .error)
                }
            }
        }
        alert.show()
    }

    @IBAction func onPressedAddDraftBtn(_ sender: AnyObject) {
        if self.logic.contributionVO?.status == .approve || self.logic.contributionVO?.status == .partReview {
            self.addChapter(nil)
        }
        else {
            self.showToast(withTitle: "只有审核通过的书才能创建草稿", subtitle: nil, type: .alert)
        }
    }

    func addChapter(_ chapter: ChapterVO?) {
        if let _ = self.logic.book {
            if let chapter = chapter {
                 self.performSegue(withIdentifier: "chapter", sender: chapter)
            }
            else {
                let actionSheet = UIActionSheet(title: "设置章节", delegate: self, cancelButtonTitle: "取消", destructiveButtonTitle: nil, otherButtonTitles: "正文章节", "设定章节")
                actionSheet.show(in: self.tableView)
            }
        }
    }
    
    func manageChapter(_ chapter: ChapterVO, cell: UITableViewCell) {
        
        if #available(iOS 8.0, *), SWIFT_IS_IPAD_DEVICE {
            let actionSheet = UIAlertController(title: "设置草稿", message: nil, preferredStyle: .actionSheet)
            actionSheet.addAction(UIAlertAction(title: "创建草稿", style: .default, handler: { (_) in
                self.addChapter(nil)
            }))
            actionSheet.addAction(UIAlertAction(title: "修改草稿", style: .default, handler: { (_) in
                self.performSegue(withIdentifier: "chapter", sender: chapter)
            }))
            actionSheet.addAction(UIAlertAction(title: "取消", style: .cancel, handler: { (_) in
                
            }))
            actionSheet.popoverPresentationController?.sourceView = cell
            actionSheet.popoverPresentationController?.sourceRect = cell.bounds
            self.present(actionSheet, animated: true, completion: nil)
        }
        else {
            let actionSheet = UIActionSheet.bk_actionSheet(withTitle: "设置章节") as! UIActionSheet
            actionSheet.bk_addButton(withTitle: "删除草稿") {
                self.deleteChapter(chapter)
            }
            actionSheet.bk_addButton(withTitle: "修改草稿") {
                self.performSegue(withIdentifier: "chapter", sender: chapter)
            }
            actionSheet.bk_setCancelButton(withTitle: "取消") {
                
            }
            actionSheet.show(in: self.view)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let nc = segue.destination as! UINavigationController
        let vc = nc.topViewController as! QWContributionWritingVC
        vc.book = self.logic.book!
        
        if let chapter = sender as? ChapterVO {
            vc.chapter = chapter
            vc.type = chapter.type!
        }
       
        vc.draft = true
        if let sender = sender as? NSNumber {
            vc.type = sender
        }
    }

    func deleteChapter(_ chapter: ChapterVO) {
        let alertView = UIAlertView.bk_alertView(withTitle: "是否删除该草稿？") as! UIAlertView
        alertView.bk_setCancelButton(withTitle: "取消") { () -> Void in

        }
        alertView.bk_addButton(withTitle: "删除") { () -> Void in
            self.showLoading()
            self.logic.deleteDraft(withChapter: chapter, andComplete: { (aResponseObject, anError) -> Void in
                self.hideLoading()
                if let anError = anError as NSError? {
                    self.showToast(withTitle: anError.userInfo[NSLocalizedDescriptionKey] as? String, subtitle: nil, type: .error)
                    return
                }

                if let _ = aResponseObject as? [String: AnyObject] {
                    self.getData()
                    self.showToast(withTitle: "删除草稿成功", subtitle: nil, type: .error)
                }
            })
        }
        alertView.show()
    }
    
    override func rightBtnClicked(_ sender: AnyObject?) {
        if #available(iOS 8.0, *) , SWIFT_IS_IPAD_DEVICE{
            let actionSheet = UIAlertController(title: "设置草稿", message: nil, preferredStyle: .actionSheet)
            actionSheet.addAction(UIAlertAction(title: "创建草稿", style: .default, handler: { (_) in
                self.addChapter(nil)
            }))
            actionSheet.addAction(UIAlertAction(title: "取消", style: .cancel, handler: { (_) in
                
            }))
            actionSheet.popoverPresentationController?.barButtonItem = self.navigationItem.rightBarButtonItem
            self.present(actionSheet, animated: true, completion: nil)
        }
        else {
            let actionSheet = UIActionSheet.bk_actionSheet(withTitle: "") as! UIActionSheet
            
            actionSheet.bk_addButton(withTitle: "创建草稿") {
                self.addChapter(nil)
            }
            actionSheet.bk_setCancelButton(withTitle: "取消") {
            }
            actionSheet.show(in: self.view)
        }
    }
}



extension QWContributionDraftVC: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let draftList = self.logic.draftList {
            return draftList.results.count
        }
        else {
            return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "chapter", for: indexPath) as! QWContributionDraftTVCell
        
        if #available(iOS 8.0, *) {
            cell.layoutMargins = UIEdgeInsets.zero
        }
        
        if let chapter = self.logic.draftList?.results[indexPath.row] as? ChapterVO {
            cell.updateWithChapter(chapter)
        }

        return cell;
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        guard let chapter = self.logic.draftList?.results[indexPath.row] as? ChapterVO else {
            return
        }
        
        if let _ = chapter.release_time {
            self.cancelReleaseDraft(chapter)
            return
        }
        
        if chapter.status == .unReview || chapter.status == .draft{
            self.manageChapter(chapter,cell: tableView.cellForRow(at: indexPath)!)
            
        } else if chapter.status == .inReview || chapter.status == .aiReview{
//            self.showToast(withTitle: "审核中的章节不允许修改", subtitle: nil, type: .error)
            let alertView = UIAlertView.bk_alertView(withTitle: "是否撤回正在审核中的章节？") as! UIAlertView
            alertView.bk_setCancelButton(withTitle: "取消") { () -> Void in
                
            }
            alertView.bk_addButton(withTitle: "撤回") { () -> Void in
                self.logic.withdrawDraft(withChapterId: (chapter.nid?.stringValue)!) { [weak self](aResponseObject, anError) in
                    guard let `self` =  self else {
                        return
                    }
                    self.hideLoading()
                    if let anError = anError as NSError? {
                        self.showToast(withTitle: anError.userInfo[NSLocalizedDescriptionKey] as? String, subtitle: nil, type: .error)
                        return
                    }
                    
                    if let _ = aResponseObject as? [String: AnyObject] {
                        self.getData()
                        self.showToast(withTitle: "撤回成功", subtitle: nil, type: .error)
                    }
                }
                
            }
            alertView.show()
            
        }
        else {
            self.showToast(withTitle: "只有草稿和未通过章节可以修改", subtitle: nil, type: .error)
        }
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if let chapter = self.logic.draftList?.results[indexPath.row] as? ChapterVO {
                self.deleteChapter(chapter)
            }
        }
    }
}

extension QWContributionDraftVC: UIActionSheetDelegate {
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
