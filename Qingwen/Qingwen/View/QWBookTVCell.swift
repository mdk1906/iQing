//
//  QWBookTVCell.swift
//  Qingwen
//
//  Created by mumu on 17/3/29.
//  Copyright © 2017年 iQing. All rights reserved.
//

import UIKit

class QWBookTVCell: QWBaseTVCell {
    
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var beliefLabel: UILabel!
    @IBOutlet weak var combatLabel: UILabel!
    
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var indexImageView: UIImageView!
    @IBOutlet weak var countBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func updateWithVO(_ model: AnyObject) {
        if model is QWBookTVCellCogig {
            self.coverImageView.qw_setImageUrlString(QWConvertImageString.convertPicURL(model.coverImageString(), imageSizeType: QWImageSizeType.cover), placeholder: self.placeholder, animation: true)
            self.titleLabel.text = model.titleString()
            self.beliefLabel.text = model.beliefString()
            self.combatLabel.text = model.combatString()
            self.authorLabel.text = model.authorString()
            
            self.countBtn.setBackgroundImage(model.topCountbgImage(), for: .normal)
            
            self.countBtn.setTitle(model.countString(), for: .normal)
            if model.is_vip == "1"{
                self.countBtn.isHidden = false
                self.countBtn.setBackgroundImage(model.vipImg(), for: .normal)
                
                self.countBtn.setTitle("VIP", for: .normal)
            }
        }
    }
    
    func updateWithIndexPath(_ indexPath: IndexPath) {
        self.indexImageView.isHidden = false
        switch indexPath.section {
        case 0:
            self.indexImageView?.isHidden = false
            self.indexImageView?.image = UIImage(named: "best_top_1")
        case 1:
            self.indexImageView?.isHidden = false
            self.indexImageView?.image = UIImage(named: "best_top_2")
        case 2:
            self.indexImageView?.isHidden = false
            self.indexImageView?.image = UIImage(named: "best_top_3")
        case 3:
            self.indexImageView?.isHidden = false
            self.indexImageView?.image = UIImage(named: "best_top_4")
        default:
            self.indexImageView?.isHidden = true
        }
    }
}
