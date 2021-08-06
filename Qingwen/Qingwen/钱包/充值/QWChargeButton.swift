//
//  QWChargeButton.swift
//  Qingwen
//
//  Created by Aimy on 3/17/16.
//  Copyright © 2016 iQing. All rights reserved.
//

import UIKit

class QWChargeButton: UIControl {

    @IBOutlet var priceBtn: UIButton!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var subtitleLabel: UILabel!
    var thirdLab:UILabel!
    override var isSelected: Bool {
        didSet {
            self.priceBtn.isSelected = isSelected
            self.titleLabel.isHighlighted = isSelected
            self.subtitleLabel.isHighlighted = isSelected
            self.thirdLab.isHighlighted = isSelected
            if isSelected {
                self.layer.borderColor = UIColor(hex: 0xfB83ac)?.cgColor
            }
            else {
                self.layer.borderColor = UIColor(hex: 0x505050)?.cgColor
            }
        }
    }
    
    func updateWithProduct(_ product: ProductVO?) {
//        self.titleLabel.frame = CGRect(x:0,y:34-14,width:self.bounds.size.width,height:16)
//        self.subtitleLabel.frame = CGRect(x:0,y:52-14,width:self.bounds.size.width,height:16)
        thirdLab = UILabel.init()
        thirdLab.frame =  CGRect(x:0,y:self.bounds.size.height-50,width:self.bounds.size.width,height:16)
        thirdLab.textAlignment = .center
        thirdLab.font = UIFont.systemFont(ofSize: 11)
        thirdLab.textColor = UIColor.color33()
        thirdLab.highlightedTextColor = UIColor.colorQWPink()
        self.addSubview(thirdLab)
        if let product = product {
            self.isUserInteractionEnabled = true
            self.priceBtn.setTitle("\(product.currency!)元", for: UIControlState())
            self.thirdLab.text = "\(product.gold!)重石"
            self.titleLabel.text = "送\(product.bonus!)轻石"
            if product.vip_bonus == "0"{
                self.subtitleLabel.isHidden = true
            }else{
                self.subtitleLabel.text = "VIP再送\(product.vip_bonus!)轻石"
            }
            
        }
        else {
            self.isUserInteractionEnabled = false
            self.priceBtn.setTitle(" ", for: UIControlState())
            self.titleLabel.text = " "
            self.subtitleLabel.text = " "
            self.thirdLab.text = " "
        }
    }
    
    func updateWithProductWithoutCoin(_  product: ProductVO?) {
        if let product = product {
            self.isUserInteractionEnabled = true
            self.priceBtn.setTitle("\(product.currency!)元", for: UIControlState())
            self.thirdLab.text = "\(product.gold!)重石"
            self.subtitleLabel.text = "  "
            self.titleLabel.text = "  "
        }
        else {
            self.isUserInteractionEnabled = false
            self.priceBtn.setTitle(" ", for: UIControlState())
            self.titleLabel.text = " "
            self.subtitleLabel.text = " "
            self.thirdLab.text = " "
        }
    }
}
