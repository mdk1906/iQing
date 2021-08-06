//
//  QWSummonsSuccessView.swift
//  Qingwen
//
//  Created by Aimy on 11/16/15.
//  Copyright © 2015 iQing. All rights reserved.
//

import UIKit

class QWSummonsSuccessView: UIView {

    @IBOutlet var countLabel: UILabel!
    
    @IBOutlet var checkCategoryLabel: UILabel!
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var mainView: UIView!
    @IBOutlet weak var cancelBtn: UIButton!

    @IBOutlet weak var firstLab: UILabel!
    @IBOutlet weak var secondLab: UILabel!
    @IBOutlet weak var thirdLab: UILabel!
    @IBOutlet weak var fourthLab: UILabel!
    @IBOutlet weak var fiveLab: UILabel!
    @IBOutlet var checkAwardImageView: UIImageView!
    @IBOutlet var collectionOfButtons: Array<UIButton>!
    
    @IBOutlet weak var signAdBtn: UIButton!
    @IBOutlet weak var titleLab: UILabel!
    @IBOutlet var collectionOfImageViews: Array<UIImageView>!

    
    var count: NSNumber?
    
    @IBOutlet weak var checkinCountLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.mainView.isHidden = true
        self.imageView.isHidden = true
        self.cancelBtn.isHidden = true
        
        let checkin_ad:String = QWGlobalValue.sharedInstance().checkin_ad!
        if checkin_ad == "2" {
            self.signAdBtn.isHidden = true
        }
    }

    @IBAction func onPressedDoneBtn(_ sender: AnyObject) {
        self.removeFromSuperview()
    }

    func updateWithCount(_ count: NSNumber, andCheckInCount: NSNumber ,andData:Dictionary<String, String>) {
        self.mainView.isHidden = true
        self.imageView.isHidden = true

//        var images = [Int](1...71).flatMap { UIImage(named: "checkin_\($0)") }
//        images += [Int](1...4).flatMap { _ in UIImage(named: "checkin_\(71)") }
        
        self.titleLab.text = andData["top_text"]
        self.firstLab.text = andData["coin_1"]
        self.secondLab.text = andData["coin_2"]
        self.thirdLab.text = andData["coin_3"]
        self.fourthLab.text = andData["coin_4"]
        self.fiveLab.text = andData["coin_5"]
        self.count = count
        self.checkinCountLabel.text = "签到第\(andCheckInCount)天"
        
        let today = andCheckInCount.intValue % 5 == 0 ? 5 : (andCheckInCount.intValue % 5)
        let textColor = UIColor(hex: 0xF48985)!
        let awarString = NSMutableAttributedString(string: "")
        let attribute1 = NSAttributedString(string: "+\(count.intValue)", attributes:[NSFontAttributeName:UIFont.systemFont(ofSize: 30), NSForegroundColorAttributeName:textColor])
        let attribute2 = NSAttributedString(string: "轻石", attributes:[NSFontAttributeName:UIFont.systemFont(ofSize: 14), NSForegroundColorAttributeName:textColor])
        awarString.append(attribute1)
        awarString.append(attribute2)
        
        if today == 5 {
            //let attribute3 = NSAttributedString(string: "\n+1", attributes:[NSFontAttributeName:UIFont.systemFont(ofSize: 30), NSForegroundColorAttributeName:textColor])
            //let attribute4 = NSAttributedString(string: "购书券", attributes:[NSFontAttributeName:UIFont.systemFont(ofSize: 14), NSForegroundColorAttributeName:textColor])
            //awarString.append(attribute3)
            //awarString.append(attribute4)
            
            self.countLabel.attributedText = awarString
            self.checkAwardImageView.image = UIImage(named: "check_award_diamond")//check_award_ticket
        } else {
            
            self.countLabel.attributedText = awarString
            self.checkAwardImageView.image = UIImage(named: "check_award_diamond")
        }
        
        for (_, btn) in self.collectionOfButtons.enumerated() {
            let btnTag = btn.tag % 100
            if btnTag <= today{
                btn.setImage(UIImage(named: "check_signed"), for: .normal)
            } else {
                btn.setImage(UIImage(named: "check_unsigned"), for: .normal)
            }
        }
        for (_, imageView) in self.collectionOfImageViews.enumerated() {
            let imageViewTag = imageView.tag % 100
            if imageViewTag < today {
                imageView.image = UIImage(named: "check_signed_line")
            }else {
                imageView.image = UIImage(named: "check_dotted_line")
            }
        }
        
//        self.imageView.animationImages = images
//        self.imageView.image = nil;
//        self.imageView.animationRepeatCount = 1
//        self.imageView.animationDuration = 75 * 0.033
//        self.imageView.startAnimating()

//        performInMainThreadBlock({ () -> Void in
//            self.imageView.stopAnimating()
//            self.imageView.isHidden = true
            self.mainView.isHidden = false
            self.cancelBtn.isHidden = false
//            }, afterSecond: 75 * 0.033)
    }
    
    @IBAction func onPressShareBtn(_ sender: UIButton) {
        //看广告
        let checkin_ad:String = QWGlobalValue.sharedInstance().checkin_ad!
        if checkin_ad == "2" {
            return;
        }
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "SignWatchAd"), object: nil)
        self.removeFromSuperview()
//        var params = [String: String]()
//        params["title"] = "签到奖励 "
//        params["image"] = "https://image.iqing.in/shareCheckin.jpg"
//        if let count = self.count {
//            params["intro"] = "我在轻文轻小说签到领到了\(count)轻石，你也快来签到吧~"
//        }else {
//            params["intro"] = "我在轻文轻小说签到领到了轻石，你也快来签到吧~"
//        }
//        params["url"] = "https://www.iqing.in/app.html"
//        QWRouter.sharedInstance().router(withUrlString: NSString.getRouterVCUrlString(fromUrlString: "share", andParams: params))
    }
    @IBAction func directlySingBtnClick(_ sender: UIButton) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "SignNOWatchAd"), object: nil)
        self.removeFromSuperview()
        
    }
    
}
