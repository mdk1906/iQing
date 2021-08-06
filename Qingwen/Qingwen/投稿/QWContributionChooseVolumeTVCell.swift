//
//  QWContributionChooseVolumeTVCell.swift
//  Qingwen
//
//  Created by Aimy on 4/11/16.
//  Copyright © 2016 iQing. All rights reserved.
//

import UIKit

class QWContributionChooseVolumeTVCell: QWBaseTVCell {

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var selectedView: UIImageView!

    func updateWithVolume(_ volume: VolumeVO) {
        self.titleLabel.text = volume.title
    }
}
