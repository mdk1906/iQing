//
//  QWMycenterHeaderCVCell.swift
//  Qingwen
//
//  Created by mumu on 16/10/26.
//  Copyright © 2016年 iQing. All rights reserved.
//

import UIKit

@objc
protocol QWMyCenterHeadCVCellDelegate: NSObjectProtocol {
    func headCell(cell: QWMyCenterHeadCVCell, sender:AnyObject) -> Void
}
class QWMyCenterHeadCVCell: QWBaseCVCell {

    @IBOutlet var userImageView: UIImageView!

    @IBOutlet var userNameLabel: UILabel!
    @IBOutlet var summonsBtn: UIButton!
    @IBOutlet var energyLabel: UILabel!
    @IBOutlet var sexImageView: UIImageView!
    
    @IBOutlet weak var signatureLabel: UILabel!
    @IBOutlet weak var uidLabel: UILabel!
    @IBOutlet weak var levelProgress: UIImageView!
    
    weak var  delegate: QWMyCenterHeadCVCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.userImageView.layer.cornerRadius = 80 / 2
        self.userImageView.layer.masksToBounds = true
    }
    
    func update() {
        if !QWGlobalValue.sharedInstance().isLogin() {
            self.userImageView.image = UIImage(named: "mycenter_not_login_user")
            return
        }
        
        self.userNameLabel.text = QWGlobalValue.sharedInstance().username
        if let user = QWGlobalValue.sharedInstance().user {
//            if let sex = user.sex, sex.intValue == 1 {
//                self.sexImageView.image = UIImage(named: "sex1")
//            }else {
//                self.sexImageView.image = UIImage(named: "sex0")
//            }
            if let adorn_medal = user.adorn_medal {
                self.sexImageView.qw_setImageUrlString(QWConvertImageString.convertPicURL(adorn_medal, imageSizeType: .none), placeholder: nil, animation: true)
            }
            if let coin = user.coin{
                self.energyLabel.text = "轻石: \(coin)"
            }
            if let signature = user.signature {
                self.signatureLabel.text = "签名: \(signature)"
            }
            if let uid = QWGlobalValue.sharedInstance().user?.level {
                self.uidLabel.text = uid
            }
            levelProgress.layer.cornerRadius = 4;
            levelProgress.layer.masksToBounds = true;
            if let levelexp = QWGlobalValue.sharedInstance().user?.level_exp, let exp = QWGlobalValue.sharedInstance().user?.exp{
                let pro:Double = Double(Double(exp)/Double(levelexp))
                let img = UIImageView.init()
                img.layer.cornerRadius = 4;
                img.layer.masksToBounds = true;
                img.frame = CGRect(x:0,y:0,width:CGFloat(pro)*levelProgress.bounds.size.width ,height:6)
                img.backgroundColor = UIColor.colorQWPink()
                levelProgress.addSubview(img)
            }
            
            
            
            
            if let avatar = user.avatar {
                self.userImageView.qw_setImageUrlString(QWConvertImageString.convertPicURL(avatar, imageSizeType: .avatar), placeholder: UIImage(named: "mycenter_logo"), animation: true)
            }

            if (user.check_in_count == nil) {
                self.summonsBtn.isUserInteractionEnabled = true
                self.summonsBtn.setBackgroundImage(UIImage(named: "btn_bg_15"), for: .normal)
                self.summonsBtn.setTitle("签到", for: .normal)
                self.summonsBtn.setTitleColor(UIColor.white, for: .normal)
            } else if let check_in_date = user.check_in_date, check_in_date.isToday() == false{
                self.summonsBtn.isUserInteractionEnabled = true;
                self.summonsBtn.setBackgroundImage(UIImage(named: "btn_bg_15"), for: .normal)
                self.summonsBtn.setTitle("签到", for: .normal)
                self.summonsBtn.setTitleColor(UIColor.white, for: .normal)
            } else if let _ = user.check_in_date, let _ = user.check_in_count{
//                self.summonsBtn.isEnabled = false
                self.summonsBtn.setBackgroundImage(UIImage(named: "btn_bg_16"), for: .normal)
                self.summonsBtn.setTitle("已签到", for: .normal)
                self.summonsBtn.setTitleColor(UIColor.colorFA(), for: .normal)
                self.summonsBtn.isUserInteractionEnabled = false;
//                let attributed = NSMutableAttributedString(string: "已签到", attributes: [NSForegroundColorAttributeName: UIColor.colorFA()])
//                self.summonsBtn.setAttributedTitle(attributed, for: .normal)
            }
//            self.summonsBtn.isEnabled = true
        }
    }
    @IBAction func onPressedSummonsBtn(_ sender: UIButton) {
        if !QWGlobalValue.sharedInstance().isLogin(){
            QWRouter.sharedInstance().routerToLogin()
            return
        }
        self.delegate?.headCell(cell: self, sender: sender)
    }
    
}
