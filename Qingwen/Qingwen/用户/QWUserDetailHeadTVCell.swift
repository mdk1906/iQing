//
//  QWUserDetailHeadTVCell.swift
//  Qingwen
//
//  Created by Aimy on 10/23/15.
//  Copyright © 2015 iQing. All rights reserved.
//

import UIKit

class QWUserDetailHeadTVCell: QWBaseTVCell {

    @IBOutlet var userImageView: UIImageView!
    @IBOutlet var usernameLabel: UILabel!
    @IBOutlet var birthdayLabel: UILabel!
    @IBOutlet var signLabel: UILabel!
    @IBOutlet var sexImageView: UIImageView!

    var user: UserVO?

    override func awakeFromNib() {
        super.awakeFromNib()

        self.userImageView.layer.masksToBounds = true
        self.userImageView.layer.cornerRadius = 50

        self.placeholder = UIImage(named: "mycenter_logo2")

        self.userImageView.bk_tapped { [weak self] () -> Void in
            if let weakSelf = self {
                if let avatar = weakSelf.user?.avatar {
                    var params = [String: AnyObject]()
                    var avatarArray = [String]()
                    avatarArray.append(avatar)
                    params["pictures"] = avatarArray as AnyObject?
                    QWRouter.sharedInstance().router(withUrlString: NSString.getRouterVCUrlString(fromUrlString: "picture", andParams: params))
                }
            }
        }
    }

    func updateWithUserVO(_ user: UserVO?) {
        self.user = user
        
        self.userImageView.qw_setImageUrlString(QWConvertImageString.convertPicURL(user?.avatar, imageSizeType: QWImageSizeType.avatar), placeholder: self.placeholder, animation: true)

        if let username = user?.username {
            let attribuatedString = NSMutableAttributedString(string: username, attributes: [NSForegroundColorAttributeName: UIColor(hex: 0x505050)!])
//            switch user?.sex {
//            case let x where x == 1:
//                self.sexImageView.image = UIImage(named: "sex1")
//                break
//            case let x where x == 2:
//                self.sexImageView.image = UIImage(named: "sex0")
//                break
//            default:
//                break
//            }
            if let adorn_medal = user?.adorn_medal {
                self.sexImageView.qw_setImageUrlString(QWConvertImageString.convertPicURL(adorn_medal, imageSizeType: .none), placeholder: nil, animation: true)
            }
            self.usernameLabel.attributedText = attribuatedString
        }

        let dateFormatter = DateFormatter();
        dateFormatter.dateFormat = "yyyy年MM月dd日"
        if let birthday = user?.birth_day {
            self.birthdayLabel.text = dateFormatter.string(from: birthday)
        }
        else {
            self.birthdayLabel.text = nil
        }

        self.signLabel.text = user?.signature
    }
}
