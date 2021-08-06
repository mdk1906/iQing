//
//  QWUserListTVCell.swift
//  Qingwen
//
//  Created by Aimy on 11/13/15.
//  Copyright © 2015 iQing. All rights reserved.
//

import UIKit

class QWUserListTVCell: QWBaseTVCell {

    @IBOutlet var userImageView: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var countLabel: UILabel!
    @IBOutlet var chargeCountLabel: UILabel!
    @IBOutlet var indexImageVIew: UIImageView!
    @IBOutlet var sexImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()

        self.placeholder = UIImage(named: "mycenter_logo")
    }

    func updateWithUserCoin(_ user: UserVO) {
        if let count = user.coin {
            self.chargeCountLabel.text = "\(count)轻石"
        }
        else {
            self.chargeCountLabel.text = " "
        }
    }

    func updateWithUserGold(_ user: UserVO) {
        if let count = user.gold {
            self.chargeCountLabel.text = "\(count)重石"
        }
        else {
            self.chargeCountLabel.text = " "
        }
    }
    
    func updateWithUserFaith(_ user: UserVO) {
        if let count = user.points {
            self.chargeCountLabel.text = "\(count)信仰"
        }
        else {
            self.chargeCountLabel.text = " "
        }
    }
    func updateWithUser(_ user: UserVO) {
        if let embedUser = user.user {
            self.userImageView.qw_setImageUrlString(QWConvertImageString.convertPicURL(embedUser.avatar, imageSizeType: .avatar), placeholder: self.placeholder, animation: true)
            self.nameLabel.text = embedUser.username
            if let fans_count = embedUser.fans_count {
                self.countLabel.text = "已有\(fans_count)人关注了TA"
            }
            else {
                self.countLabel.text = " "
            }

//            switch embedUser.sex {
//            case let x where x == 1:
//                self.sexImageView.image = UIImage(named: "sex1")
//                break
//            case let x where x == 2:
//                self.sexImageView.image = UIImage(named: "sex0")
//                break
//            default:
//                break
//            }
            if let adorn_medal = embedUser.adorn_medal {
                self.sexImageView.qw_setImageUrlString(QWConvertImageString.convertPicURL(adorn_medal, imageSizeType: .none), placeholder: nil, animation: true)
            }
        }
        else {
            self.userImageView.qw_setImageUrlString(QWConvertImageString.convertPicURL(user.avatar, imageSizeType: .avatar), placeholder: self.placeholder, animation: true)
            self.nameLabel.text = user.username
            if let fans_count = user.fans_count {
                self.countLabel.text = "已有\(fans_count)人关注了TA"
            }
            else {
                self.countLabel.text = " "
            }

//            switch user.sex {
//            case let x where x == 1:
//                self.sexImageView.image = UIImage(named: "sex1")
//                break
//            case let x where x == 2:
//                self.sexImageView.image = UIImage(named: "sex0")
//                break
//            default:
//                break
//            }
            if let adorn_medal = user.adorn_medal {
                self.sexImageView.qw_setImageUrlString(QWConvertImageString.convertPicURL(adorn_medal, imageSizeType: .none), placeholder: nil, animation: true)
            }
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
