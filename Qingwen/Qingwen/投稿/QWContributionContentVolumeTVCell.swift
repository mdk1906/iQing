//
//  QWContributionContentVolumeTVCell.swift
//  Qingwen
//
//  Created by Aimy on 10/30/15.
//  Copyright © 2015 iQing. All rights reserved.
//

import UIKit

class QWContributionContentVolumeTVCell: QWBaseTVCell {

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var statusBtn: UIButton!
    @IBOutlet var countLabel: UILabel!
    @IBOutlet var chapterCountLabel: UILabel!
    

    func updateWithVolume(_ volume: VolumeVO) {
        self.titleLabel.text = volume.title
        self.countLabel.text = "字数：\(QWHelper.count(toShortString: volume.count)!)"
        self.chapterCountLabel.text = "章节：\(QWHelper.count(toShortString: volume.chapter_count)!)"
        if volume.status!.intValue == 0 {
            self.statusBtn.setTitle("不可见", for: .normal)
            self.statusBtn.backgroundColor = UIColor(hex: 0xF35588)
        }
        else {
            self.statusBtn.setTitle("可见", for: .normal)
            self.statusBtn.backgroundColor = UIColor(hex: 0x64C18B)
        }
    }

//    override func setEditing(_ editing: Bool, animated: Bool) {
//        super.setEditing(editing, animated: animated)
//        self.addChapterBtn.isHidden = editing
//    }
}
