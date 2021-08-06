//
//  QWShopingCVCell.swift
//  Qingwen
//
//  Created by mumu on 16/10/27.
//  Copyright © 2016年 iQing. All rights reserved.
//

import UIKit

@objc
protocol QWShopingCVCellDelegate: NSObjectProtocol {
    func onPressedBuyTicket(cell: QWBaseCVCell, goodsVO:GoodsVO) -> Void
}
class QWShopingCVCell: QWBaseCVCell {

    @IBOutlet var ticketImage: UIImageView!
    @IBOutlet var buyBtn: UIButton!
    @IBOutlet var priceLabel: UILabel!
    @IBOutlet var applyLabel: UILabel!
    @IBOutlet var periodLabel: UILabel!
    @IBOutlet var descriptionsLabel: UILabel!
    
    var goods: GoodsVO?
    weak var delegate: QWShopingCVCellDelegate?
    override func awakeFromNib() {
        
    }
    
    func update(goodsVO: GoodsVO) {
        self.goods = goodsVO
        if let icon = goodsVO.icon {
        self.ticketImage.qw_setImageUrlString(QWConvertImageString.convertPicURL(icon, imageSizeType: .cover), placeholder: UIImage(named: "shop_alert_ticket"), animation: false)
        }
        if let price = goodsVO.price, let price_type = goodsVO.price_type {
            if price_type == "轻石" {
                self.priceLabel.text = "价格: \(price)轻石 "
            } else if price_type == "重石" {
                self.priceLabel.text = "价格: \(price)重石 "
            } else {
                self.priceLabel.text = "价格: \(price)\(price_type) "
            }
        }else {
            self.priceLabel.text = "正在准备"
            self.buyBtn.backgroundColor = UIColor(hex: 0x505050)
            self.buyBtn.isEnabled = false
        }
        if let descriptions = goodsVO.descriptions {
            self.descriptionsLabel.text = "使用说明: \(descriptions)"
        }
        if let period = goodsVO.period {
            self.periodLabel.text = "有效期: \(period)天";
        }
    }
    @IBAction func onPressedBuyBtn(_ sender: UIButton) {
        guard let goods = goods else {
            return
        }
        self.delegate?.onPressedBuyTicket(cell: self, goodsVO: goods)
    }
}
