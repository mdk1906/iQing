//
//  QWContributionDraftTVCell.swift
//  Qingwen
//
//  Created by Aimy on 4/11/16.
//  Copyright © 2016 iQing. All rights reserved.
//

import UIKit

class QWContributionDraftTVCell: QWContributionContentChapterTVCell {
    
    @IBOutlet var publishTimeLabel: UILabel!
    
    override func updateWithChapter(_ chapter: ChapterVO) {
        super.updateWithChapter(chapter)
        if let release_time = chapter.release_time {
            self.statusBtn.setTitle("定时中", for: .normal)
            self.statusBtn.backgroundColor = UIColor(hex: 0xA29BF0)
            self.publishTimeLabel.text = "定时：\(QWHelper.fullDate(toString: release_time)!)"
            self.publishTimeLabel.isHidden = false
            self.timeLab.isHidden = true
        }
        else {
            self.publishTimeLabel.isHidden = true
        }
    }
}
