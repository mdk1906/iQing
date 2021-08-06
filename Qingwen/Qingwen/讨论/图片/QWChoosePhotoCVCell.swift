//
//  QWChoosePhotoCVCell.swift
//  Qingwen
//
//  Created by Aimy on 2/22/16.
//  Copyright © 2016 iQing. All rights reserved.
//

import UIKit
import AssetsLibrary

class QWChoosePhotoCVCell: QWBaseCVCell {

    @IBOutlet var checkBtn: UIButton!
    @IBOutlet var imageView: UIImageView!

    func updateWithAsset(_ result: ALAsset,seletedImages images: [ALAsset]) {
        imageView.image = UIImage(cgImage: result.aspectRatioThumbnail().takeUnretainedValue())

        guard let url = result.value(forProperty: ALAssetPropertyAssetURL) as? URL else {
            checkBtn.isSelected = false
            return
        }

        if let _ = images.filter({ (selectedImage) -> Bool in
            guard let selectedUrl = selectedImage.value(forProperty: ALAssetPropertyAssetURL) as? URL else {
                return false
            }

            return selectedUrl == url
        }).first {
            checkBtn.isSelected = true
        }
        else {
            checkBtn.isSelected = false
        }
    }
}
