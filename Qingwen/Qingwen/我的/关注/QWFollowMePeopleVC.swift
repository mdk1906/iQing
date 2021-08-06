//
//  QWFollowMePeopleVC.swift
//  Qingwen
//
//  Created by Aimy on 10/12/15.
//  Copyright © 2015 iQing. All rights reserved.
//

import UIKit

class QWFollowMePeopleVC: QWAttentionVC {

    override var attentionUrl: String? {
        return QWGlobalValue.sharedInstance().user?.fan_url
    }

    override func updateWithTVCell(_ cell: QWBaseTVCell, indexPath: IndexPath) {
        super.updateWithTVCell(cell, indexPath: indexPath)
    }
}
