//
//  QWBestPromotionCVCell.swift
//  Qingwen
//
//  Created by Aimy on 12/7/15.
//  Copyright © 2015 iQing. All rights reserved.
//

import UIKit

class QWBestPromotionCVCell: QWBaseCVCell {

    @IBOutlet var imageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.placeholder = UIImage(named: "placeholder2to1")
    }

    func updateWithPromotion(_ promotion: PromotionVO) {
        self.imageView.qw_setImageUrlString(QWConvertImageString.convertPicURL(promotion.cover, imageSizeType: QWImageSizeType.promotion), placeholder: self.placeholder, animation:true)
    }
}
