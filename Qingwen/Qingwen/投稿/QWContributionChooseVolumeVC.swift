//
//  QWContributionChooseVolumeVC.swift
//  Qingwen
//
//  Created by Aimy on 4/11/16.
//  Copyright © 2016 iQing. All rights reserved.
//

import UIKit

class QWContributionChooseVolumeVC: QWBaseVC {

    lazy var logic: QWContributionLogic = {
        return QWContributionLogic(operationManager: self.operationManager)
    }()

    @IBOutlet var tableView: UITableView!

    var currentIndex: IndexPath?
    
    let publishView = QWContributionPublishView.createWithNib()!
    
    var draft = true
    var chapterId = ""
    var bookId = ""
    var chapterType: NSNumber = 1
    var time: Date?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.mj_header = QWRefreshHeader(refreshingBlock: { [weak self] () -> Void in
            self?.getData()
        })
        
        getData()
    }

    override func getData() {
        self.logic.getDirectoryWithBookId(bookId) { (aResponseObject, anError) in
            if let list = self.logic.volumeList , list.results.count == 0 {
                self.showToast(withTitle: "请先去创建卷目", subtitle: nil, type: .alert)
            }

            self.tableView.mj_header.endRefreshing()
            self.tableView.reloadData()
        }
        
    }
    
    func submitDraft(with releaseDate: Date?) {
        guard let currentIndex = self.currentIndex, let volume = self.logic.volumeList?.results[(currentIndex as NSIndexPath).row] as? VolumeVO, let nid = volume.nid?.stringValue else {
            return
        }

        if let date = releaseDate {
            self.showLoading()
            self.logic.releaseDraft(withDraftId: self.chapterId, volumeId: nid, chapterType:chapterType, date: date) { (aResponseObject, anError) in
                self.hideLoading()
                if let anError = anError as NSError?{
                    self.showToast(withTitle: anError.userInfo[NSLocalizedDescriptionKey] as? String, subtitle: nil, type: .error)
                    return
                }
                
                if let _ = aResponseObject as? [String: AnyObject] {
                    if self.draft {
                        self.performSegue(withIdentifier: "draftupdate", sender: nil)
                    } else {
                        self.performSegue(withIdentifier: "chapterupdate", sender: nil)
                    }
                    self.showToast(withTitle: "定时发布成功", subtitle: nil, type: .error)
                }
            }
        } else {
            self.showLoading()
            self.logic.releaseDraft(withDraftId: self.chapterId, volumeId: nid, chapterType:chapterType, date: nil) { (aResponseObject, anError) in
                self.hideLoading()
                if let anError = anError as NSError?{
                    self.showToast(withTitle: anError.userInfo[NSLocalizedDescriptionKey] as? String, subtitle: nil, type: .error)
                    return
                }
                
                if let _ = aResponseObject as? [String: AnyObject] {
                    if self.draft {
                        self.performSegue(withIdentifier: "draftupdate", sender: nil)
                    } else {
                        self.performSegue(withIdentifier: "chapterupdate", sender: nil)
                    }
                    self.showToast(withTitle: "发布成功", subtitle: nil, type: .error)
                }
            }
        }
    }
}

extension QWContributionChooseVolumeVC: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let list = self.logic.volumeList {
            return list.results.count
        }
        else {
            return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! QWContributionChooseVolumeTVCell
        if let volume = self.logic.volumeList?.results[(indexPath as NSIndexPath).row] as? VolumeVO {
            cell.updateWithVolume(volume)
        }

        cell.selectedView.isHighlighted = indexPath == self.currentIndex
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.currentIndex = indexPath
        self.tableView.reloadData()
        
        if let window = UIApplication.shared.delegate?.window {
            window?.addSubview(self.publishView)
            self.publishView.frame = self.view.bounds;
            self.publishView.delegate = self
        }
    }
}

extension QWContributionChooseVolumeVC: QWContributionPublishViewDelegate {
    func publishView(_ view: QWContributionPublishView, onPressedPublishBtn sender: AnyObject) {
        self.submitDraft(with: nil)
    }
    func publishView(_ view: QWContributionPublishView, onPressedCancelPublishBtn sender: AnyObject) {
        
    }
    func publishView(_ view: QWContributionPublishView, onPressedTimePublishBtn sender: AnyObject, time: Date) {
        self.submitDraft(with: time)
    }
    
}
