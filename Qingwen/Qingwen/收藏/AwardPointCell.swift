//
//  AwardPointCell.swift
//  Qingwen
//
//  Created by wei lu on 8/02/18.
//  Copyright © 2018 iQing. All rights reserved.
//

import UIKit

class QWAwardPointCell: QWBaseTVCell {
    var empty:Bool = false
    
    var avatarImage: UIImageView = {
        let view = UIImageView()
        view.cornerRadius = 20
        view.clipsToBounds = true
        return view
    }()
    
    var sexImage: UIImageView = {
        let view = UIImageView()
        return view
    }()
    
    var userNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15.0)
        label.contentMode = .left
        label.textAlignment = .left
        label.textColor = UIColor(hex: 0x505050)
        return label
    }()
    
    var awardLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14.0)
        label.textAlignment = .right
        label.textColor = UIColor(hex: 0x505050)
        return label
    }()
    
    var indexImage: UIImageView = {
        let view = UIImageView()
        return view
    }()
    
    var emptyView:UILabel = {
        let label = UILabel()
        label.text = "暂无投石动态"
        label.font = UIFont.systemFont(ofSize: 15.0)
        label.textColor = UIColor(hex: 0x505050)
        label.alpha = 0
        return label
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: "awardDetials")
        self.setUpViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setUpViews(){
        self.contentView.addSubview(self.emptyView)
        self.contentView.addSubview(self.avatarImage)
        self.contentView.addSubview(self.sexImage)
        self.contentView.addSubview(self.userNameLabel)
        self.contentView.addSubview(self.awardLabel)
        self.placeholder = UIImage(named: "mycenter_logo")
        self.avatarImage.autoAlignAxis(toSuperviewAxis: .horizontal)
        self.avatarImage.autoPinEdge(.left, to: .left, of: self.contentView,withOffset:8.0)
        self.avatarImage.autoMatch(.width, to: .height, of: self.avatarImage, withMultiplier: 1)
        self.avatarImage.autoSetDimension(.height, toSize: 40.0)
        
        self.sexImage.autoMatch(.width, to: .height, of: self.sexImage, withMultiplier: 1)
        self.sexImage.autoMatch(.width, to: .height, of: self.avatarImage, withMultiplier: 48/120)
        self.sexImage.autoPinEdge(.right, to: .right, of: self.avatarImage)
        self.sexImage.autoPinEdge(.bottom, to: .bottom, of: self.avatarImage)
        
        self.awardLabel.autoAlignAxis(toSuperviewAxis: .horizontal)
        self.awardLabel.autoPinEdge(.right, to: .right, of: self.contentView, withOffset: -10)
        //self.awardLabel.autoPinEdge(.left, to: .right, of: self.userNameLabel, withOffset: 10)
        
        self.userNameLabel.autoAlignAxis(toSuperviewAxis: .horizontal)
        self.userNameLabel.autoPinEdge(.left, to: .right, of: self.avatarImage ,withOffset: 10)
        self.userNameLabel.autoPinEdge(.right, to: .left, of: self.awardLabel,withOffset: -10)

        self.emptyView.autoAlignAxis(toSuperviewAxis: .horizontal)
        self.emptyView.autoAlignAxis(toSuperviewAxis: .vertical)
    }
    
    func showEmptyView(){
        if self.empty == true {
            self.emptyView.alpha = 1
        }else{
            self.emptyView.alpha = 0
        }
    }
    
    func updateWithUserCoin(_ user: UserVO) {
        if let count = user.coin {
            self.awardLabel.text = "\(count)轻石"
        }
        else {
            self.awardLabel.text = " "
        }
    }
    
    func updateWithUserGold(_ user: UserVO) {
        if let count = user.gold {
            self.awardLabel.text = "\(count)重石"
        }
        else {
            self.awardLabel.text = " "
        }
    }
    
    //订阅动态
    func updateWithSubscriber(_ user: UserVO) {
        if let userVO = user.user {
            if let name = userVO.username {
                self.userNameLabel.text = "\(name)订阅了本作品"
            } else {
                self.userNameLabel.text = ""
            }
            if let _ = user.created_time {
                self.awardLabel.text = ""
            } else {
                self.awardLabel.text = ""
            }
        }else {
            self.userNameLabel.text = ""
            self.awardLabel.text = ""
        }
        
    }
    
    //投石动态
    func updateAwardWithUserVO(_ user: UserVO) {
        if let userVO = user.user {
            if let name = userVO.username, let gold = user.gold {
                self.userNameLabel.text = "\(name)打赏\(gold)重石"
            } else {
                self.userNameLabel.text = ""
            }
            if let created_time = user.created_time {
                self.awardLabel.text = QWHelper.shortDate2(toString: created_time)
            } else {
                self.awardLabel.text = ""
            }
        }else {
            self.userNameLabel.text = ""
            self.awardLabel.text = ""
        }
        
    }
    
    func updateWithUser(_ user: UserVO) {
        if let embedUser = user.user {
            self.avatarImage.qw_setImageUrlString(QWConvertImageString.convertPicURL(embedUser.avatar, imageSizeType: .avatar), placeholder: self.placeholder, animation: true)
            //            self.nameLabel.text = embedUser.username
            
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
    
}
