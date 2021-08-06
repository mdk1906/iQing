//
//  QWWalletBillTVCell.swift
//  Qingwen
//
//  Created by Aimy on 2/25/16.
//  Copyright © 2016 iQing. All rights reserved.
//

import UIKit

class QWWalletBillTVCell: QWBaseTVCell {

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var updateLabel: UILabel!
    @IBOutlet var countLabel: UILabel!

    @IBOutlet weak var detailLab: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()

        self.placeholder = UIImage(named: "mycenter_logo")      
    }

    func updateWithBillVO(_ bill: WalletBillVO) {
        self.titleLabel.text = bill.reason
        
//        self.updateLabel.text = QWHelper.fullDate(toString: bill.updated_time)
        if let money = bill.money {
            self.countLabel.text = "¥" + money
        }
        else {
            self.countLabel.text = "¥0"
        }
    }
}
