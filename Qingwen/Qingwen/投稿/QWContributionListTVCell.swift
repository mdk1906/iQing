//
//  QWContributionListCVCell.swift
//  Qingwen
//
//  Created by Aimy on 10/26/15.
//  Copyright © 2015 iQing. All rights reserved.
//

import UIKit

class QWContributionListTVCell: QWListTVCell {

    @IBOutlet var statusBtn: UIButton!
    
    @IBOutlet var volumeCountLabel: UILabel!

    func updateWithContributionVO(_ contribution: ContributionVO) {
//        super.updateWithBookVO(contribution.book)
        let book = contribution.book
        self.bookImageView .qw_setImageUrlString(QWConvertImageString.convertPicURL(book.cover, imageSizeType: .coverThumbnail), placeholder: self.placeholder, animation: true)
        self.countBtn?.isHidden = false
        
        self.countBtn?.setTitle("\(QWHelper.count(toShortString: book.count)!)字", for: UIControlState.normal)
        
        self.countBtn?.setBackgroundImage(UIImage(named: "list_count_bg"), for: .normal)
        self.volumeCountLabel.text = "共\(QWHelper.count(toShortString:book.volume_count)!)卷"
        self.titleLabel.text = book.title!
        self.combatLabel.text = "信仰：\(QWHelper.count(toShortString: book.belief)!)   战力：\(QWHelper.count(toShortString: book.combat)!)"
        self.updateLabel.text = "收藏：\(QWHelper.count(toShortString: book.follow_count)!)   点击：\(QWHelper.count(toShortString: book.views)!)"
        switch contribution.status {
        case .draft:
            self.statusBtn?.setBackgroundImage(UIImage(named: "contribution_bg_type0"), for: UIControlState())
            self.statusBtn?.setTitle("  草稿", for: UIControlState())
        case .inReview:
            self.statusBtn?.setBackgroundImage(UIImage(named: "contribution_bg_type2"), for: UIControlState())
            self.statusBtn?.setTitle("  审核中", for: UIControlState())
        case .partReview:
            self.statusBtn?.setBackgroundImage(UIImage(named: "contribution_bg_type3"), for: UIControlState())
            self.statusBtn?.setTitle("  部分通过", for: UIControlState())
        case .approve:
            self.statusBtn?.setBackgroundImage(UIImage(named: "contribution_bg_type3"), for: UIControlState())
            self.statusBtn?.setTitle("  审核通过", for: UIControlState())
        case .reject:
            self.statusBtn?.setBackgroundImage(UIImage(named: "contribution_bg_type1"), for: UIControlState())
            self.statusBtn?.setTitle("  退回", for: UIControlState())
        case .unReview:
            self.statusBtn?.setBackgroundImage(UIImage(named: "contribution_bg_type1"), for: UIControlState())
            self.statusBtn?.setTitle("  未通过", for: UIControlState())
        }
    }
}
