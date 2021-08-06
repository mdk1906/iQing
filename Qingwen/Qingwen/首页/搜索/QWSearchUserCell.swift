//
//  QWSearchUserCell.swift
//  Qingwen
//
//  Created by mumu on 2017/7/26.
//  Copyright © 2017年 iQing. All rights reserved.
//

import UIKit

class QWSearchUserCell: QWBaseTVCell {

    var change = false
    
    @IBOutlet var avatarImageView: UIImageView!
    
    @IBOutlet var namelabel: UILabel!
    
    @IBOutlet var sexImageView: UIImageView!
    @IBOutlet var introLabel: UILabel!
    @IBOutlet var fansLabel: UILabel!
    @IBOutlet var followLabel: UILabel!
    
    func updateCell(withUser vo: UserVO) {
        self.avatarImageView.qw_setImageUrlString(QWConvertImageString.convertPicURL(vo.avatar, imageSizeType: .avatar), placeholder: #imageLiteral(resourceName: "mycenter_logo"), animation: true)
        self.namelabel.text = vo.username
        self.introLabel.text = vo.signature
//        if let sex = vo.sex, sex.intValue == 1 {
//            self.sexImageView.image = UIImage(named: "sex1")
//        }else {
//            self.sexImageView.image = UIImage(named: "sex0")
//        }
        if let adorn_medal = vo.adorn_medal {
            self.sexImageView.qw_setImageUrlString(QWConvertImageString.convertPicURL(adorn_medal, imageSizeType: .none), placeholder: nil, animation: true)
        }
        if let fansCount = vo.fans_count {
            self.fansLabel.text = "关注他的人：\(String(describing: fansCount))"
        }
        if let followCount = vo.follow_count {
            self.followLabel.text = "他的关注：\(String(describing: followCount))"
        }
    }

}
