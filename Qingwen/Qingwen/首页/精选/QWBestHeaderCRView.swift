//
//  QWBestHeaderCRView.swift
//  Qingwen
//
//  Created by Aimy on 10/13/15.
//  Copyright © 2015 iQing. All rights reserved.
//

class QWBestHeaderCRView: QWBaseCRView {

    @IBOutlet var imageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var actionBtn: UIButton!
    @IBOutlet weak var rightImage: UIImageView!
    @IBOutlet weak var bestMoreImageBg: UIImageView!
    @IBOutlet weak var actionImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.actionBtn.setTitle(nil, for: UIControlState())
        let tapGesture = UITapGestureRecognizer()
        tapGesture.bk_init { [weak self] (_, _, _) -> Void in
            if let weakSelf = self {
                weakSelf.actionBtn.sendActions(for: UIControlEvents.touchUpInside)
            }
        }
        
        self.addGestureRecognizer(tapGesture)

        if (UIDevice.current.systemVersion as NSString).floatValue < 8.0 {
            self.imageView.image = UIImage(named: "best_header_image")?.withRenderingMode(.alwaysTemplate)
            self.actionImageView.image = UIImage(named: "best_header_right_image")?.withRenderingMode(.alwaysTemplate)
        }
    }

    
    func updateWithIndexPath(_ indexPath: IndexPath) {
        
        self.actionBtn.tag = (indexPath as NSIndexPath).section
        self.tag = (indexPath as NSIndexPath).section
        self.rightImage.image = UIImage(named: "nil")
        self.actionImageView.isHidden = true
        self.bestMoreImageBg.isHidden = true
        self.actionBtn.isHidden = true
        
        switch QWBestCVC.QWBestType(section: (indexPath as NSIndexPath).section) {
        case .recommend:
            self.imageView.isHidden = false
            self.imageView.image = UIImage(named: "best_icon_1")
            self.titleLabel.isHidden = false
            self.titleLabel.text = "主编强推"
            
//            self.rightImage.image = UIImage(named: "best_icon_1_1")
//            self.actionBtn.setTitle("排行榜", forState: .Normal)
//            self.actionBtn.setTitleColor(UIColor(hex: 0xFB83AC), forState: .Normal)
//            self.actionBtn.hidden = false
//            self.actionImageView.image = UIImage(named: "best_icon_1_rank")
//            self.actionImageView.hidden = false
        case .new:
            self.imageView.isHidden = false
            self.imageView.image = UIImage(named: "best_icon_2")
            self.titleLabel.isHidden = false
            self.titleLabel.text = "签约新秀"
        case .recommend2:
            self.imageView.isHidden = false
            self.imageView.image = UIImage(named: "best_icon_3")
            self.titleLabel.isHidden = false
            self.titleLabel.text = "小编推荐"
  
        case .hot:
            self.imageView.isHidden = false
            self.imageView.image = UIImage(named: "best_icon_4")
            self.titleLabel.isHidden = false
            self.titleLabel.text = "热门作品"

        case .discount:
            self.imageView.isHidden = false
            self.imageView.image = UIImage(named: "best_icon_5")
            self.titleLabel.isHidden = false
            self.titleLabel.text = "限时优惠"
        case .zone:
            self.imageView.isHidden = false
            self.imageView.image = UIImage(named: "best_icon_7")
            self.titleLabel.isHidden = false
            self.titleLabel.text = "分区推荐"
        case .update:
            self.imageView.isHidden = false
            self.imageView.image = UIImage(named: "best_icon_6")
            self.titleLabel.isHidden = false
            self.titleLabel.text = "最近更新"
        default:
            self.imageView.isHidden = true
            self.titleLabel.isHidden = true
            self.actionBtn.isHidden = true
            self.actionImageView.isHidden = true
        }
    }
}
