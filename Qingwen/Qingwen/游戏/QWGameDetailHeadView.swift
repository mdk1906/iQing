//
//  QWGameDetailHeadView.swift
//  Qingwen
//
//  Created by Aimy on 5/17/16.
//  Copyright © 2016 iQing. All rights reserved.
//

import UIKit

@objc
protocol QWGameDetailHeadViewDelegate : NSObjectProtocol {

}

class QWGameDetailHeadView: UIView {

    weak var delegate: QWGameDetailHeadViewDelegate?

    @IBOutlet var combatLabel: UILabel!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var countBtn: UIButton!

    @IBOutlet weak var bookNameLbl: UILabel!
    @IBOutlet var categoryBtns: [UIButton]!
    
    @IBOutlet weak var bookCoverImage: UIImageView!
    @IBOutlet weak var payBtn: UIButton!
    
    func updateWithBook(_ book: BookVO) {
        if let name = book.title {
            self.bookNameLbl.text = name
            let size = self.getSizeWithWidth(self.bookNameLbl.frame.size.width - 20, textString: name)
            if  size.height > self.bookNameLbl.frame.size.height{
                self.bookNameLbl.isUserInteractionEnabled = true
                self.bookNameLbl.bk_(whenTapped: { 
                    self.showToast(withTitle: name, subtitle: nil, type: .alert)
                })
            }else {
                self.bookNameLbl.isUserInteractionEnabled = false;
            }
            
        }else {
            self.bookNameLbl.text = ""
        }
        
        if let imageCover = book.cover {
            self.bookCoverImage.qw_setImageUrlString(QWConvertImageString.convertPicURL(imageCover, imageSizeType: .gameCover), placeholder: nil, animation: true)
        }
        
        if let belief = book.belief, let combat = book.combat {
            self.combatLabel.text = "信仰:\(QWHelper.count(toShortString: belief)!)  战力:\(QWHelper.count(toShortString: combat)!)"
        }
        if let categories = book.categories, categories.count > 0 {
            for (idx, btn) in self.categoryBtns.enumerated() {
                if idx < categories.count {
                    let itemVO = categories[idx] as! CategoryItemVO
                    btn.setTitle(" \(itemVO.name!) ", for: .normal)
                    btn.isHidden = false
                } else {
                    btn.isHidden = true
                }
            }
        } else {
            self.categoryBtns[0].setTitle(" 演绘 ", for: .normal)
            self.categoryBtns[0].isHidden = false
        }
        if let updated_time = book.updated_time {
            self.timeLabel.text = "更新时间: \(QWHelper.shortDate1(toString: updated_time)!)"
        }
        else {
            self.timeLabel.text = " "
        }

        if let sceneCount = book.scene_count ,sceneCount.intValue > 0{
            self.countBtn.setTitle(" \(sceneCount)章 ", for: .normal)
            self.countBtn.isHidden = false
        }
        else {
            self.countBtn.isHidden = true
        }
        if(book.discount != nil){
            self.addPayingBtn(discount: book.discount!.intValue);
        }
        
    }

    @IBAction func onPressedCategoryBtn(_ sender: UIButton) {
        var params = [String: Any]()
        params["tags"] = [[1, "战力"]]
        params["order"] =  1
        params["title"] = "演绘库"
        QWRouter.sharedInstance().router(withUrlString: NSString.getRouterVCUrlString(fromUrlString: "gamelibrary", andParams: params))
    }
    @IBAction func onPressedPriceBtn(_ sender: AnyObject) {
        
    }
    
    func addPayingBtn(discount:Int) {
        if (discount > 0) {
            switch (discount) {
            case 0:
                self.payBtn.setTitle("付费", for: .normal);
                self.payBtn.backgroundColor = UIColor(hex: 0xfa8490);
                self.payBtn.isHidden = false;
            break;
            case 100:
                self.payBtn.setTitle("限免", for: .normal);
                self.payBtn.backgroundColor = UIColor(hex: 0x6cc3c1);
                self.payBtn.isHidden = false;
            break;
            default:
                if(discount < 100){
                    let discountStr = String(format: "-%ld％", (100 - discount))
                    self.payBtn.setTitle(discountStr, for: .normal);
                    self.payBtn.backgroundColor = UIColor(hex: 0x6cc3c1);
                }else{
                    self.payBtn.setTitle("付费", for: .normal);
                    self.payBtn.backgroundColor = UIColor(hex: 0xfa8490);
                }
                    self.payBtn.isHidden = false;
            break;
            }
        }
        else {
            self.payBtn.isHidden = true;
        }
    }
}
