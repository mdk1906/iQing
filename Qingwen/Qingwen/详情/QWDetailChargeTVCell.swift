//
//  QWDetailChargeTVCell.swift
//  Qingwen
//
//  Created by Aimy on 11/11/15.
//  Copyright © 2015 iQing. All rights reserved.
//

import UIKit

class QWDetailChargeTVCell: QWBaseTVCell {

    @IBOutlet var userImageView: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var chargeCountLabel: UILabel!
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
    
    //订阅动态
    func updateWithSubscriber(_ user: UserVO) {
        if let userVO = user.user {
            if let name = userVO.username {
                self.nameLabel.text = "\(name)订阅了本作品"
            } else {
                self.nameLabel.text = ""
            }
            if let _ = user.created_time {
                self.chargeCountLabel.text = ""
            } else {
                self.chargeCountLabel.text = ""
            }
        }else {
            self.nameLabel.text = ""
            self.chargeCountLabel.text = ""
        }
    
    }
    
    //投石动态
    func updateAwardWithUserVO(_ user: UserVO) {
        if let userVO = user.user {
            if let name = userVO.username, let gold = user.gold {
                self.nameLabel.text = "\(name)打赏\(gold)重石"
            } else {
                self.nameLabel.text = ""
            }
            if let created_time = user.created_time {
                self.chargeCountLabel.text = QWHelper.shortDate2(toString: created_time)
            } else {
                self.chargeCountLabel.text = ""
            }
        }else {
            self.nameLabel.text = ""
            self.chargeCountLabel.text = ""
        }
        
    }
    
    func updateWithUser(_ user: UserVO) {
        if let embedUser = user.user {
            self.userImageView.qw_setImageUrlString(QWConvertImageString.convertPicURL(embedUser.avatar, imageSizeType: .avatar), placeholder: self.placeholder, animation: true)
//            self.nameLabel.text = embedUser.username

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
            self.userImageView.qw_setImageUrlString(QWConvertImageString.convertPicURL(user.user?.avatar, imageSizeType: .avatar), placeholder: self.placeholder, animation: true)
            self.nameLabel.text = user.user?.username

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
            if let adorn_medal = user.user?.adorn_medal {
                self.sexImageView.qw_setImageUrlString(QWConvertImageString.convertPicURL(adorn_medal, imageSizeType: .none), placeholder: nil, animation: true)
            }
        }
    }
}
