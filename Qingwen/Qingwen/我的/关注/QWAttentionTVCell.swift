//
//  QWAttentionTVCell.swift
//  Qingwen
//
//  Created by Aimy on 10/14/15.
//  Copyright © 2015 iQing. All rights reserved.
//

import UIKit

class QWAttentionTVCell: QWBaseTVCell {

    @IBOutlet var userImageView: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var attentionCountLabel: UILabel!
    @IBOutlet var attentionBtn: UIButton?
    @IBOutlet var sexImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()

        self.placeholder = UIImage(named: "mycenter_logo")
    }

    func updateWithUser(_ user: UserVO) {
        self.userImageView.qw_setImageUrlString(QWConvertImageString.convertPicURL(user.avatar, imageSizeType: .avatarThumbnail), placeholder: self.placeholder, cornerRadius: 25, borderWidth: 0, borderColor: UIColor.clear, animation: true, complete: nil)

        self.nameLabel.text = user.username
        if let fans_count = user.fans_count {
            self.attentionCountLabel.text = "已有\(fans_count)人关注了TA"
        }
        else {
            self.attentionCountLabel.text = " "
        }

        if let embedUser = user.user {
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
}
