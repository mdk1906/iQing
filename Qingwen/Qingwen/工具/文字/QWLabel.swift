//
//  QWLabel.swift
//  Qingwen
//
//  Created by wei lu on 8/12/17.
//  Copyright © 2017 iQing. All rights reserved.
//

import Foundation
import UIKit

class QWLabel: UILabel{
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
        self.setup()
    }
    
    override init(frame:CGRect) {
        super.init(frame:frame)
        self.setup()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setup()
    }
    
    func setup() {
        self.text = self.text
        self.textColor = self.textColor
        self.font = self.font
        self.textLayer().alignmentMode = kCAAlignmentJustified
        self.textLayer().wrapped = true
        self.layer.display()
    }
}
