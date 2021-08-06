//
//  QWBestGuessCRView.swift
//  Qingwen
//
//  Created by Aimy on 11/10/15.
//  Copyright © 2015 iQing. All rights reserved.
//

import UIKit

protocol QWBestGuessCRViewDelegate: NSObjectProtocol {
    func guessView(_ view: QWBestGuessCRView, onPressedGuessBtn sender:UIButton)
}

class QWBestGuessCRView: QWBaseCRView {

    weak var delegate: QWBestGuessCRViewDelegate?
    @IBOutlet var guessBtn: UIButton!
    @IBOutlet var bgView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()

        self.bgView.bk_tapped { [weak self] () -> Void in
            if let weakSelf = self {
                weakSelf.delegate?.guessView(weakSelf, onPressedGuessBtn: weakSelf.guessBtn)
            }
        }
    }

    @IBAction func onPressedGuessBtn(_ sender: AnyObject) {
        self.delegate?.guessView(self, onPressedGuessBtn: self.guessBtn)
    }
}
