//
//  FaithPointUnit.swift
//  Qingwen
//
//  Created by wei lu on 7/02/18.
//  Copyright © 2018 iQing. All rights reserved.
//  之前的没法复用

import UIKit

class QWFaithPointUnitCell: QWBaseCVCell {
    
    var avatarImage: UIImageView = {
        let view = UIImageView()
        view.cornerRadius = 15
        view.clipsToBounds = true
      return view
    }()
    
    var sexImage: UIImageView = {
        let view = UIImageView()
        return view
    }()
    
    var userNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 11.0)
        label.contentMode = .left
        label.textAlignment = .center
        label.textColor = UIColor(hex: 0x505050)
        return label
    }()
    
    var indexImage: UIImageView = {
        let view = UIImageView()
        return view
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.placeholder = UIImage(named: "mycenter_logo")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setUpViews()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUpViews(){
        self.contentView.addSubview(self.avatarImage)
        self.contentView.addSubview(self.sexImage)
        self.contentView.addSubview(self.userNameLabel)
        self.contentView.addSubview(self.indexImage)
        
        self.avatarImage.autoAlignAxis(toSuperviewAxis: .vertical)
        self.avatarImage.autoMatch(.width, to: .height, of: self.avatarImage, withMultiplier: 1)
        self.avatarImage.autoPinEdge(.top, to: .top, of: self.contentView)
        self.avatarImage.autoSetDimension(.height, toSize: 30.0)
    
        self.sexImage.autoMatch(.width, to: .height, of: self.sexImage, withMultiplier: 1)
        self.sexImage.autoMatch(.width, to: .height, of: self.avatarImage, withMultiplier: 8/15)
        self.sexImage.autoPinEdge(.right, to: .right, of: self.avatarImage)
        self.sexImage.autoPinEdge(.bottom, to: .bottom, of: self.avatarImage)
        
        self.indexImage.autoMatch(.width, to: .height, of: self.indexImage, withMultiplier: 22/9)
        self.indexImage.autoSetDimension(.height, toSize: 9.0)
        self.indexImage.autoAlignAxis(toSuperviewAxis: .vertical)
        self.indexImage.autoPinEdge(.top, to: .bottom, of: self.sexImage, withOffset: 7)
        
        self.userNameLabel.autoPinEdge(.right, to: .right, of: self.contentView)
        self.userNameLabel.autoPinEdge(.left, to: .left, of: self.contentView)
        self.userNameLabel.autoPinEdge(.top, to: .bottom, of: self.indexImage, withOffset: 4)
    }
    
    func updateChargeCellWithUserPageVO(_ user: UserVO) {
        if let embedUser = user.user {
            self.avatarImage.qw_setImageUrlString(QWConvertImageString.convertPicURL(embedUser.avatar, imageSizeType: .avatar), placeholder: self.placeholder, animation: true)
            self.userNameLabel.text = embedUser.username
            
            switch embedUser.sex {
            case let x where x == 1:
                self.sexImage.image = UIImage(named: "sex1")
                break
            case let x where x == 2:
                self.sexImage.image = UIImage(named: "sex0")
                break
            default:
                break
            }
        }
        else {
            self.avatarImage.qw_setImageUrlString(QWConvertImageString.convertPicURL(user.user?.avatar, imageSizeType: .avatar), placeholder: self.placeholder, animation: true)
            self.userNameLabel.text = user.user?.username
            
            switch user.sex {
            case let x where x == 1:
                self.sexImage.image = UIImage(named: "sex1")
                break
            case let x where x == 2:
                self.sexImage.image = UIImage(named: "sex0")
                break
            default:
                break
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
