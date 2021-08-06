//
//  QWBestAuthorCVCell.swift
//  Qingwen
//
//  Created by Aimy on 11/11/15.
//  Copyright © 2015 iQing. All rights reserved.
//

import UIKit

class QWBestAuthorCVCell: QWBaseCVCell {

    @IBOutlet var leftImage: UIImageView!
    @IBOutlet var leftLabel: UILabel!
    @IBOutlet var leftDetailLabel: UILabel!
    @IBOutlet var middleImage: UIImageView!
    @IBOutlet var middleLabel: UILabel!
    @IBOutlet var middleDetailLabel: UILabel!
    @IBOutlet var rightImage: UIImageView!
    @IBOutlet var rightLabel: UILabel!
    @IBOutlet var rightDetailLabel: UILabel!

    var items: [UserVO]?

    override func awakeFromNib() {
        super.awakeFromNib()

        self.placeholder = UIImage(named: "mycenter_logo")

        self.leftImage.layer.borderWidth = PX1_LINE
        self.leftImage.bk_tapped { () -> Void in
            self.gotoUserDetailWithIndex(0)
        }
        self.middleImage.layer.borderWidth = PX1_LINE
        self.middleImage.bk_tapped { () -> Void in
            self.gotoUserDetailWithIndex(1)
        }
        self.rightImage.layer.borderWidth = PX1_LINE
        self.rightImage.bk_tapped { () -> Void in
            self.gotoUserDetailWithIndex(2)
        }
    }

    func updateWithItems(_ items: [UserVO]) {
        self.items = items

        for index in 0..<items.count {
            let user = self.items![index]
            if index == 0 {
                self.leftImage.qw_setImageUrlString(QWConvertImageString.convertPicURL(user.avatar, imageSizeType: .avatarThumbnail), placeholder: self.placeholder, cornerRadius: 25, borderWidth: 0, borderColor: UIColor.clear, animation: true, complete: nil)
                if let coin = user.coin {
                    self.leftDetailLabel.text = "\(coin)轻石"
                }
                else {
                    self.leftDetailLabel.text = "0"
                }
                self.leftLabel.text = user.username
            }
            else if index == 1 {
                self.middleImage.qw_setImageUrlString(QWConvertImageString.convertPicURL(user.avatar, imageSizeType: .avatarThumbnail), placeholder: self.placeholder, cornerRadius: 25, borderWidth: 0, borderColor: UIColor.clear, animation: true, complete: nil)
                if let coin = user.coin {
                    self.middleDetailLabel.text = "\(coin)轻石"
                }
                else {
                    self.middleDetailLabel.text = "0"
                }
                self.middleLabel.text = user.username

            }
            else {
                self.rightImage.qw_setImageUrlString(QWConvertImageString.convertPicURL(user.avatar, imageSizeType: .avatarThumbnail), placeholder: self.placeholder, cornerRadius: 25, borderWidth: 0, borderColor: UIColor.clear, animation: true, complete: nil)
                if let coin = user.coin {
                    self.rightDetailLabel.text = "\(coin)轻石"
                }
                else {
                    self.rightDetailLabel.text = "0"
                }
                self.rightLabel.text = user.username
            }
        }
    }

    func gotoUserDetailWithIndex(_ index: Int) {
        if let items = self.items {
            let user = items[index]
            var params = [String: String]()
            params["profile_url"] = user.profile_url
            params["username"] = user.username
            if let sex = user.sex {
                params["sex"] = sex.stringValue
            }

            if let avatar = user.avatar {
                params["avatar"] = avatar
            }

            QWRouter.sharedInstance().router(withUrlString: NSString.getRouterVCUrlString(fromUrlString: "user", andParams: params))
        }
    }
}
