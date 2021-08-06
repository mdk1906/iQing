//
//  QWSquareStoneRankTVCell.swift
//  Qingwen
//
//  Created by qingwen on 2018/4/17.
//  Copyright © 2018年 iQing. All rights reserved.
//

import UIKit

class QWSquareStoneRankTVCell: QWBaseTVCell {
    
    @IBOutlet weak var rankScroll: LLCycleScrollView!
    @IBOutlet weak var backView: UIView!
    var emptyImg :UIImageView!
    var imagesURLStrings :Array<String>! = []
    var userNameArr:Array<String>! = []
    var contentArr:Array<String>!  = []
    var bookIdArr:Array<String>! = []
    var stoneArr:Array<String>! = []
    var bookTitleArr :Array<NSNumber>! = []
    var userIdArr :Array<NSNumber>! = []
    var bookUrlArr :Array<String>! = []
    var profile_urlArr :Array<String>! = []
    var rankArr :Array<String>! = []
    var medalArr :Array<String>! = []
    var nextBtn: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        //        self.placeholder = UIImage(named: "placeholder2to1")
        // Initialization code
        backView.layer.cornerRadius = 3
        backView.layer.masksToBounds = true
        backView.layer.borderColor = UIColor.colorF9().cgColor
        backView.layer.borderWidth = 2
        
        let titleView = UIView.init()
        titleView.frame = CGRect(x:0,y:0,width:QWSize.screenWidth(),height:30)
        titleView.backgroundColor = UIColor.colorF9()
        
        let titleLab = UILabel.init()
        titleLab.frame = CGRect(x:10,y:0,width:100,height:30)
        titleLab.text = "本周投石榜"
        titleLab.font = UIFont.systemFont(ofSize: 14)
        titleLab.textColor = UIColor.color33()
        backView.addSubview(titleLab)
        
        nextBtn = UIButton.init()
        nextBtn.frame = CGRect(x:QWSize.screenWidth()-10-20-50,y:0,width:50,height:30)
        nextBtn.setTitle("下一个", for: .normal)
        nextBtn.addTarget(self, action: #selector(nextClick), for: .touchUpInside)
        nextBtn.setTitleColor(UIColor.color33(), for: .normal)
        nextBtn.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        backView.addSubview(nextBtn)
        
        let notificationName = Notification.Name(rawValue: "headImgClick")
        NotificationCenter.default.addObserver(self, selector: #selector(headImgclick(notification:)), name: notificationName, object: nil)
        let notificationName2 = Notification.Name(rawValue: "bookLabClick")
        NotificationCenter.default.addObserver(self, selector: #selector(bookLabClick(notification:)), name: notificationName2, object: nil)
        
        emptyImg = UIImageView.init(frame: CGRect(x:10,y:30,width:QWSize.screenWidth()-20,height:73))
        emptyImg.image = UIImage(named:"空白投石榜")
        emptyImg.layer.cornerRadius = 3
        emptyImg.layer.masksToBounds = true
        self.contentView.addSubview(emptyImg)
        emptyImg.isHidden = true
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    func createScrollView()  {
        self.rankScroll.imagePaths = imagesURLStrings
        self.rankScroll.userName = userNameArr
        self.rankScroll.content = contentArr
        self.rankScroll.bookName = bookIdArr
        self.rankScroll.stone = stoneArr
        self.rankScroll.rank = rankArr
        self.rankScroll.medal = medalArr
        // 新增图片显示控制
        self.rankScroll.imageViewContentMode = .scaleToFill
        self.rankScroll.customPageControlStyle = .image
        self.rankScroll.pageControlPosition = .center
        // 是否对url进行特殊字符处理
        self.rankScroll.isAddingPercentEncodingForURLString = true
        
        self.rankScroll.delegate = self as LLCycleScrollViewDelegate
        self.rankScroll.pageControl?.frame = CGRect(x:0,y:120,width:UIScreen.main.bounds.width, height: 10)
        self.contentView.addSubview(self.rankScroll.pageControl!)
    }
    func updateWithStoneRank(_ stoneRank: Dictionary<String, Any>) {
        imagesURLStrings = []
        userNameArr = []
        contentArr = []
        bookIdArr = []
        stoneArr = []
        bookTitleArr = []
        userIdArr = []
        bookUrlArr = []
        profile_urlArr  = []
        rankArr = []
        medalArr = []
        print("stone12345 = ",stoneRank)
        
        var dataArr = [Dictionary<String, Any>]()
        dataArr  = stoneRank["results"]! as! [Dictionary<String, Any>]
        var index :Int = 1
        for dic :Dictionary<String,Any> in dataArr {
            
            let paid_gold = dic["gold"] as! NSNumber
            let book:Dictionary<String,Any> = dic["book"] as! Dictionary
            
            let title = book["title"] as! String
//            let bookId = book["id"] as! NSNumber
            
            let user:Dictionary<String,Any> = dic["user"] as! Dictionary
            let signature = user["signature"] as! String
            let avatar = user["avatar"] as! String
            let userId = user["id"] as! NSNumber
            let userName = user["username"] as! String
            if let medalStr = user["adorn_medal"] {
                medalArr?.append(medalStr as! String)
            }
            else{
                
            }
            
            #if DEBUG
            let profile_urlStr = "https://box-gate.iqing.com/user/" + userId.description + "/profile/"
            let share_url = book["share_url"] as! String
            #else
            let profile_urlStr = "https://box.iqing.com/user/" + userId.description + "/profile/"
            let share_url = book["share_url"] as! String
            #endif
            
            imagesURLStrings?.append(avatar)
            userNameArr?.append(userName)
            contentArr?.append(signature)
            bookIdArr?.append(title)
            stoneArr?.append(paid_gold.description)
            bookUrlArr?.append(share_url)
            profile_urlArr?.append(profile_urlStr)
            rankArr?.append(index.description)
            
            index = index + 1
        }
        self.createScrollView()
    }
    
    func nextClick()  {
        self.rankScroll.automaticScroll()
    }
    func headImgclick(notification: Notification) {
        
        let index:Int = notification.object as! Int
        var params = [String: String]()
        params["profile_url"] = profile_urlArr[index]
        params["username"] = userNameArr[index]
        QWRouter.sharedInstance().router(withUrlString: NSString.getRouterVCUrlString(fromUrlString: "user", andParams: params))
    }
    func bookLabClick(notification: Notification) {
        
        let index:Int = notification.object as! Int
        //        var params = [String: String]()
        //        params["id"] = bookIdArr[index]
        //        params["book_url"] = bookUrlArr[index]
        //            QWRouter.sharedInstance().router(withUrlString: NSString.getRouterVCUrlString(fromUrlString: "book", andParams: params))
        QWRouter.sharedInstance().router(withUrlString: NSString.getRouterVCUrlString(fromUrlString:bookUrlArr[index])!)
        
        
    }
}
extension QWSquareStoneRankTVCell: LLCycleScrollViewDelegate {
    func cycleScrollView(_ cycleScrollView: LLCycleScrollView, didSelectItemIndex index: NSInteger) {
        print("协议：当前点击文本的位置为:\(index)")
    }
}
