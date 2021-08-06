//
//  QWBestDiscussCVCell.swift
//  Qingwen
//
//  Created by Aimy on 11/6/15.
//  Copyright © 2015 iQing. All rights reserved.
//

import UIKit

class QWBestDiscussCVCell: QWBaseCVCell {
    
    @IBOutlet weak var zoneView: UIView!
    @IBOutlet var topicView: UIView!
    @IBOutlet var activityView: UIView!
    @IBOutlet var boutiqueView: UIView!
    @IBOutlet var smallYellowBookView: UIView!
    @IBOutlet var bgImages: Array<UIImageView>!
    @IBOutlet var titles: Array <UILabel>!
    @IBOutlet var activityPageBtn: UIButton!
    @IBOutlet weak var freeView: UIView!
    @IBOutlet weak var vipZoneLab: UILabel!
    
    var url = ""
    var name = "少年讨论"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
            vipZoneLab.text = "VIP专区";
        
        self.boutiqueView.bk_tapped {
            var params = [String: Any]()
            params["tags"] = [[3,"原创"],[2,"白金"], [1, "信仰"]]
            params["rank"] = 6
            params["order"] = 2
            params["boutique"] = 1
            params["channel"] = 10
            params["title"] = "精品"
            QWRouter.sharedInstance().router(withUrlString: NSString.getRouterVCUrlString(fromUrlString: "booklibrary", andParams: params))
        }
        
        self.smallYellowBookView.bk_tapped {
                        var params = [String: Any]()
                        params["title"] = "文库本"
                        params["tags"] = [[3,"文库本"],[1,"战力"]]
                        params["channel"] = 14
                        params["riqing"] = 1
                        params["order"] = 1
            
                        QWRouter.sharedInstance().router(withUrlString: NSString.getRouterVCUrlString(fromUrlString: "booklibrary", andParams: params))
//            var params = [String: AnyObject]()
//            params["title"] = "活动" as AnyObject
//            QWRouter.sharedInstance().router(withUrlString: NSString.getRouterVCUrlString(fromUrlString: "actopiclist", andParams: params))
        }
        self.activityView.bk_tapped {
            //            var params = [String: AnyObject]()
            //            params["title"] = "活动" as AnyObject
            //            QWRouter.sharedInstance().router(withUrlString: NSString.getRouterVCUrlString(fromUrlString: "actopiclist", andParams: params))
            var params = [String: Any]()
            params["tags"] = [[1, "战力"]]
            params["order"] =  1
            params["title"] = "演绘库"
            QWRouter.sharedInstance().router(withUrlString: NSString.getRouterVCUrlString(fromUrlString: "gamelibrary", andParams: params))
        }
        self.topicView.bk_tapped {
            //            var params = [String: AnyObject]()
            //            params["title"] = "专题" as AnyObject
            //            params["topic"] = 1 as AnyObject
            //            QWRouter.sharedInstance().router(withUrlString: NSString.getRouterVCUrlString(fromUrlString: "actopiclist", andParams: params))
            var params = [String: Any]()
            params["tags"] = [[1, "战力"]]
            params["order"] =  1
            params["title"] = "小说库"
            QWRouter.sharedInstance().router(withUrlString: NSString.getRouterVCUrlString(fromUrlString: "booklibrary", andParams: params))
            
        }
        self.zoneView.bk_tapped{
            let vc = QWVIPSectionVC()
            self.nextresponsder(viewself: self).navigationController?.pushViewController(vc, animated: true)
        }
        
        self.freeView.bk_tapped{
            let vc = QWFreeZoneVC()
            self.nextresponsder(viewself: self).navigationController?.pushViewController(vc, animated: true)
        }
    }
    @IBAction func onPressedBookLibraryBtn(_ sender: UIButton) {
        
    }
    
    @IBAction func onPressedGameLibraryBtn(_ sender: UIButton) {
        
    }
    func updateDiscussItem(withEntrances entrances: [EntranceVO]?){
        guard let entrances = entrances else { return }
        //        for (_, item) in entrances.enumerated() {
        //            if let title = item.title, let cover = item.cover, let order = item.order?.intValue {
        //                self.titles[order].text = title
        //                switch order {
        //                case 0:
        //                    self.bgImages[order].qw_setImageUrlString(QWConvertImageString.convertPicURL(cover, imageSizeType: .category), placeholder: UIImage(named: "best_icon_boutiqueView"), animation: true)
        //                case 1:
        //                    self.bgImages[order].qw_setImageUrlString(QWConvertImageString.convertPicURL(cover, imageSizeType: .category), placeholder: UIImage(named: "best_icon_riqing"), animation: true)
        //                case 2:
        //                    self.bgImages[order].qw_setImageUrlString(QWConvertImageString.convertPicURL(cover, imageSizeType: .category), placeholder: UIImage(named: "best_icon_category"), animation: true)
        //                case 3:
        //                    self.bgImages[order].qw_setImageUrlString(QWConvertImageString.convertPicURL(cover, imageSizeType: .category), placeholder: UIImage(named: "best_icon_activity"), animation: true)
        //                default:
        //                    break
        //                }
        //            }
        //
        //        }
    }
    
    /**
     用于获取父亲控制器
     
     - parameter ViewC:  当前的控制器
     - parameter target: 要获取的父亲控制器的类型
     
     - returns: 返回父亲控制器
     */
    func nextresponsder(viewself:UIView)->UIViewController{
        var vc:UIResponder = viewself
        while vc.isKind(of: UIViewController.self) != true {
            vc = vc.next!
        }
        return vc as! UIViewController
    }
    
}
