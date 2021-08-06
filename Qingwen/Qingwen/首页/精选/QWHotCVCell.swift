//
//  QWHotVCCell.swift
//  Qingwen
//
//  Created by mumu on 17/4/1.
//  Copyright © 2017年 iQing. All rights reserved.
//

import UIKit

class QWHotCVCell: QWBestCVCell {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.titleLabel.font = UIFont.systemFont(ofSize: 13)
    }
    
    @IBOutlet weak var introLabel: UILabel!
    
    override func updateWithBestItem1(_ bestItem: BestItemVO) {
        super.updateWithBestItem1(bestItem)
        if let recommendWords = bestItem.recommend_words {
            
//            introLabel.attributedText = recommendWords.pargraphAttribute()
//            introLabel.lineBreakMode = .byTruncatingTail
            introLabel.text = recommendWords
            titleLabel.text = bestItem.title
        }
    }
}
