//
//  QWBillTVCell.swift
//  Qingwen
//
//  Created by Aimy on 11/16/15.
//  Copyright © 2015 iQing. All rights reserved.
//

import UIKit

class QWBillTVCell: QWBaseTVCell {

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var updateLabel: UILabel!
    @IBOutlet var countLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        self.placeholder = UIImage(named: "mycenter_logo")
    }

    func updateWithBillVO(_ bill: BillVO) {
        self.titleLabel.text = bill.detail
        self.updateLabel.text = QWHelper.fullDate(toString: bill.updated_time)
        if let coin = bill.coin {
            if bill.receiver == QWGlobalValue.sharedInstance().user?.nid {
                self.countLabel.text = "+\(coin)轻石"
            }
            else {
                self.countLabel.text = "-\(coin)轻石"
            }
        }
        else {
            self.countLabel.text = "0轻石"
        }
    }
}
