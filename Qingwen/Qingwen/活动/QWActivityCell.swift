//
//  QWActivityCell.swift
//  Qingwen
//
//  Created by mumu on 2017/4/25.
//  Copyright © 2017年 iQing. All rights reserved.
//

import UIKit

class QWActivityCell: QWBaseTVCell {
    
    @IBOutlet var activityImageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var newImageView: UIImageView!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var otherLabel: UILabel!
    @IBOutlet var stateImageView: UIImageView!

    func updateCell(activityVO vo: ActivityVO) {
        if  let _ = vo.started_time,let _ = vo.ended_time{
            
            if let _ = QWUserDefaults.sharedInstance()["activity_\(vo.nid!)"] as? NSDate {
                self.newImageView.isHidden = true
            }
            else {
                self.newImageView.isHidden = false
            }
        }

        if let cover = vo.cover {
            self.activityImageView.qw_setImageUrlString(QWConvertImageString.convertPicURL(cover, imageSizeType: QWImageSizeType.promotion), placeholder: self.placeholder, animation:true)
        }
        
        if let title = vo.title {
            self.titleLabel.text = title
            if let state = vo.status?.intValue{
                switch state {
                case 0:
                    self.titleLabel.text = title
                    self.stateImageView.image = #imageLiteral(resourceName: "activity_finished")
                    self.newImageView.isHidden = true
                case 1:
                    self.titleLabel.text = title
                    self.stateImageView.image = #imageLiteral(resourceName: "activity_planning")
                case 2:
                    self.titleLabel.text = title
                    self.stateImageView.image = #imageLiteral(resourceName: "activity_ongoing")
                default:
                    break
                }
            }
        }
    }
    
    func configOtherLable(activityVO vo: ActivityVO) {
        if let bf_count = vo.bf_count, let work_count = vo.work_count, (bf_count.intValue > 0 || work_count.intValue > 0 ) {
            let pinkAttributeDic = [NSFontAttributeName: UIFont.systemFont(ofSize: 12),
                                    NSForegroundColorAttributeName: UIColor.colorQWPinkDark()] as [String : Any]
            let commonAttributeDic = [NSFontAttributeName: UIFont.systemFont(ofSize: 12),
                                      NSForegroundColorAttributeName: UIColor(hex: 0x666666)!] as [String : Any]
            let workCountAttribute = NSAttributedString(string: "\(work_count)", attributes: pinkAttributeDic)
            
            let bfCountAttribute = NSAttributedString(string: "\(bf_count)", attributes: pinkAttributeDic)
            
            let workAttribute = NSMutableAttributedString(string: "作品", attributes: commonAttributeDic)
            let bfAttribute = NSAttributedString(string: " / 讨论", attributes: commonAttributeDic)
            workAttribute.append(workCountAttribute)
            workAttribute.append(bfAttribute)
            workAttribute.append(bfCountAttribute)
            self.otherLabel.attributedText = workAttribute
        }
            
        else {
            self.otherLabel.isHidden = true
        }
        self.dateLabel.text = "\(QWHelper.fullDate2(toString: vo.started_time)!)—\(QWHelper.fullDate2(toString: vo.ended_time)!)"
    }
}
