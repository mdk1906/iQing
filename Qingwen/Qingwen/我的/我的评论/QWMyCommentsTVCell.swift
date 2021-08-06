//
//  QWMyCommentsTVCell.swift
//  Qingwen
//
//  Created by qingwen on 2018/4/27.
//  Copyright © 2018年 iQing. All rights reserved.
//

import UIKit

class QWMyCommentsTVCell: QWBaseTVCell {

    var contentLab : QWLabel!
    var recordLab :UILabel!
    var hui :UIView!
    var headImg:UIImageView!
    var userName:UILabel!
    var timeLab :UILabel!
    var hui2 : UIView!
    override func awakeFromNib()  {
        super.awakeFromNib()
        // Initialization code
       
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        headImg = UIImageView.init()
        headImg.frame = CGRect(x:11,y:10,width:40,height:40)
        headImg.backgroundColor = UIColor.blue
        headImg.layer.cornerRadius = 20
        headImg.layer.masksToBounds = true
        
        self.contentView.addSubview(headImg)
        
        userName = UILabel.init()
        userName.frame = CGRect(x:56,y:10,width:QWSize.screenWidth()-80,height:14)
        userName.textColor = UIColor(hex: 0x555555)
        userName.text = "我是作者"
        userName.font = UIFont.systemFont(ofSize: 14)
        self.contentView.addSubview(userName)
        
        timeLab = UILabel.init()
        timeLab.frame = CGRect(x:56,y:34,width:QWSize.screenWidth()-80,height:11)
        timeLab.textColor = UIColor(hex: 0x555555)
        timeLab.text = "2小时前"
        timeLab.font = UIFont.systemFont(ofSize: 11)
        self.contentView.addSubview(timeLab)
        
        contentLab  = QWLabel.init()
        
        contentLab.textColor = UIColor(hex: 0x555555)
        contentLab.numberOfLines = 9999
        contentLab.font = UIFont.systemFont(ofSize: 12)
        self.contentView.addSubview(contentLab)
        
         hui = UIView.init()
        
        hui.backgroundColor = UIColor(hex: 0xF4F4F4)
        self.contentView.addSubview(hui)
        
        recordLab  = UILabel.init()
        recordLab.frame = CGRect(x:0,y:0,width:QWSize.screenWidth()-22,height:38)
        recordLab.textColor = UIColor(hex: 0xababab)
        
        recordLab.backgroundColor = UIColor(hex: 0xF4F4F4)
        recordLab.font = UIFont.systemFont(ofSize: 12)
        hui.addSubview(recordLab)
        
        hui2 = UIView.init()
        hui2.frame = CGRect(x:0,y:140,width:QWSize.screenWidth(),height:10)
        hui2.backgroundColor = UIColor(hex: 0xF4F4F4)
        self.contentView.addSubview(hui2)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    var CommentsVO:CommentsVO? {
        didSet {
            headImg.qw_setImageUrlString(QWConvertImageString.convertPicURL(CommentsVO?.s_user?.avatar, imageSizeType: .avatar), placeholder: UIImage(named: "mycenter_logo"), animation: true)
            userName.text = CommentsVO?.s_user?.username
//            timeLab.text = QWHelper.shortDate(toString: CommentsVO?.created_time)
            if let created_time = CommentsVO?.created_time {
                self.timeLab?.text = QWHelper.shortDate2(toString: CommentsVO?.created_time)
//                print("时间 = ",created_time)
            }
            
            let height :CGFloat = contentLab.getLabHeight(labelStr: (CommentsVO?.s_content)!, font: UIFont.systemFont(ofSize: 12), width: QWSize.screenWidth()-22)
            contentLab.frame = CGRect(x:11,y:60,width:QWSize.screenWidth()-22,height:height)
            contentLab.text = CommentsVO?.s_content
            
            if CommentsVO?.r_content == "" {
                hui.isHidden = true
                hui2.frame = CGRect(x:0,y:height+60+10,width:QWSize.screenWidth(),height:10)
            }
            else{
                hui.isHidden = false
                hui.frame = CGRect(x:11,y:60+height+10,width:QWSize.screenWidth()-22,height:38)
                hui2.frame = CGRect(x:0,y:height+60+10+38+10,width:QWSize.screenWidth(),height:10)
                recordLab.text = CommentsVO?.r_content
            }
            headImg.bk_tapped {
                if self.CommentsVO?.order == -1{
                    
                }
                else{
                    
                }
            }
        }
    }
    
}
