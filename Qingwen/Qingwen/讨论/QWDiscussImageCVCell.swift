//
//  QWDiscussImageCVCell.swift
//  Qingwen
//
//  Created by Aimy on 2/24/16.
//  Copyright © 2016 iQing. All rights reserved.
//

import UIKit

class QWDiscussImageCVCell: QWBaseCVCell {

    @IBOutlet var imageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.placeholder = UIImage(named: "placeholder2to1")
    }

    func updateWithImageUrl(_ url: String) {
        self.imageView.qw_setImageUrlString(QWConvertImageString.convertPicURL(url, imageSizeType: .multipreview), placeholder: self.placeholder, animation: true)
    }
}
