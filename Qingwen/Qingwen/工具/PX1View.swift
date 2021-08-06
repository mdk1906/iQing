//
//  PX1View.swift
//  Qingwen
//
//  Created by Aimy on 10/8/15.
//  Copyright © 2015 iQing. All rights reserved.
//

import UIKit

class PX1View: UIView {

    @IBOutlet var heightOrWidthConstraint: NSLayoutConstraint?

    override func awakeFromNib() {
        super.awakeFromNib()

        self.heightOrWidthConstraint?.constant = 1.0 / UIScreen.main.scale
    }

}
