//
//  QWHeavyBillTVCell.swift
//  Qingwen
//
//  Created by Aimy on 3/21/16.
//  Copyright © 2016 iQing. All rights reserved.
//

import UIKit

class QWHeavyBillTVCell: QWBaseTVCell {

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var updateLabel: UILabel!
    @IBOutlet var countLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        self.placeholder = UIImage(named: "mycenter_logo")
    }

    func updateWithGoldBillVO(_ bill: GoldBillVO) {
        self.titleLabel.text = bill.reason
        self.updateLabel.text = QWHelper.fullDate(toString: bill.updated_time)
        if let gold = bill.gold {
            if gold.intValue > 0 {
                self.countLabel.text = "+\(gold)重石"
            }
            else {
                self.countLabel.text = "\(gold)重石"
            }
        }
        else {
            self.countLabel.text = "0重石"
        }
    }
}
