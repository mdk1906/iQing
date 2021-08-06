//
//  QWFilterChannelView.swift
//  Qingwen
//
//  Created by mumu on 17/3/29.
//  Copyright © 2017年 iQing. All rights reserved.
//

import UIKit

protocol QWFilterChannelViewDelegate: NSObjectProtocol {
    func onPressedChannelBtn(_ sender: UIButton)
}

class QWFilterChannelView: UIView {

    @IBOutlet var channelButtons: [UIButton]!
    
    @IBOutlet weak var currentButton: UIButton!
    
    weak var delegate: QWFilterChannelViewDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.currentButton.selectedBackgroundColor = UIColor.colorEE()
    }
    
    @IBAction func onPressedChannelBtn(_ sender: UIButton) {
        if self.currentButton == sender {
            return
        }
        self.currentButton.isSelected = false
        self.currentButton = sender
        self.currentButton.isSelected = true
        self.currentButton.selectedBackgroundColor = UIColor.colorEE()
        
        delegate?.onPressedChannelBtn(sender)
    }

}
