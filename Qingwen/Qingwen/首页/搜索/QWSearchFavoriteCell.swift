//
//  QWSearchFavoriteCell.swift
//  Qingwen
//
//  Created by wei lu on 8/02/18.
//  Copyright © 2018 iQing. All rights reserved.
//

import UIKit

class QWFavoriteCell: QWBaseTVCell {
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setUpViews()
    }
    
    
    var change = false
    
    var coverImage: UIImageView = {
        let view = UIImageView()
        view.cornerRadius = 6.0
        view.clipsToBounds = true
        return view
    }()
    
    
    var countLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 11.0)
        label.contentMode = .center
        label.textAlignment = .center
        label.textColor = UIColor(hex: 0x695047)
        label.backgroundColor = UIColor.white
        label.cornerRadius = 6.0
        label.clipsToBounds = true
        return label
    }()
    
    var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 15.0)
        label.contentMode = .left
        label.textAlignment = .left
        label.textColor = UIColor(hex: 0x505050)
        
    
        return label
    }()
    
    var author = UILabel()
    var belief = UILabel()
    var power = UILabel()
    
    func setUpViews(){
        let tags:[UILabel] = [author,belief,power]
        for label in tags{
            label.font = UIFont.boldSystemFont(ofSize: 11.0)
            label.contentMode = .left
            label.textAlignment = .left
            label.textColor = UIColor(hex: 0x9c9c9c)
        }
        self.contentView.addSubview(self.countLabel)
        self.contentView.addSubview(self.coverImage)
        
        self.contentView.addSubview(self.titleLabel)
        self.contentView.addSubview(self.author)
        self.contentView.addSubview(self.belief)
        self.contentView.addSubview(self.power)
        
        self.coverImage.autoPinEdge(.left, to: .left, of:self.contentView ,withOffset:12)
        self.coverImage.autoPinEdge(.top, to: .top, of:self.contentView ,withOffset:12)
        self.coverImage.autoSetDimension(.height, toSize: 94)
        self.coverImage.autoSetDimension(.width, toSize: 94)

        self.countLabel.autoPinEdge(.top, to: .bottom, of: self.coverImage,withOffset:-6.0)
        self.countLabel.autoPinEdge(.left, to: .left, of: self.coverImage)
        self.countLabel.autoPinEdge(.right, to: .right, of: self.coverImage)
        self.countLabel.autoSetDimension(.height, toSize: 145/5)
        
        self.titleLabel.autoPinEdge(.top, to: .top, of:self.coverImage,withOffset:12)
        self.titleLabel.autoPinEdge(.left, to: .right, of:self.coverImage ,withOffset:10)
        self.titleLabel.autoPinEdge(.right, to: .right, of:self.contentView ,withOffset:-12)
        
        self.author.autoPinEdge(.left, to: .left, of:self.titleLabel)
        self.author.autoPinEdge(.top, to: .bottom, of:self.titleLabel,withOffset:10)
        self.author.autoPinEdge(.right, to: .right, of:self.contentView,withOffset:12)
        
        self.belief.autoPinEdge(.left, to: .left, of:self.titleLabel)
        self.belief.autoPinEdge(.top, to: .bottom, of:self.author,withOffset:5)
        self.belief.autoPinEdge(.right, to: .right, of:self.contentView,withOffset:12)
        
        self.power.autoPinEdge(.left, to: .left, of:self.titleLabel)
        self.power.autoPinEdge(.top, to: .bottom, of:self.belief,withOffset:5)
        self.power.autoPinEdge(.right, to: .right, of:self.contentView,withOffset:12)
    }
    
    func updateCell(withFavorite vo: FavoriteBooksVO) {
        MultipleImagesToolsAsset.multipleImagesSetUrl(groupUrls: vo.cover!, defaultImage: self.placeholder, animation: true, completeHandle: { (photos) in
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
        self.countLabel.text = "共" + vo.work_count!.stringValue + "部"
        self.titleLabel.text = vo.title
        self.author.text = "作者: " + vo.user!.username!
        self.belief.text = "信仰: " + vo.belief!.stringValue
        self.power.text = "战力: " + vo.combat!.stringValue
    }
    
}
