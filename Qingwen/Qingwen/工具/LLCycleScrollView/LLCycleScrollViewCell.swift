//
//  LLCycleScrollViewCell.swift
//  LLCycleScrollView
//
//  Created by LvJianfeng on 2016/11/22.
//  Copyright © 2016年 LvJianfeng. All rights reserved.
//

import UIKit

class LLCycleScrollViewCell: UICollectionViewCell {
    
    // 标题
    var title: String = "" {
        didSet {
            titleLabel.text = "\(title)"
            
            if title.count > 0 {
                
            }else{
                
            }
        }
    }
    // userName
    var userName: String = "" {
        didSet {
            userNameLab.text = "\(userName)"
            
            if userName.count > 0 {
                
            }else{
                
            }
        }
    }

    // content
    var content: String = "" {
        didSet {
            contentLab.text = "\(content)"
            
            if content.count > 0 {
                
            }else{
                
            }
        }
    }
    // rank
    var rank: String = "" {
        didSet {
            rankLab.text = "\(rank)"
            
            if rank.count > 0 {
                
            }else{
                
            }
        }
    }
    // bookNmae
    var bookName: String = "" {
        didSet {
            if bookName.count >= 13{
                let rangeOfSub = bookName.index(bookName.endIndex, offsetBy: -2)
                let lastStr = bookName.substring(from: rangeOfSub)
                
                let rangeOfStart = bookName.index(bookName.startIndex,offsetBy: 5)
                let startStr = bookName.substring(to: rangeOfStart)
                let attributeString = NSMutableAttributedString(string:"投石最多：" + "《" + "\(startStr)" + "..." + "\(lastStr)" + "》")
                //设置字体颜色
                attributeString.addAttribute(NSForegroundColorAttributeName, value: UIColor(hex:0x252525)!,
                                             range: NSMakeRange(0, 5))
                bookLab.attributedText = attributeString
            }else{
                let attributeString = NSMutableAttributedString(string:"投石最多：" + "《" + "\(bookName)" + "》")
                //设置字体颜色
                attributeString.addAttribute(NSForegroundColorAttributeName, value: UIColor(hex:0x252525)!,
                                             range: NSMakeRange(0, 5))
                bookLab.attributedText = attributeString
            }
            
//            bookLab.text = "打赏：" + "\(bookName)"
            
            if bookName.count > 0 {
                
            }else{
                
            }
        }
    }
    // stone
    var stone: String = "" {
        didSet {
            stoneLab.text = "\(stone)" + "重石"
            
            if stone.count > 0 {
                
            }else{
                
            }
        }
    }
    
    
    // 标题颜色
    var titleLabelTextColor: UIColor = UIColor.white {
        didSet {
            titleLabel.textColor = titleLabelTextColor
        }
    }
    
    // 标题字体
    var titleFont: UIFont = UIFont.systemFont(ofSize: 15) {
        didSet {
            titleLabel.font = titleFont
        }
    }
    
    // 文本行数
    var titleLines: NSInteger = 2 {
        didSet {
            titleLabel.numberOfLines = titleLines
        }
    }
    
    // 标题文本x轴间距
    var titleLabelLeading: CGFloat = 15 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    
    // 标题背景色
    var titleBackViewBackgroundColor: UIColor = UIColor.black.withAlphaComponent(0.3) {
        didSet {
            
        }
    }
    
    
    
    // 标题Label高度
    var titleLabelHeight: CGFloat! = 56 {
        didSet {
            layoutSubviews()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupImageView()
        setupTitleLabel()
    }
    
    // 图片
    var imageView: UIImageView!
    fileprivate var titleLabel: UILabel!
    fileprivate var userNameLab :UILabel!
    fileprivate var contentLab :UILabel!
    fileprivate var rankLab :UILabel!
    fileprivate var noLab :UILabel!
    fileprivate var bookLab :UILabel!
    fileprivate var stoneLab:UILabel!
    var medalImgView:UIImageView!
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Setup ImageView
    fileprivate func setupImageView() {
        imageView = UIImageView.init()
        // 默认模式
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        self.contentView.addSubview(imageView)
        medalImgView = UIImageView.init()
        self.contentView.addSubview(medalImgView)
    }
    
    
    
    // Setup Title
    fileprivate func setupTitleLabel() {
        titleLabel = UILabel.init()
        titleLabel.isHidden = true
        titleLabel.textColor = titleLabelTextColor
        titleLabel.numberOfLines = titleLines
        titleLabel.font = titleFont
        titleLabel.backgroundColor = UIColor.clear
        self.contentView.addSubview(titleLabel)
        
        userNameLab = UILabel.init()
        
        userNameLab.text = "轻文娘正在整理中...."
        userNameLab.font = UIFont.systemFont(ofSize: 14)
        userNameLab.textColor = UIColor.color33()
        self.contentView.addSubview(userNameLab)
        
        contentLab = UILabel.init()
        
        contentLab.text = "轻文娘正在整理中...."
        contentLab.font = UIFont.systemFont(ofSize: 12)
        contentLab.textColor = UIColor(hex: 0xBFBFBF)
        self.contentView.addSubview(contentLab)
        
        rankLab = UILabel.init()
        
        rankLab.text = "1"
        rankLab.font = UIFont.systemFont(ofSize: 48)
        rankLab.textColor = UIColor(hex:0xFF8E9B)
        rankLab.textAlignment = .right
        self.contentView.addSubview(rankLab)
        
        noLab = UILabel.init()
        
        noLab.text = "No"
        noLab.font = UIFont.systemFont(ofSize: 12)
        noLab.textColor = UIColor(hex:0xFF8E9B)
        self.contentView.addSubview(noLab)
        
        bookLab = UILabel.init()
        
        bookLab.text = "打赏：轻文娘正在整理中...."
        bookLab.font = UIFont.systemFont(ofSize: 12)
        bookLab.textColor = UIColor(hex:0xFF8E9B)
        self.contentView.addSubview(bookLab)
        
        stoneLab = UILabel.init()
        
        stoneLab.text = "轻文娘正在整理中...."
        stoneLab.font = UIFont.systemFont(ofSize: 12)
        stoneLab.textColor = UIColor(hex:0x252525)
        stoneLab.textAlignment = .right
        self.contentView.addSubview(stoneLab)
        
        
    }
    //
    // MARK: layoutSubviews
    override func layoutSubviews() {
        super.layoutSubviews()
        
        imageView.frame = CGRect(x:10,y:3,width:46,height:46)
        imageView.layer.cornerRadius = 23
        imageView.layer.masksToBounds = true
        medalImgView.frame = CGRect(x:10,y:3+46-46*0.308,width:46,height:46*0.308)
        titleLabel.frame = CGRect.init(x:60,y:4,width:150,height:20)
        contentLab.frame = CGRect(x:60,y:29,width:UIScreen.main.bounds.width-71-89,height:20)
        userNameLab.frame = CGRect(x:60,y:4,width:150,height:20)
        rankLab.frame = CGRect(x:UIScreen.main.bounds.width-30-30-10,y:2,width:30,height:48)
        noLab.frame = CGRect(x:UIScreen.main.bounds.width-55-30-10,y:29,width:20,height:17)
        bookLab.frame = CGRect(x:10,y:53,width:UIScreen.main.bounds.width-40-100,height:17)
        stoneLab.frame = CGRect(x:UIScreen.main.bounds.width-30-150-10,y:53,width:150,height:12)
    }
}
