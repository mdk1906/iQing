//
//  QWBookListsTVCell.swift
//  Qingwen
//
//  Created by wei lu on 10/02/18.
//  Copyright © 2018 iQing. All rights reserved.
//
import UIKit
class QWBookListsTVCell: QWBaseTVCell {
    
    var coverImage: UIImageView = {
        let image = UIImageView()
        image.cornerRadius = 6.0
        image.clipsToBounds = true
        return image
    }()
    
    var bookCount: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 11)
        label.textColor = UIColor(hex:0x695047)
        label.backgroundColor = UIColor(hex:0xF4F4F4)
        label.textAlignment = .center
        return label
    }()
    
    var title: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 15)
        label.textColor = UIColor(hex:0x333333)
        label.textAlignment = .left
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
    
    lazy var intro: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 11)
        label.textColor = UIColor(hex:0x333333)
        label.textAlignment = .left
        
        label.numberOfLines = 0
        label.lineBreakMode = .byTruncatingTail
        label.sizeToFit()
        return label
    }()
    
    
//    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
//        super.init(style: style, reuseIdentifier: "cell")
//        self.setUpViews()
//    }
//    
//    required init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//        fatalError("init(coder:) has not been implemented")
//    }
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setUpViews()
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        intro.sizeToFit()
    }
    func setUpViews() {
        self.contentView.addSubview(self.coverImage)
        self.coverImage.addSubview(self.bookCount)
        self.contentView.addSubview(self.title)
        self.contentView.addSubview(self.intro)
        
        self.coverImage.autoPinEdge(.left, to: .left, of: self.contentView,withOffset:12)
        self.coverImage.autoAlignAxis(toSuperviewAxis: .horizontal)
        self.coverImage.autoSetDimension(.height, toSize: 94.0)
        self.coverImage.autoMatch(.width, to: .height, of: self.coverImage, withMultiplier: 4/3)
        
        self.bookCount.autoPinEdge(.bottom, to:.bottom, of: self.coverImage)
        self.bookCount.autoPinEdge(.left, to:.left, of: self.coverImage)
        self.bookCount.autoPinEdge(.right, to:.right, of: self.coverImage)
        self.bookCount.autoSetDimension(.height, toSize: 20.0)
        
        self.title.autoSetDimension(.height, toSize: 15.0)
        self.title.autoPinEdge(.left, to:.right, of: self.coverImage,withOffset:10)
        self.title.autoPinEdge(.right, to:.right, of: self.contentView,withOffset:-12)
        self.title.autoPinEdge(.top, to:.top, of: self.coverImage)
        
        self.intro.autoPinEdge(.top, to:.bottom, of: self.title,withOffset:5)
        self.intro.autoPinEdge(.left, to:.left, of: self.title)
        self.intro.autoPinEdge(.right, to:.right, of: self.contentView,withOffset:-12)
        self.intro.autoPinEdge(.bottom, to:.bottom, of: self.coverImage)
    }
    
    func updateWithFavItem(_ favItem: FavoriteBooksVO) {
        MultipleImagesToolsAsset.multipleImagesSetUrl(groupUrls: favItem.cover!, defaultImage: self.placeholder, animation: true, completeHandle: { (photos) in
            var imagesArray = [UIImageView]()
            if(photos.count < 3){
                let loopCnt = 3 - photos.count
                
                if(photos.count != 0){
                    for i in 0...photos.count-1 {
                        imagesArray.append(photos[i])
                    }
                }
                for _ in 0...loopCnt {
                    let defaultPic = UIImageView(image: UIImage(named: "default_fav"))
                    imagesArray.append(defaultPic)
                }
                self.coverImage.image = MultipleImagesToolsAsset.drawImages(imageArray: imagesArray, size: self.coverImage.frame.size,corner:true,count: 3, startX: 0, row: 1)
            }else{
                self.coverImage.image = MultipleImagesToolsAsset.drawImages(imageArray: photos, size: self.coverImage.frame.size,corner:true,count: 3, startX: 0, row: 1)
            }
            
        })
        
        if let titleContent = favItem.title {
            self.title.text = titleContent
        }
        
        if let countContent = favItem.work_count {
            self.bookCount.text = "共"+String(describing:countContent.intValue)+"部作品"
        }
        
        if let introContent = favItem.intro {
            self.intro.text = "简介："+introContent
            self.intro.sizeToFit()
        }
    }
}
