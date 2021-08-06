//
//  QWMyGoodsCVCell.swift
//  Qingwen
//
//  Created by mumu on 16/10/27.
//  Copyright © 2016年 iQing. All rights reserved.
//

import UIKit

class QWMyGoodsCVCell: QWBaseCVCell {
    
    @IBOutlet var ticketNameLabel: UILabel!
    @IBOutlet var ticketImage: UIImageView!
    @IBOutlet var countBtn: UIButton!
    @IBOutlet var applyLabel: UILabel!
    @IBOutlet var descriptionsLabel: UILabel!
    @IBOutlet var priceLabel: UILabel!
    
    func update(props: PropsVO) {
        if let goods = props.commodity{
            if let price = goods.price {
                self.priceLabel.text = "价格: \(price)轻石"
            }
            if let descriptions = goods.descriptions {
                self.descriptionsLabel.text = "使用说明: \(descriptions)"
            }
        }
        if let count = props.count {
            self.countBtn.setTitle("\(count)", for: .normal)
        } else {

            self.countBtn.isHidden = true
        }
        
    }
}
