//
//  QWDetailDynamicCVCell.swift
//  Qingwen
//
//  Created by mumu on 16/9/18.
//  Copyright © 2016年 iQing. All rights reserved.
//

import UIKit

class QWDetailLargeChargeCVCell: QWBaseCVCell {

    @IBOutlet var avatarImage: UIImageView!
    @IBOutlet var sexImage: UIImageView!
    @IBOutlet var userNameLabel: UILabel!
    @IBOutlet var indexImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.placeholder = UIImage(named: "mycenter_logo")
    }
    
    func updateChargeCellWithUserPageVO(_ user: UserVO) {
        if let embedUser = user.user {
            self.avatarImage.qw_setImageUrlString(QWConvertImageString.convertPicURL(embedUser.avatar, imageSizeType: .avatar), placeholder: self.placeholder, animation: true)
            self.userNameLabel.text = embedUser.username
            
//            switch embedUser.sex {
//            case let x where x == 1:
//                self.sexImage.image = UIImage(named: "sex1")
//                break
//            case let x where x == 2:
//                self.sexImage.image = UIImage(named: "sex0")
//                break
//            default:
//                break
//            }
            if let adorn_medal = embedUser.adorn_medal {
                self.sexImage.qw_setImageUrlString(QWConvertImageString.convertPicURL(adorn_medal, imageSizeType: .none), placeholder: nil, animation: true)
            }
        }
        else {
            self.avatarImage.qw_setImageUrlString(QWConvertImageString.convertPicURL(user.user?.avatar, imageSizeType: .avatar), placeholder: self.placeholder, animation: true)
            self.userNameLabel.text = user.user?.username
            
//            switch user.sex {
//            case let x where x == 1:
//                self.sexImage.image = UIImage(named: "sex1")
//                break
//            case let x where x == 2:
//                self.sexImage.image = UIImage(named: "sex0")
//                break
//            default:
//                break
//            }
            if let adorn_medal = user.user?.adorn_medal {
                self.sexImage.qw_setImageUrlString(QWConvertImageString.convertPicURL(adorn_medal, imageSizeType: .none), placeholder: nil, animation: true)
            }
        }
    }
    
    func updateWithUserFaith(_ indexPath: IndexPath) {
        switch (indexPath as NSIndexPath).row {
        case 0:
            self.indexImage.image = UIImage(named: "detail_faith_ssr")
        case 1:
            self.indexImage.image = UIImage(named: "detail_faith_sr")
        case 2,3,4:
            self.indexImage.image = UIImage(named: "detail_faith_ur")
        default:
            self.indexImage.isHidden = true

        }
    }

}
