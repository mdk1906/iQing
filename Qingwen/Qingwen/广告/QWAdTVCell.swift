//
//  QWAdTVCell.swift
//  Qingwen
//
//  Created by qingwen on 2019/2/25.
//  Copyright © 2019 iQing. All rights reserved.
//

import UIKit

class QWAdTVCell: QWListTVCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.backgroundColor = UIColor.white
        // Initialization code
//        self.createUI()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func createUI(type: String) {
        var ad :String?
        var adInc :String?
        var adURL :String?
        if type == "Favorite" {
            ad = QWGlobalValue.sharedInstance().favorite_ad!
            adInc = QWGlobalValue.sharedInstance().favorite_adInc!
            adURL = QWGlobalValue.sharedInstance().favorite_adURL!
        }
        if type == "Square" {
            ad = QWGlobalValue.sharedInstance().square_ad!
            adInc = QWGlobalValue.sharedInstance().square_adInc!
            adURL = QWGlobalValue.sharedInstance().square_adURL!
        }
        if type == "Topic" {
            ad = QWGlobalValue.sharedInstance().topic_ad!
            adInc = QWGlobalValue.sharedInstance().topic_adInc!
            adURL = QWGlobalValue.sharedInstance().topic_adURL!
        }
        if type == "Brand" {
            ad = QWGlobalValue.sharedInstance().brand_ad!
            adInc = QWGlobalValue.sharedInstance().brand_adInc!
            adURL = QWGlobalValue.sharedInstance().brand_adURL!
        }
        if type == "Upper" {
            ad = QWGlobalValue.sharedInstance().upper_ad!
            adInc = QWGlobalValue.sharedInstance().upper_adInc!
            adURL = QWGlobalValue.sharedInstance().upper_adURL!
        }
        if type == "Active"{
            ad = QWGlobalValue.sharedInstance().active_ad!
            adInc = QWGlobalValue.sharedInstance().active_adInc!
            adURL = QWGlobalValue.sharedInstance().active_adURL!
        }
//        let favorite_ad:String = QWGlobalValue.sharedInstance().favorite_ad!
        if ad == "0"{
            let headView = QWGDTbannerAdView.init(frame: CGRect(x:0,y:0,width:QWSize.screenWidth(),height:QWSize.bannerHeight()))
            let str = type + "Event"
            let extra = NSMutableDictionary()
            extra["source"] = "GDT"
            QWUserStatistics .sendEvent(toServer: "CustomEvent", pageID: str, extra: extra )
            headView?.backgroundColor = UIColor.white
            self.contentView.addSubview(headView!)
        }
        if ad == "1"{
//            let favorite_adInc:String = QWGlobalValue.sharedInstance().favorite_adInc!
            let str = type + "Event"
            let extra = NSMutableDictionary()
            extra["source"] = "iQing"
            
            QWUserStatistics .sendEvent(toServer: "CustomEvent", pageID: str, extra: extra )
            print(str)
            let imgView = UIImageView.init()
            imgView.isUserInteractionEnabled = true;
            imgView .qw_setImageUrlString(adInc, placeholder: nil, animation: true)
            imgView.frame = CGRect(x:0,y:0,width:QWSize.screenWidth(),height:QWSize.bannerHeight())
            if type == "Brand" || type == "Upper"{
                imgView.frame = CGRect(x:0,y:0,width:QWSize.screenWidth()-61,height:QWSize.bannerHeight())
            }
            imgView .bk_tapped {
                QWRouter.sharedInstance().router(withUrlString: adURL!)
                let extra = NSMutableDictionary()
                extra["source"] = "iQing"
                let str = type + "ClickEvent"
                
                QWUserStatistics .sendEvent(toServer: "CustomEvent", pageID: str, extra: extra )
            };
            self.contentView.addSubview(imgView)
        }
        
        
    }
}
