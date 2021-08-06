//
//  QWBookListCommentsCell.swift
//  Qingwen
//
//  Created by wei lu on 7/01/18.
//  Copyright © 2018 iQing. All rights reserved.
//


import UIKit

class QWBookListCommentsCell: QWBaseTVCell {
    
    @IBOutlet weak var authur_avatar: UIImageView!
    
    @IBOutlet weak var authur_sex: UIImageView!
    
    @IBOutlet weak var authur_name: UILabel!
    
    @IBOutlet weak var booklist_from: UILabel!
    
    @IBOutlet weak var comments: UILabel!
    
    var fav_id:Int?
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func updateWithVO(_ vo: BookCommentsVO) {
        self.authur_avatar.qw_setImageUrlString(QWConvertImageString.convertPicURL(vo.author!.avatar, imageSizeType: QWImageSizeType.avatar), placeholder: self.placeholder, cornerRadius: 20, borderWidth: 0, borderColor: UIColor.clear, animation: true, complete: nil)
//        if let sex = vo.author?.sex, sex.intValue == 1 {
//            self.authur_sex.image = UIImage(named: "sex1")
//        }else {
//            self.authur_sex.image = UIImage(named: "sex0")
//        }
        if let adorn_medal = vo.author?.adorn_medal {
            self.authur_sex.qw_setImageUrlString(QWConvertImageString.convertPicURL(adorn_medal, imageSizeType: .none), placeholder: nil, animation: true)
        }
        if let name = vo.author?.username{
            self.authur_name.text = name
        }
        self.booklist_from.text = "来自<<"+vo.favorite_title!+">>书单的推荐词"
        
        if let id = vo.favorite_id?.intValue{
            self.fav_id = id
        }
        
        self.comments.text = vo.recommend

    }
    

}

