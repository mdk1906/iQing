//
//  QWGameDetailChargeTVCell.swift
//  Qingwen
//
//  Created by Aimy on 11/11/15.
//  Copyright © 2015 iQing. All rights reserved.
//

import UIKit

class QWGameDetailChargeTVCell: QWBaseTVCell {

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

    func updateWithUser(_ user: UserVO) {
        if let embedUser = user.user {
            self.userImageView.qw_setImageUrlString(QWConvertImageString.convertPicURL(embedUser.avatar, imageSizeType: .avatar), placeholder: self.placeholder, animation: true)
            self.nameLabel.text = embedUser.username

            switch embedUser.sex {
            case let x where x == 1:
                self.sexImageView.image = UIImage(named: "sex1")
                break
            case let x where x == 2:
                self.sexImageView.image = UIImage(named: "sex0")
                break
            default:
                break
            }
        }
        else {
            self.userImageView.qw_setImageUrlString(QWConvertImageString.convertPicURL(user.user?.avatar, imageSizeType: .avatar), placeholder: self.placeholder, animation: true)
            self.nameLabel.text = user.user?.username

            switch user.sex {
            case let x where x == 1:
                self.sexImageView.image = UIImage(named: "sex1")
                break
            case let x where x == 2:
                self.sexImageView.image = UIImage(named: "sex0")
                break
            default:
                break
            }
        }
    }
}
