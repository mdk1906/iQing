//
//  QWContributionContentVolumeTVC.swift
//  Qingwen
//
//  Created by Aimy on 10/26/15.
//  Copyright © 2015 iQing. All rights reserved.
//

import UIKit

class QWContributionContentVolumeTVC: QWBaseVC {

    var logic: QWContributionLogic!
    
    @IBOutlet var tableView: UITableView!

    var writingParams: (VolumeVO, ChapterVO?)? = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        self.tableView.separatorInset = UIEdgeInsets.zero;
        if #available(iOS 8.0, *) {
            self.tableView.layoutMargins = UIEdgeInsets.zero
        }

        self.tableView.mj_header = QWRefreshHeader(refreshingBlock: { [weak self] () -> Void in
            self?.getData()
        })

        self.getData()
    }

    @IBAction func onPressedAddVolumeBtn(_ sender: AnyObject) {
        let alertView = UIAlertView.bk_alertView(withTitle: "请输入卷标题") as! UIAlertView
        alertView.alertViewStyle = .plainTextInput
        alertView.textField(at: 0)?.placeholder = "卷名不能超过64个字符"
        alertView.bk_setCancelButton(withTitle: "取消") { () -> Void in
            self.endTextEditing()
        }

        alertView.bk_addButton(withTitle: "确定") { () -> Void in
            self.endTextEditing()
            if let title = alertView.textField(at: 0)?.text , (title as NSString).length > 0 {
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
                            self.getData()
                            self.showToast(withTitle: "创建成功", subtitle: nil, type: .error)
                        }
                    }
                })
            }
            else {
                self.showToast(withTitle: "请输入卷名", subtitle: nil, type: .alert)
            }
        }
        alertView.show()
    }

    @IBAction func onPressedAddChapterBtn(_ sender: AnyObject, event: UIEvent) {
        if let touch = event.allTouches?.first {
            let point = touch.location(in: self.tableView)
            if let indexPath = self.tableView.indexPathForRow(at: point), let volume = self.logic.volumeList?.results[(indexPath as NSIndexPath).section] as? VolumeVO {
                self.addChapter((volume, nil))
            }
        }
    }

    func addChapter(_ params: (VolumeVO, ChapterVO?)) {
        self.writingParams = params
        if let _ = params.1 {
            self.performSegue(withIdentifier: "chapter", sender: nil)
        } else {
//            self.performInMainThreadBlock({  //iPad 会出现问题
//                let actionSheet = UIActionSheet.bk_actionSheet(withTitle: "设置章节") as! UIActionSheet
//                actionSheet.bk_addButton(withTitle: "正文章节") {[weak self]() -> Void in
//                    if let weakSelf = self {
//                        let type: NSNumber = 1
//                        weakSelf.performSegue(withIdentifier: "chapter", sender: type)
//                    }
//                }
//                actionSheet.bk_addButton(withTitle: "设定章节") {[weak self]() -> Void in
//                    if let weakSelf = self {
//                        let type: NSNumber = 0
//                        weakSelf.performSegue(withIdentifier: "chapter", sender: type)
//                    }
//                }
//                actionSheet.bk_setCancelButton(withTitle: "取消") {
//                    
//                }
//                actionSheet.show(in: self.tableView)
//            })
            let actionSheet = UIActionSheet(title: "设置章节", delegate: self, cancelButtonTitle: "取消", destructiveButtonTitle: nil, otherButtonTitles: "正文章节", "设定章节")
            actionSheet.show(in: self.tableView)
        }
    }

    @IBAction func onPressedSubmitBtn(_ sender: AnyObject) {

        guard let volumes = self.logic.volumeList?.results as? [VolumeVO] else {
            self.showToast(withTitle: "没有任何卷，无法提交审核", subtitle: nil, type: .error)
            return ;
        }

        if volumes.count == 0 {
            self.showToast(withTitle: "该书无任何内容，无法提交审核", subtitle: nil, type: .error)
            return
        }

        for volume in volumes {
            if let chapters = volume.chapter , chapters.count == 0 {
                if let index = volumes.index(of: volume) {
                    self.showToast(withTitle: "第\(index + 1)卷无内容，无法提交审核", subtitle: nil, type: .error)
                }
                else {
                    self.showToast(withTitle: "有空卷，无法提交审核", subtitle: nil, type: .error)
                }
                return
            }
        }

        if self.logic.contributionVO?.status != .draft && self.logic.contributionVO?.status != .reject {
            self.showToast(withTitle: "只有草稿状态，退回状态的书才能提交审核", subtitle: nil, type: .error)
            return
        }

        self.submitBook()
    }

    func submitBook() {
        let alertView = UIAlertView.bk_alertView(withTitle: "确认提交审核？") as! UIAlertView
//        alertView.alertViewStyle = .plainTextInput
//        alertView.textField(at: 0)?.placeholder = "想对审核君说的话(可不填)"
        alertView.bk_setCancelButton(withTitle: "取消") { () -> Void in
            self.endTextEditing()
        }

        alertView.bk_addButton(withTitle: "提交审核") { () -> Void in

            self.showLoading()
            self.logic.submitBook(withComment: nil) { (aResponseObject, anError) -> Void in
                self.hideLoading()
                if let anError = anError as NSError? {
                    self.showToast(withTitle: anError.userInfo[NSLocalizedDescriptionKey] as? String, subtitle: nil, type: .error)
                    return
                }

                if let dict = aResponseObject as? [String: AnyObject] {
                    if let code = dict["code"] as? Int , code != 0 {
                        if let pack = dict["pack"] as? [String: Int], let chapter_id = pack["chapter_id"], let volume_id = pack["volume_id"] , code == 44 {
                            if let volumes = self.logic.volumeList?.results as? [VolumeVO] {
                                for volume in volumes {
                                    if let nid = volume.nid?.intValue , volume_id == nid {
                                        if let chapters = volume.chapter as? [ChapterVO] {
                                            for chapter in chapters {
                                                if let nid = chapter.nid?.intValue , chapter_id == nid {
                                                    if let chapterIndex = chapters.index(of: chapter), let volumeIndex = volumes.index(of: volume) {
                                                        self.showToast(withTitle: "第\(volumeIndex + 1)卷，第\(chapterIndex + 1)章，字数不足1千", subtitle: nil, type: .error)
                                                        return
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            return
                        }

                        if let message = dict["data"] as? String {
                            self.showToast(withTitle: message, subtitle: nil, type: .error)
                        }
                        else {
                            self.showToast(withTitle: "提交审核失败", subtitle: nil, type: .error)
                        }
                    }
                    else {
                        self.getData()
                        self.logic.contributionVO?.status = .inReview
                        self.update()
                        self.showToast(withTitle: "提交审核成功", subtitle: nil, type: .error)
                    }
                }
            }
        }
        alertView.show()
    }

    override func getData() {
        
        self.showLoading()
        self.logic.getDirectoryWithBookId((self.logic.book?.nid?.stringValue)!) { (aResponseObject, anError) -> Void in
            self.tableView.reloadData()
            self.tableView.mj_header.endRefreshing()
            self.update()
            self.hideLoading()
        }
    }

    override func update() {
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let params = self.writingParams {
            let nc = segue.destination as! UINavigationController
            let vc = nc.topViewController as! QWContributionWritingVC
            vc.volume = params.0
            vc.chapter = params.1
            vc.book = self.logic.book!
            if let sender = sender as? NSNumber {
                vc.type = sender
            }
        }
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        self.tableView.setEditing(editing, animated: animated)
    }
    
    func manageVolume(_ volume: VolumeVO) {
        let actionSheet = UIActionSheet.bk_actionSheet(withTitle: volume.title) as! UIActionSheet
        actionSheet.bk_addButton(withTitle: "管理章节") { 
            self.manageChapters(volume)
        }
        actionSheet.bk_addButton(withTitle: "修改卷目") {
            self.updateVolume(volume)
        }
        actionSheet.bk_addButton(withTitle: "删除卷目") {
            self.deleteVolume(volume)
        }
        actionSheet.bk_setCancelButton(withTitle: "取消") {
            
        }
        actionSheet.show(in: self.view)
    }
    
    func deleteVolume(_ volume: VolumeVO) {
        let alertView = UIAlertView.bk_alertView(withTitle: "是否删除该卷？") as! UIAlertView
        alertView.bk_setCancelButton(withTitle: "取消") { () -> Void in

        }

        alertView.bk_addButton(withTitle: "删除") { () -> Void in
            self.showLoading()
            self.logic.deleteVolume(withVolume: volume, andComplete: { (aResponseObject, anError) -> Void in
                self.hideLoading()
                if let anError = anError as NSError? {
                    self.showToast(withTitle: anError.userInfo[NSLocalizedDescriptionKey] as? String, subtitle: nil, type: .error)
                    return
                }

                if let _ = aResponseObject as? [String: AnyObject] {
                    self.getData()
                    self.showToast(withTitle: "删除卷成功", subtitle: nil, type: .error)
                }
            })
        }
        alertView.show()
    }
    
    func manageChapters(_ volume: VolumeVO) {
        let vc = QWContributionContentChapterTVC.createFromStoryboard(withStoryboardID: "contentchapter", storyboardName: "QWContribution")!
        vc.volume = volume
        vc.logic = self.logic
        self.navigationController?.pushViewController(vc, animated: true)
    }

    func addVolume() {
        let vc = QWContributionAddVolumeVC.createFromStoryboard(withStoryboardID: "addvolume", storyboardName: "QWContribution")!
        vc.logic = self.logic
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func updateVolume(_ volume: VolumeVO) {
        let vc = QWContributionAddVolumeVC.createFromStoryboard(withStoryboardID: "addvolume", storyboardName: "QWContribution")!
        vc.volume = volume
        vc.logic = self.logic
        self.navigationController?.pushViewController(vc, animated: true)
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
    
    override func leftBtnClicked(_ sender: AnyObject?) {
        self.cancelAllOperations()
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction override func rightBtnClicked(_ sender: AnyObject?) {
        let actionSheet = UIActionSheet.bk_actionSheet(withTitle: "") as! UIActionSheet
        
        actionSheet.bk_addButton(withTitle: "创建卷目") {
            let vc = QWContributionAddVolumeVC.createFromStoryboard(withStoryboardID: "addvolume", storyboardName: "QWContribution")!
            vc.logic = self.logic
            self.navigationController?.pushViewController(vc, animated: true)
        }
        actionSheet.bk_setCancelButton(withTitle: "取消") {
        
        }
        actionSheet.show(in: self.view)
    }
    
//MARK: Segue
    
    @IBAction func unwindToContributionVolumeFromAddVolume(_ segue: UIStoryboardSegue) {
        self.getData()
    }
}

extension QWContributionContentVolumeTVC: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        if let volumeList = self.logic.volumeList {
            return volumeList.results.count
        }
        else {
            return 0
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath as NSIndexPath).row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "volume", for: indexPath) as! QWContributionContentVolumeTVCell
            if let volumeVO = self.logic.volumeList?.results[(indexPath as NSIndexPath).section] as? VolumeVO {
                cell.updateWithVolume(volumeVO)
            }

            if #available(iOS 8.0, *) {
                cell.layoutMargins = UIEdgeInsets.zero
            }
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "chapter", for: indexPath) as! QWContributionContentChapterTVCell
            if let volumeVO = self.logic.volumeList?.results[(indexPath as NSIndexPath).section] as? VolumeVO, let chapters = volumeVO.chapter, let chapter = chapters[(indexPath as NSIndexPath).row - 1] as? ChapterVO {
                cell.updateWithChapter(chapter)
            }

            if #available(iOS 8.0, *) {
                cell.layoutMargins = UIEdgeInsets.zero
            }
            
            return cell
        }
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            guard let _ = self.logic.volumeList?.results as? [VolumeVO] else {
                return ;
            }

            if (indexPath as NSIndexPath).row == 0 {
                //如果不是草稿状态就不能删除唯一卷
                if let status = self.logic.contributionVO?.status , status != QWBookType.draft && self.logic.volumeList?.results.count == 1 {
                    self.showToast(withTitle: "无法删除唯一的卷", subtitle: nil, type: .alert)
                    return ;
                }

                if let volume = self.logic.volumeList?.results[(indexPath as NSIndexPath).section] as? VolumeVO {
                    self.deleteVolume(volume)
                }
            }
            else {
                if let volume = self.logic.volumeList?.results[(indexPath as NSIndexPath).section] as? VolumeVO, let chapters = volume.chapter, let chapter = chapters[(indexPath as NSIndexPath).row - 1] as? ChapterVO {

                    //如果只有一章则删除卷
                    if chapters.count == 1 {
                        //如果是草稿状态，就直接删除章节
                        if let status = self.logic.contributionVO?.status , status == QWBookType.draft {
                            self.deleteChapter(chapter)
                        }
                        else if self.logic.volumeList?.results.count == 1 {
                            self.showToast(withTitle: "无法删除唯一的章", subtitle: nil, type: .alert)
                        }
                        else {
                            self.deleteVolume(volume)
                        }
                    }
                    else {
                        self.deleteChapter(chapter)
                    }
                }
            }
        }
    }

    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return false;
    }

    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        if sourceIndexPath == destinationIndexPath {
            return
        }

        self.showLoading()
        if (sourceIndexPath as NSIndexPath).row == 0 {
            if var volumes = self.logic.volumeList?.results as? [VolumeVO] {
                let temp = volumes[(sourceIndexPath as NSIndexPath).section]
                volumes[(sourceIndexPath as NSIndexPath).section] = volumes[(destinationIndexPath as NSIndexPath).section]
                volumes[(destinationIndexPath as NSIndexPath).section] = temp
                self.logic.reorderVolume(volumes, andComplete: { (aResponseObject, anError) -> Void in
                    self.hideLoading()
                    self.getData()
                })
            }
        }
        else {
            if let volume = self.logic.volumeList?.results[(sourceIndexPath as NSIndexPath).section] as? VolumeVO, var chapters = volume.chapter as? [ChapterVO] {
                let temp = chapters[(sourceIndexPath as NSIndexPath).row - 1]
                chapters[(sourceIndexPath as NSIndexPath).row - 1] = chapters[(destinationIndexPath as NSIndexPath).row - 1]
                chapters[(destinationIndexPath as NSIndexPath).row - 1] = temp
                self.logic.reorderChapter(chapters, andComplete: { (aResponseObject, anError) -> Void in
                    self.hideLoading()
                    self.getData()
                })
            }
        }
    }

    func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        if (sourceIndexPath as NSIndexPath).row == 0 && (sourceIndexPath as NSIndexPath).section != (proposedDestinationIndexPath as NSIndexPath).section {
            if (sourceIndexPath as NSIndexPath).section < (proposedDestinationIndexPath as NSIndexPath).section {
                return proposedDestinationIndexPath
            }

            if (sourceIndexPath as NSIndexPath).section > (proposedDestinationIndexPath as NSIndexPath).section {
                return proposedDestinationIndexPath
            }
        }

        if (sourceIndexPath as NSIndexPath).row > 0 && (proposedDestinationIndexPath as NSIndexPath).row > 0 &&
            (sourceIndexPath as NSIndexPath).row != (proposedDestinationIndexPath as NSIndexPath).row &&
            (sourceIndexPath as NSIndexPath).section == (proposedDestinationIndexPath as NSIndexPath).section {
            return proposedDestinationIndexPath
        }

        return sourceIndexPath
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if (indexPath as NSIndexPath).row == 0 {
            guard let volume = self.logic.volumeList?.results[(indexPath as NSIndexPath).section] as? VolumeVO else {
                return ;
            }

            self.manageVolume(volume)
//            let alertView = UIAlertView.bk_alertView(withTitle: "请输入卷标题") as! UIAlertView
//            alertView.alertViewStyle = .plainTextInput
//            alertView.textField(at: 0)?.placeholder = "卷名不能超过64个字符"
//            alertView.textField(at: 0)?.text = volume.title
//            alertView.bk_setCancelButton(withTitle: "取消") { () -> Void in
//                self.endTextEditing()
//            }
//
//            alertView.bk_addButton(withTitle: "确定") { () -> Void in
//                
//            }
//            alertView.show()
        }
        else {
            if let volume = self.logic.volumeList?.results[(indexPath as NSIndexPath).section] as? VolumeVO, let chapters = volume.chapter {
                self.addChapter((volume, chapters[(indexPath as NSIndexPath).row - 1] as? ChapterVO))
            }
        }
    }
}

extension QWContributionContentVolumeTVC: UIActionSheetDelegate {
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
