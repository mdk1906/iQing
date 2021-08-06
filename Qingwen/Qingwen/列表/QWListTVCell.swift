//
//  QWListTVCell.swift
//  Qingwen
//
//  Created by Aimy on 10/13/15.
//  Copyright © 2015 iQing. All rights reserved.
//

class QWListTVCell: QWBaseTVCell {

    @IBOutlet var bookImageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var goldLabel: UILabel!
    @IBOutlet var authorLabel: UILabel!
    @IBOutlet var updateLabel: UILabel!
    @IBOutlet var indexImageVIew: UIImageView?
    @IBOutlet var countBtn: UIButton!
    
    @IBOutlet var combatLabel: UILabel! //战力
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func updateWithBookVO(_ book: BookVO) {
        self.bookImageView .qw_setImageUrlString(QWConvertImageString.convertPicURL(book.cover, imageSizeType: .coverThumbnail), placeholder: self.placeholder, animation: true)
        if let count = book.count, count.intValue > 0 {
            self.countBtn?.isHidden = false
            self.countBtn?.setTitle(book.topRightCornerTitle(), for: UIControlState.normal)
            self.countBtn?.setBackgroundImage(book.topRightCornerImage(), for: .normal)
        }
        if book.is_vip == "1"{
            self.countBtn?.isHidden = false
            self.countBtn?.setBackgroundImage(book.vipImg(), for: .normal)
            
            self.countBtn?.setTitle("VIP", for: .normal)
        }
        self.titleLabel.text = book.title

        if let author_name = (book.author?.first as? UserVO)?.username {
            self.authorLabel.text = "作者: \(author_name)"
        }
        else {
            self.authorLabel.text = "作者: "
        }

        if let gold = book.belief {
            if self.reuseIdentifier == "game" {
                self.goldLabel.text = "信仰: \(QWHelper.count(toShortString: gold)!)"
            }
            else {
                self.goldLabel.text = "信仰: \(QWHelper.count(toShortString: gold)!)"
            }
        }
        else {
            self.goldLabel.text = "信仰: 0"
        }
        
        if let gold = book.combat {
            self.updateLabel.text = "战力: \(QWHelper.count(toShortString: gold)!)"
        }
        else {
            self.updateLabel.text = "战力: 0"
        }
    }
    
    func updateWithGameVO(book: BookVO) {
        
        self.bookImageView .qw_setImageUrlString(QWConvertImageString.convertPicURL(book.cover, imageSizeType: .gameCover), placeholder: self.placeholder, animation: true)
        if let sceneCount = book.scene_count, sceneCount.intValue > 0 {
            self.countBtn?.isHidden = false
            countBtn?.setTitle(" \(sceneCount)章 ", for: .normal)
            countBtn?.setBackgroundImage(UIImage(named: "list_count_bg_3"), for: .normal)
        } else {
            countBtn.isHidden = true
        }
        if book.is_vip == "1"{
            self.countBtn?.isHidden = false
            self.countBtn?.setBackgroundImage(book.vipImg(), for: .normal)
            
            self.countBtn?.setTitle("VIP", for: .normal)
        }
        self.titleLabel.text = book.title
        
        if let author_name = (book.author?.first as? UserVO)?.username {
            self.authorLabel.text = "作者: \(author_name)"
        }
        else {
            self.authorLabel.text = "作者: "
        }
        
        if let gold = book.belief {
            if self.reuseIdentifier == "game" {
                self.goldLabel.text = "信仰: \(QWHelper.count(toShortString: gold)!)"
            }
            else {
                self.goldLabel.text = "信仰: \(QWHelper.count(toShortString: gold)!)"
            }
        }
        else {
            self.goldLabel.text = "信仰: 0"
        }
        
        if let gold = book.combat {
            self.updateLabel.text = "战力: \(QWHelper.count(toShortString: gold)!)"
        }
        else {
            self.updateLabel.text = "战力: 0"
        }
    }

    func updateWithBookCD(_ book: BookCD) {
        if self.reuseIdentifier == "game" {
            self.bookImageView .qw_setImageUrlString(QWConvertImageString.convertPicURL(book.cover, imageSizeType: .gameCover), placeholder: self.placeholder, animation: true)
        }
        else {
            self.bookImageView .qw_setImageUrlString(QWConvertImageString.convertPicURL(book.cover, imageSizeType: .coverThumbnail), placeholder: self.placeholder, animation: true)
        }

        self.titleLabel.text = book.title

        if let author_name = book.author_name {
            self.authorLabel.text = "作者: \(author_name)"
        }
        else {
            self.authorLabel.text = "作者: "
        }

        if let gold = book.gold {
            if self.reuseIdentifier == "game" {
                self.goldLabel.text = "重石: \(QWHelper.count(toShortString: gold)!)"
            }
            else {
                self.goldLabel.text = "重石: \(gold)"
            }
        }
        else {
            self.goldLabel.text = "重石: 0"
        }
        
        self.updateLabel.text = "更新: " + QWHelper.fullDate(toString: book.updated_time)
    }
// Section
    func updateWithIndexPath(_ indexPath: IndexPath) {
        switch (indexPath as NSIndexPath).section {
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
    
    func updateWithRow(_ indexPath: IndexPath) {
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
