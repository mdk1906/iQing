//
//  QWBookListsDetailsHeader.swift
//  Qingwen
//
//  Created by wei lu on 21/12/17.
//  Copyright © 2017 iQing. All rights reserved.
//

import UIKit
protocol QWBooksListDetailsHeaderDelegate {
    func didSelectedCellAtIndexPath(_ sender: UIButton?)
}

class QWBooksListDetailsHeader: UIView {
    @IBOutlet var headBGView: UIImageView!
    @IBOutlet var bookListCreator: UIButton!
    @IBOutlet var bookListName: UILabel!
    @IBOutlet var avatar: UIImageView!
    @IBOutlet var bookListIntro: YYLabel!
    var delegate:QWBooksListDetailsHeaderDelegate?
    var profile:String?
    var isOwn:NSNumber?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.clipsToBounds = false
        self.layer.masksToBounds = false
        self.headBGView.clipsToBounds = true;
        self.headBGView.autoMatch(.height, to: .height, of: self)
        self.headBGView.autoMatch(.width, to: .width, of: self)
        if #available(iOS 8.0, *) {
            let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
            blurView.translatesAutoresizingMaskIntoConstraints = false
            blurView.alpha = 0.95;
            self.headBGView.addSubview(blurView);
            blurView.autoCenterInSuperview()
            blurView.autoMatch(.height, to: .height, of: self.headBGView)
            blurView.autoMatch(.width, to: .width, of: self.headBGView)
        }
        self.bookListIntro.autoPinEdge(.left, to: .left, of: self,withOffset:12)
        self.bookListIntro.autoPinEdge(.right, to: .right, of: self,withOffset:-12)
        self.bookListIntro.autoPinEdge(.bottom, to: .bottom, of: self,withOffset:-12)
        
        self.bookListCreator.bk_tapped { () -> Void in
            var params = [String: String]()
            params["profile_url"] = self.profile!
            var url = "user"
            if(self.isOwn?.boolValue == true){
               url = "myself"
            }
            QWRouter.sharedInstance().router(withUrlString: NSString.getRouterVCUrlString(fromUrlString: url, andParams: params))
        }
    }
    
    func updateWithData(_ bookLists:FavoriteBooksVO,ShowAll showAll:Bool){
        self.bookListCreator.setTitle( bookLists.user?.username, for: .normal)
        self.bookListName.text = bookLists.title
        self.profile = bookLists.user?.profile_url
        self.isOwn = bookLists.own
        if(bookLists.user?.avatar != nil){
            self.avatar.qw_setImageUrlString(QWConvertImageString.convertPicURL(bookLists.user?.avatar, imageSizeType: QWImageSizeType.avatar), placeholder: UIImage(named:"mycenter_logo2"),  cornerRadius: 20, borderWidth: 0, borderColor: UIColor.clear, animation: true, complete: nil)
        }
        self.bookListIntro?.text = bookLists.intro;
        self.showAllIntro(ShowAll: showAll);
    }
    
    func showAllIntro(ShowAll showAll:Bool) {
        if (showAll) {
            self.bookListIntro.numberOfLines = 0;
        }
        else {
            self.bookListIntro.numberOfLines = 2;
        }
        
        if let content = self.bookListIntro?.text {
            let introText = "简介:"+content
            //遇到\n，会换行
            let temText = introText.replacingOccurrences(of: "\n", with: "")
            if(showAll){
                let attributedString = NSMutableAttributedString(string: introText, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 12),NSForegroundColorAttributeName: UIColor(hex:0xAEAEAE)!])
                let size = CGSize(width: QWSize.screenWidth()-20, height: CGFloat.greatestFiniteMagnitude)
                let layout = YYTextLayout(containerSize: size, text: attributedString)
                self.bookListIntro.attributedText = attributedString
                self.bookListIntro.textLayout = layout
                
            }
            else{
                var attributedString = NSMutableAttributedString(string: temText, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 12),NSForegroundColorAttributeName: UIColor(hex:0xAEAEAE)!])
                var size = CGSize(width: CGFloat.greatestFiniteMagnitude,height:20)
                if var layout = YYTextLayout(containerSize: size, text: attributedString){
                    if(layout.textBoundingSize.width > (QWSize.screenWidth() - 20) * 1.5){//大于1.5行
                        size = CGSize(width: (QWSize.screenWidth() - 20) * 1.5,height:20)
                        layout = YYTextLayout(containerSize: size, text: attributedString)!
                        let ocTemText = temText as NSString
                        attributedString = NSMutableAttributedString(string: ocTemText.substring(with: layout.visibleRange), attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 12),NSForegroundColorAttributeName: UIColor(hex:0xAEAEAE)!])
                        attributedString.append(NSMutableAttributedString(string: "...", attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 12),NSForegroundColorAttributeName: UIColor(hex:0xAEAEAE)!]))
                        
                        let more = NSMutableAttributedString(string: "更多", attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 12),NSForegroundColorAttributeName: UIColor(hex:0xfb83ac)!])
                        
                        let highlight = YYTextHighlight()
                        highlight.setColor(UIColor(hex:0xfb83ac))
                        highlight.tapAction = {[weak self] (view: UIView, text: NSAttributedString, range: NSRange, rect: CGRect) in
                            self?.delegate?.didSelectedCellAtIndexPath(nil)
                        }
                        attributedString.append(more)
                        attributedString.yy_setTextHighlight(highlight, range: attributedString.yy_rangeOfAll())
                        self.bookListIntro.attributedText = attributedString;
                        size = CGSize(width: QWSize.screenWidth()-20, height: CGFloat.greatestFiniteMagnitude)
                        layout = YYTextLayout(containerSize: size, text: attributedString)!
                        self.bookListIntro.textLayout = layout
                    }else{
                        size = CGSize(width: QWSize.screenWidth()-20, height: CGFloat.greatestFiniteMagnitude)
                        layout = YYTextLayout(containerSize: size, text: attributedString)!
                        self.bookListIntro.attributedText = NSMutableAttributedString(string: introText, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 12),NSForegroundColorAttributeName: UIColor(hex:0xAEAEAE)!])
                        self.bookListIntro.textVerticalAlignment = .top
                        self.bookListIntro.numberOfLines = 1;
                        self.bookListIntro.textLayout = layout;
                    }
                }
                
                
            }
        }
    }
    
}
