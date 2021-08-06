//
//  QWListCVCell.swift
//  Qingwen
//
//  Created by Aimy on 10/13/15.
//  Copyright © 2015 iQing. All rights reserved.
//

import UIKit

class QWListCVCell: QWBaseCVCell {

    @IBOutlet var imageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var indexImageVIew: UIImageView?
    @IBOutlet var countBtn: UIButton?
    
    override func awakeFromNib() {
        super.awakeFromNib()

        self.placeholder = UIImage(named: "placeholder114x152")

        self.clipsToBounds = false
        self.layer.masksToBounds = false
        self.contentView.clipsToBounds = false
        self.contentView.layer.masksToBounds = false

        if SWIFT_IS_IPHONE_DEVICE {
            self.titleLabel.font = UIFont.systemFont(ofSize: 12)
        }
        else {
            self.titleLabel.font = UIFont.systemFont(ofSize: 14)
        }
    }

    override func prepareForReuse() {
        self.imageView.image = nil
        self.titleLabel.text = nil

    }

    func updateWithBookVO(_ book: BookVO) {
        self.imageView.qw_setImageUrlString(QWConvertImageString.convertPicURL(book.cover, imageSizeType: .coverThumbnail), placeholder: self.placeholder, animation: true)
        self.titleLabel.attributedText = QWHelper.attributedString(withText: book.title, image: book.cornerImage)
        if let count = book.count , count.intValue > 0 {
            self.countBtn?.isHidden = false
            self.countBtn?.setTitle("  \(QWHelper.count(toString: count)!)", for: UIControlState.normal)
            self.countBtn?.setBackgroundImage(UIImage(named: "list_count_bg"), for: .normal)
    }
        else {
            self.countBtn?.isHidden = true
        }
        if book.is_vip == "1"{
            self.countBtn?.isHidden = false
            self.countBtn?.setBackgroundImage(book.vipImg(), for: .normal)
            
            self.countBtn?.setTitle("VIP", for: .normal)
        }
    }
    func updateWithGameVO(_ game: BookVO) {
        
        self.imageView.qw_setImageUrlString(QWConvertImageString.convertPicURL(game.cover, imageSizeType: .cover), placeholder: self.placeholder, animation: true)
        self.titleLabel.attributedText = QWHelper.attributedString(withText: game.title, image: game.cornerImage)
        if let sceneCount = game.scene_count, sceneCount.intValue > 0 {
            self.countBtn?.setTitle(game.topRightCornerTitle(), for: UIControlState.normal)
            self.countBtn?.setBackgroundImage(game.topRightCornerImage(), for: .normal)
        }
        else {
            self.countBtn?.isHidden = true;
        }
    }
    func updateWithBookCD(_ book: BookCD) {
        let bookVO = book.toBookVO()
        self.imageView.qw_setImageUrlString(QWConvertImageString.convertPicURL(bookVO.cover, imageSizeType: .coverThumbnail), placeholder: self.placeholder, animation: true)
        self.titleLabel.attributedText = QWHelper.attributedString(withText: bookVO.title, image: bookVO.cornerImage)
        if let count = bookVO.count, count.intValue > 0 {
            self.countBtn?.isHidden = false
            self.countBtn?.setTitle(bookVO.topRightCornerTitle(), for: UIControlState.normal)
            self.countBtn?.setBackgroundImage(bookVO.topRightCornerImage(), for: .normal)
        }
        if bookVO.is_vip == "1"{
            self.countBtn?.isHidden = false
            self.countBtn?.setBackgroundImage(bookVO.vipImg(), for: .normal)
            
            self.countBtn?.setTitle("VIP", for: .normal)
        }
    }
    func updateWithGameCD(_ game: BookCD) {
        
        let gameVO = game.toBookVO()
        self.imageView.qw_setImageUrlString(QWConvertImageString.convertPicURL(gameVO.cover, imageSizeType: .cover), placeholder: self.placeholder, animation: true)
        self.titleLabel.attributedText = QWHelper.attributedString(withText: gameVO.title, image: gameVO.cornerImage)
        if let sceneCount = gameVO.scene_count, sceneCount.intValue > 0 {
            self.countBtn?.setTitle(gameVO.topRightCornerTitle(), for: UIControlState.normal)
            self.countBtn?.setBackgroundImage(gameVO.topRightCornerImage(), for: .normal)
        }
        
    }
    
    func updateWithIndexPath(_ indexPath: IndexPath) {
        switch (indexPath as NSIndexPath).row {
        case 0:
            self.indexImageVIew?.isHidden = false
            self.indexImageVIew?.image = UIImage(named: "best_top_1")
        case 1:
            self.indexImageVIew?.isHidden = false
            self.indexImageVIew?.image = UIImage(named: "best_top_2")
        case 2:
            self.indexImageVIew?.isHidden = false
            self.indexImageVIew?.image = UIImage(named: "best_top_3")
        case 3:
            self.indexImageVIew?.isHidden = false
            self.indexImageVIew?.image = UIImage(named: "best_top_4")
        default:
            self.indexImageVIew?.isHidden = true
        }
    }
}
