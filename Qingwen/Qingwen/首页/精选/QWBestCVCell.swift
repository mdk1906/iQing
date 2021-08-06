//
//  QWBestCVCell.swift
//  Qingwen
//
//  Created by Aimy on 10/13/15.
//  Copyright © 2015 iQing. All rights reserved.
//

class QWBestCVCell: QWListCVCell {
    
    
    @IBOutlet var recommendBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()

        self.imageView.layer.borderWidth = 0
        self.imageView.layer.borderColor = nil

        self.clipsToBounds = false
        self.layer.masksToBounds = false
        self.contentView.clipsToBounds = false
        self.contentView.layer.masksToBounds = false
    }
    //1:1
    func updateWithBestItem(_ bestItem: BestItemVO) {

        imageView.qw_setImageUrlString(QWConvertImageString.convertPicURL(bestItem.cover, imageSizeType: QWImageSizeType.recommend), placeholder: self.placeholder, animation: true)
        if let work = bestItem.work {
            titleLabel.attributedText = QWHelper.attributedString(withText: bestItem.title, image:work.cornerImage)
        }
    }
    //3:4 分区推荐是 3:4的
    func updateWithBestItem1(_ bestItem: BestItemVO) {
        if QWLocalPictures.sharedInstance.needMask, let _ = bestItem.cover {
            
             imageView.qw_setImageUrlString(QWConvertImageString.convertPicURL(bestItem.cover, imageSizeType: QWImageSizeType.cover), placeholder: self.placeholder, animation: true)
        } else  {
            let cover = bestItem.work?.cover
//            imageView.qw_setImageUrlString(QWConvertImageString.convertPicURL(bestItem.cover, imageSizeType: QWImageSizeType.cover), placeholder: self.placeholder, animation: true)
            imageView.qw_setImageUrlString(QWConvertImageString.convertPicURL(cover, imageSizeType: QWImageSizeType.cover), placeholder: self.placeholder, animation: true)
        }
        
        if let url = bestItem.url , url.contains("recommend") {
            self.recommendBtn.isHidden = false
            self.recommendBtn.setBackgroundImage(UIImage(named: "list_recommend_bg"), for: UIControlState())
        }else {
            self.recommendBtn.isHidden = true
        }
        
        if let work = bestItem.work {
            self.titleLabel.attributedText = QWHelper.attributedString(withText: bestItem.title, image: work.cornerImage)
            self.countBtn?.setTitle(work.topRightCornerTitle(), for: UIControlState.normal)
            self.countBtn?.setBackgroundImage(work.topRightCornerImage(), for: .normal)
            if work.is_vip == "1"{
                self.countBtn?.isHidden = false
                self.countBtn?.setBackgroundImage(work.vipImg(), for: .normal)
                
                self.countBtn?.setTitle("VIP", for: .normal)
            }
            if work.channel == 14{
                self.countBtn?.isHidden = true
            }
        }
    }
}
