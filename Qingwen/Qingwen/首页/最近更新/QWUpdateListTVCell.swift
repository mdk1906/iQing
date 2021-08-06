//
//  QWUpdateListTVCell.swift
//  Qingwen
//
//  Created by mumu on 16/11/14.
//  Copyright © 2016年 iQing. All rights reserved.
//

import UIKit

class QWUpdateListTVCell: QWListTVCell {
    
    override func prepareForReuse() {
        self.countBtn.isHidden = true
    }

    override func updateWithBookVO(_ book: BookVO) {
        
        self.bookImageView.qw_setImageUrlString(QWConvertImageString.convertPicURL(book.cover, imageSizeType: .coverThumbnail), placeholder: self.placeholder, animation: true)
            
        self.titleLabel.text = book.title
        
        if let faith = book.belief {
            self.goldLabel.text = "信仰: \(QWHelper.count(toShortString: faith)!)"
        }
        if let combat = book.combat {
            self.updateLabel.text = "战力: \(QWHelper.count(toShortString: combat)!)"
        }
        if let author_name = (book.author?.first as? UserVO)?.username {
            self.authorLabel.text = "作者: \(author_name)"
        }
        else {
            self.authorLabel.text = "作者: "
        }
        
        if let count = book.count, count.intValue > 0 {
            self.countBtn?.isHidden = false
            self.countBtn?.setTitle(book.topRightCornerTitle(), for: UIControlState.normal)
            self.countBtn?.setBackgroundImage(book.topRightCornerImage(), for: .normal)
        }
        
        if let sceneCount = book.scene_count, sceneCount.intValue > 0 {
            self.countBtn?.isHidden = false
            countBtn?.setTitle(" \(sceneCount)幕 ", for: .normal)
            countBtn?.setBackgroundImage(UIImage(named: "list_count_bg_3"), for: .normal)

        } else {

        }
        if book.is_vip == "1"{
            self.countBtn?.isHidden = false
                            self.countBtn?.setBackgroundImage(book.vipImg(), for: .normal)
            
                            self.countBtn?.setTitle(nil, for: .normal)
                        }
        
    }
    
}
