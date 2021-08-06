//
//  QWSearchHistoryTVCell.swift
//  Qingwen
//
//  Created by Aimy on 12/14/15.
//  Copyright © 2015 iQing. All rights reserved.
//

import UIKit

class QWSearchHistoryTVCell: QWBaseTVCell {

    @IBOutlet var deleteHistoryBtn: UIButton!
    @IBOutlet var titleLabel: UILabel!
    
    func updateWithHistory(_ history: String) {
        self.titleLabel.text = history
    }

}
