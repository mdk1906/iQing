//
//  QWSquarePromotionTVCell.swift
//  Qingwen
//
//  Created by mumu on 17/3/25.
//  Copyright © 2017年 iQing. All rights reserved.
//

import UIKit

class QWSquarePromotionTVCell: QWBaseTVCell {
    
    
    @IBOutlet weak var promotionImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.placeholder = UIImage(named: "placeholder2to1")
    }
    
    func updateWithPromotion(_ promotion: PromotionVO) {
        self.promotionImageView.qw_setImageUrlString(QWConvertImageString.convertPicURL(promotion.cover, imageSizeType: QWImageSizeType.promotion), placeholder: self.placeholder, animation:true)
    }
}
