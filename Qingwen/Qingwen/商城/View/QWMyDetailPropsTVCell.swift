//
//  QWMyDetailPropsTVCell.swift
//  Qingwen
//
//  Created by mumu on 16/10/27.
//  Copyright © 2016年 iQing. All rights reserved.
//

import UIKit

class QWMyDetailPropsTVCell: QWBaseTVCell {
    
    @IBOutlet var ticketBgImageView: UIImageView!
    
    @IBOutlet var soureceLabel: UILabel!
    
    @IBOutlet var expireLabel: UILabel!
    @IBOutlet var applyLabel: UILabel!
    @IBOutlet var validLabel: UILabel!
    
    func update(singlePropsVO: SinglePropsVO) {
        if let source = singlePropsVO.source {
            self.soureceLabel.text = "来源: \(source)"
        }
        if let category = singlePropsVO.category {
            self.applyLabel.text = "适用范围: \(category)"
        }
        if let overdue_time = singlePropsVO.overdue_time, let used = singlePropsVO.is_used{
            self.validLabel.text = "有效期限: \(QWHelper.fullDate1(toString: overdue_time)!)"
            if used.boolValue {
                self.expireLabel.text = "已使用"
                self.ticketBgImageView.image = UIImage(named: "shop_book_offbg")
            } else {
                if overdue_time < Date(){
                    self.expireLabel.text = "已过期"
                    self.ticketBgImageView.image = UIImage(named: "shop_book_offbg")
                } else if overdue_time.isToday() || overdue_time.daysBeforeNow() == 0{
                    self.expireLabel.text = "即将过期"
                    self.ticketBgImageView.image = UIImage(named: "shop_book_onbg")
                } else {
                    let days = overdue_time.daysBeforeNow()
                    self.expireLabel.text = "还有\(days)天过期"
                    self.ticketBgImageView.image = UIImage(named: "shop_book_onbg")
                }
            }
        }
    }
}
