//
//  QWBookListsCVCell.swift
//  Qingwen
//
//  Created by wei lu on 13/12/17.
//  Copyright © 2017 iQing. All rights reserved.
//

import UIKit
class QWBookListsCVCell: QWBaseCVCell {
    
    

    @IBOutlet var coverImage: UIImageView!
    @IBOutlet var bookCount: UILabel!
    @IBOutlet var title: UILabel!
    @IBOutlet var intro: UILabel!
    @IBOutlet var author: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.coverImage.layer.borderWidth = 0
        self.coverImage.layer.borderColor = nil
        self.coverImage.layer.cornerRadius = 6.0
        self.coverImage.clipsToBounds = true
        self.bookCount.layer.borderWidth = 0
        self.bookCount.layer.borderColor = nil

        self.bookCount.clipsToBounds = true
        
        self.clipsToBounds = false
        self.layer.masksToBounds = false
        self.contentView.clipsToBounds = false
        self.contentView.layer.masksToBounds = false
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
            self.intro.text = "简介：" + introContent
        }
        if let creatorName = favItem.user?.username {
            self.author.text = creatorName
        }
    }
}
