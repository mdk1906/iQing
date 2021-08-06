//
//  QWCummonTVCell.swift
//  Qingwen
//
//  Created by mumu on 17/3/13.
//  Copyright © 2017年 iQing. All rights reserved.
//

import UIKit

class QWCommonTVCell: QWBaseTVCell {

    var iconImageView: UIImageView!
    var titleLabel: UILabel!
    var subTitleLable: UILabel!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.accessoryView = UIImageView(image: UIImage(named: "arrow_right"))
        self.selectionStyle = .none
        self.updateUI()
    }
    
    private func updateUI() {
        self.iconImageView = UIImageView()
        self.titleLabel = UILabel()
        self.subTitleLable = UILabel()
        self.addSubview(self.iconImageView)
        self.addSubview(self.titleLabel)
        self.addSubview(subTitleLable)
        
        self.iconImageView.autoPinEdge(.left, to: .left, of: self, withOffset: 10)
        self.iconImageView.autoSetDimension(.width, toSize: 24)
        self.iconImageView.autoSetDimension(.height, toSize: 24)
        self.iconImageView.autoAlignAxis(.horizontal, toSameAxisOf: self, withOffset: 0)
        
        self.titleLabel.autoPinEdge(.leading, to: .trailing, of: self.iconImageView, withOffset: 12)
        self.titleLabel.autoAlignAxis(toSuperviewAxis: .horizontal)
        self.titleLabel.textAlignment = .left
        self.titleLabel.textColor = UIColor.color55()
        self.titleLabel.font = UIFont.systemFont(ofSize: 14)

        self.subTitleLable.autoPinEdge(.trailing, to: .trailing, of: self, withOffset: -34)
        self.subTitleLable.autoAlignAxis(toSuperviewAxis: .horizontal)
        self.subTitleLable.textAlignment = .right
        self.subTitleLable.textColor = UIColor.color55()
        self.subTitleLable.font = UIFont.systemFont(ofSize: 14)
    }
    
    func updateCell(withIconImageString iconImage:String?, titleString:String?, subTitle:String?) {
        if let iconImage = iconImage {
            self.iconImageView.image = UIImage(named: iconImage)
        }
        if let title = titleString {
            self.titleLabel.text = title
        }else {
            self.titleLabel.text = "0"
        }
        if let subTitle = subTitle {
            self.subTitleLable.text = subTitle
        }
        
        
    }
}
