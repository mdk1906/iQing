//
//  QWRecommendsBooksCVCell.swift
//  Qingwen
//
//  Created by wei lu on 12/12/17.
//  Copyright © 2017 iQing. All rights reserved.
//

import UIKit
class QWRecommendBooksCell: QWBaseCVCell {
    
  
    @IBOutlet var coverView: UIImageView!
    @IBOutlet var title: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.coverView.layer.borderWidth = 0
        self.coverView.layer.borderColor = nil

        self.clipsToBounds = false
        self.layer.masksToBounds = false
        self.contentView.clipsToBounds = false
        self.contentView.layer.masksToBounds = false
    }

    func updateWithRecommendItem(_ recommendItem: RecommendBooksVO) {
        self.coverView.qw_setImageUrlString(QWConvertImageString.convertPicURL(recommendItem.cover, imageSizeType: QWImageSizeType.recommend), placeholder: self.placeholder, animation: true)
        if let titleContent = recommendItem.title {
            self.title.text = titleContent
        }
    }
}
