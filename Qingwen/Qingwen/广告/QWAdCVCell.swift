//
//  QWAdCVCell.swift
//  Qingwen
//
//  Created by qingwen on 2019/3/5.
//  Copyright © 2019 iQing. All rights reserved.
//

import UIKit

class QWAdCVCell: QWBaseCVCell {
    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.backgroundColor = UIColor.white
        
    }
    func createUI() {
        let headView = QWbannerAdView.init(frame: CGRect(x:0,y:0,width:QWSize.screenWidth(),height:QWSize.bannerHeight()))
        //        headView.frame = CGRect(x:0,y:0,width:QWSize.screenWidth(),height:125)
        headView?.backgroundColor = UIColor.white
        self.contentView.addSubview(headView!)
        
    }
}
