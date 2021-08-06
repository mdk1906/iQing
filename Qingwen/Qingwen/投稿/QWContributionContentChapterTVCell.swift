//
//  QWContributionContentChapterTVCell.swift
//  Qingwen
//
//  Created by Aimy on 10/30/15.
//  Copyright © 2015 iQing. All rights reserved.
//

import UIKit

class QWContributionContentChapterTVCell: QWBaseTVCell {

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var countLabel: UILabel!
    @IBOutlet var statusBtn: UIButton!
    var timeLab :UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        timeLab = UILabel.init()
        timeLab.frame = CGRect(x:90,y:39,width:200,height:14.5)
        timeLab.font = UIFont.systemFont(ofSize: 12)
        timeLab.textColor = UIColor(hex: 0xc0c0c0)
        timeLab.removeFromSuperview()
        timeLab.isHidden = true
        self.contentView.addSubview(timeLab)
    }
    func updateWithChapter(_ chapter: ChapterVO) {
        self.titleLabel?.text = chapter.title
        self.countLabel.text = "字数：\(QWHelper.count(toShortString: chapter.count)!)"
        
        switch chapter.status {
        case .draft:
            self.statusBtn.setTitle("草稿", for: .normal)
            self.statusBtn.backgroundColor = UIColor(hex: 0x64C18B)
            
        case .inReview:
            self.statusBtn.setTitle("编辑复核中", for: .normal)
            self.statusBtn.backgroundColor = UIColor(hex: 0xFEA958)
            timeLab.text = "已审核" + chapter.human_time!
            timeLab.isHidden = false
        case .unReview:
            self.statusBtn.setTitle("未通过", for: .normal)
            self.statusBtn.backgroundColor = UIColor(hex: 0xF35588)
        case .approve:
            self.statusBtn.setTitle("已通过", for: .normal)
            self.statusBtn.backgroundColor = UIColor(hex: 0x64C18B)
        case .reject:
            self.statusBtn.setTitle("已退回", for: .normal)
            self.statusBtn.backgroundColor = UIColor(hex: 0xF35588)
        case .aiReview:
            self.statusBtn.setTitle("AI审核中", for: .normal)
            self.statusBtn.backgroundColor = UIColor(hex: 0xFEA958)
            timeLab.text = "已审核" + chapter.ai_time!
            timeLab.isHidden = false
        }
    }
}
