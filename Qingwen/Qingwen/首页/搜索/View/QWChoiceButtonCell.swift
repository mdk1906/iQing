//
//  QWChoiceButtonCell.swift
//  Qingwen
//
//  Created by mumu on 2017/7/26.
//  Copyright © 2017年 iQing. All rights reserved.
//

import UIKit

class QWChoiceButtonCell: QWBaseCVCell {

    @IBOutlet var choiceBtn: UIButton!
    
    func updateBtnTitle(title: String) {
        self.choiceBtn.setTitle(title, for: UIControlState())
    }
}
